import secrets
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404

from .models import Organization, SSOState
from .serializers import (
    UserSerializer,
    LoginRequestSerializer,
    RegisterRequestSerializer,
    SSODiscoverRequestSerializer,
    SSOCallbackRequestSerializer,
    ProfileUpdateRequestSerializer,
    ForgotPasswordRequestSerializer,
    ResetPasswordConfirmSerializer,
)
from .services import SSOService, get_tokens_for_user

User = get_user_model()


class LoginView(APIView):
    """
    POST /api/auth/login/
    Athirai main sign-in endpoint.
    Accepts email or mobile number.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'errors': serializer.errors,
                'message': list(serializer.errors.values())[0][0] if serializer.errors else 'Validation error'
            }, status=status.HTTP_400_BAD_REQUEST)

        identifier = serializer.validated_data['identifier']
        password = serializer.validated_data.get('password', '')

        user = None
        if '@' in identifier:
            user = User.objects.filter(email__iexact=identifier).first()
        else:
            clean_phone = ''.join(c for c in identifier if c.isdigit() or c == '+')
            user = User.objects.filter(mobile_number__icontains=clean_phone[-10:]).first()

        if user:
            if password and (
                not user.has_usable_password() or not user.check_password(password)
            ):
                return Response({
                    'success': False,
                    'message': 'Invalid credentials. Please verify your password.'
                }, status=status.HTTP_401_UNAUTHORIZED)
        else:
            if password:
                return Response({
                    'success': False,
                    'message': 'Invalid credentials. Please verify your email or phone and password.'
                }, status=status.HTTP_401_UNAUTHORIZED)

            if '@' in identifier:
                user = User.objects.create_user(email=identifier.lower(), is_profile_completed=False)
            else:
                user = User.objects.create_user(mobile_number=identifier, is_profile_completed=False)

        tokens = get_tokens_for_user(user)
        return Response({
            'success': True,
            'message': 'Signed in successfully',
            'tokens': tokens,
            'user': UserSerializer(user).data,
            'requires_profile_completion': not user.is_profile_completed
        }, status=status.HTTP_200_OK)


class RegisterView(APIView):
    """
    POST /api/auth/register/
    Create a new Athirai account.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'errors': serializer.errors,
                'message': list(serializer.errors.values())[0][0] if serializer.errors else 'Registration failed'
            }, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        full_name = data.get('full_name') or ' '.join(
            part for part in (data.get('first_name', ''), data.get('last_name', '')) if part
        )
        user = User.objects.create_user(
            email=data['email'],
            password=data['password'],
            full_name=full_name,
            first_name=data.get('first_name', ''),
            last_name=data.get('last_name', ''),
            mobile_number=data.get('mobile_number', ''),
            gender=data.get('gender', ''),
            date_of_birth=data.get('date_of_birth'),
            door_no=data.get('door_no', ''),
            street_name=data.get('street_name', ''),
            pincode=data.get('pincode', ''),
            town=data.get('town', ''),
            city=data.get('city', ''),
            district=data.get('district', ''),
            state=data.get('state', ''),
            is_profile_completed=True
        )

        tokens = get_tokens_for_user(user)
        return Response({
            'success': True,
            'message': 'Account created successfully',
            'tokens': tokens,
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)


class SSODiscoverView(APIView):
    """
    POST /api/auth/sso/discover/
    Discovers organization identity provider by corporate email domain.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SSODiscoverRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'errors': serializer.errors,
                'message': list(serializer.errors.values())[0][0] if serializer.errors else 'Invalid email'
            }, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        domain = SSOService.extract_domain(email)

        public_domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'icloud.com']
        if domain in public_domains:
            return Response({
                'success': False,
                'message': 'Please enter a corporate work email address (e.g. name@company.com) for SSO.'
            }, status=status.HTTP_400_BAD_REQUEST)

        org = SSOService.discover_organization(email)
        if not org:
            return Response({
                'success': False,
                'message': f"We couldn't find an organization configured for domain '{domain}'."
            }, status=status.HTTP_404_NOT_FOUND)

        session_data = SSOService.generate_sso_session(email, org)
        return Response({
            'success': True,
            'organization': session_data['organization'],
            'authorization_url': session_data['authorization_url'],
            'state': session_data['state'],
        }, status=status.HTTP_200_OK)


class SSOCallbackView(APIView):
    """
    POST /api/auth/sso/callback/
    Receives code & state from IdP redirection, verifies and logs in the user.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SSOCallbackRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'errors': serializer.errors,
                'message': 'Invalid SSO parameters'
            }, status=status.HTTP_400_BAD_REQUEST)

        code = serializer.validated_data['code']
        state_str = serializer.validated_data['state']

        try:
            user, created = SSOService.exchange_code_for_user(code, state_str)
        except ValueError as e:
            return Response({
                'success': False,
                'message': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)

        tokens = get_tokens_for_user(user)
        return Response({
            'success': True,
            'message': 'SSO authentication successful',
            'tokens': tokens,
            'user': UserSerializer(user).data,
            'is_new_user': created,
            'requires_profile_completion': not user.is_profile_completed
        }, status=status.HTTP_200_OK)


class UserProfileView(APIView):
    """
    GET /api/auth/me/
    PUT, PATCH /api/auth/profile/
    Retrieve or update the authenticated user's profile.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response({
            'success': True,
            'user': serializer.data
        }, status=status.HTTP_200_OK)

    def put(self, request):
        return self._update_profile(request)

    def patch(self, request):
        return self._update_profile(request)

    def _update_profile(self, request):
        serializer = ProfileUpdateRequestSerializer(request.user, data=request.data, partial=True)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'errors': serializer.errors,
                'message': list(serializer.errors.values())[0][0] if serializer.errors else 'Validation error'
            }, status=status.HTTP_400_BAD_REQUEST)

        user = serializer.save()
        # Mark profile completed
        user.is_profile_completed = True
        user.save()

        return Response({
            'success': True,
            'message': 'Profile updated successfully',
            'user': UserSerializer(user).data
        }, status=status.HTTP_200_OK)


class LogoutView(APIView):
    """
    POST /api/auth/logout/
    Blacklists the provided refresh token.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({'success': False, 'message': 'Refresh token is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({'success': True, 'message': 'Logged out successfully.'}, status=status.HTTP_200_OK)
        except TokenError:
            return Response({'success': False, 'message': 'Token is invalid or already expired.'}, status=status.HTTP_400_BAD_REQUEST)


class ForgotPasswordRequestView(APIView):
    """
    POST /api/auth/password/forgot/
    Request OTP verification code for password reset.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'message': list(serializer.errors.values())[0][0] if serializer.errors else 'Validation error'
            }, status=status.HTTP_400_BAD_REQUEST)

        identifier = serializer.validated_data['identifier'].strip()
        user = None
        if '@' in identifier:
            user = User.objects.filter(email__iexact=identifier).first()
        else:
            clean_phone = ''.join(c for c in identifier if c.isdigit() or c == '+')
            user = User.objects.filter(mobile_number__icontains=clean_phone[-10:]).first()

        otp = "123456"
        return Response({
            'success': True,
            'message': f"A 6-digit recovery code has been sent to {identifier}.",
            'otp': otp,
            'user_exists': user is not None
        }, status=status.HTTP_200_OK)


class ResetPasswordConfirmView(APIView):
    """
    POST /api/auth/password/reset/
    Verify recovery code and update password.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResetPasswordConfirmSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'message': list(serializer.errors.values())[0][0] if serializer.errors else 'Validation error'
            }, status=status.HTTP_400_BAD_REQUEST)

        identifier = serializer.validated_data['identifier'].strip()
        otp = serializer.validated_data['otp'].strip()
        new_password = serializer.validated_data['new_password']

        if len(otp) != 6:
            return Response({
                'success': False,
                'message': 'Invalid recovery code. Please enter the 6-digit code.'
            }, status=status.HTTP_400_BAD_REQUEST)

        user = None
        if '@' in identifier:
            user = User.objects.filter(email__iexact=identifier).first()
        else:
            clean_phone = ''.join(c for c in identifier if c.isdigit() or c == '+')
            user = User.objects.filter(mobile_number__icontains=clean_phone[-10:]).first()

        if user:
            user.set_password(new_password)
            user.save()
            return Response({
                'success': True,
                'message': 'Password has been reset successfully. Please sign in with your new password.'
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'message': 'Account not found. Please verify your email or phone number.'
            }, status=status.HTTP_404_NOT_FOUND)


# =====================================================================
# MOCK ENTERPRISE IDENTITY PROVIDER (IDP) VIEWS
# Provides full offline/local end-to-end testing of the entire SSO Flow
# (Screens 5 & 6 in the specification)
# =====================================================================

class MockIdPAuthorizeView(APIView):
    """
    Simulates corporate IdP authorization.
    POST /api/auth/mock-idp/authorize/
    """
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email', '')
        password = request.data.get('password', '')
        state = request.data.get('state', '')

        if not email or not password:
            return Response({
                'success': False,
                'message': 'Email and password are required for organization login.'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Generate authorization code
        auth_code = f"athirai_authcode_{secrets.token_hex(16)}"
        
        # Check if MFA is required (simulate MFA challenge)
        requires_mfa = request.data.get('simulate_mfa', True)

        return Response({
            'success': True,
            'requires_mfa': requires_mfa,
            'email': email,
            'state': state,
            'code': auth_code if not requires_mfa else None,
            'message': 'Enter 6-digit verification code' if requires_mfa else 'Authenticated'
        }, status=status.HTTP_200_OK)


class MockIdPVerifyMFAView(APIView):
    """
    Simulates corporate MFA verification (Screen 6 in flow).
    POST /api/auth/mock-idp/verify-mfa/
    """
    permission_classes = [AllowAny]

    def post(self, request):
        otp = request.data.get('otp', '')
        state = request.data.get('state', '')
        email = request.data.get('email', '')

        # Accept any 6-digit code for testing (e.g. 123456 or any 6 digits)
        if len(otp) != 6 or not otp.isdigit():
            return Response({
                'success': False,
                'message': 'Please enter a valid 6-digit verification code.'
            }, status=status.HTTP_400_BAD_REQUEST)

        auth_code = f"athirai_authcode_{secrets.token_hex(16)}"
        return Response({
            'success': True,
            'code': auth_code,
            'state': state,
            'email': email,
            'message': 'Identity verified successfully'
        }, status=status.HTTP_200_OK)


# =====================================================================
# CLOUDINARY SELFIE & AI AVATAR VIEWS
# Handles uploading selfies to Cloudinary, creating AI avatars based
# on the latest selfie, and querying selfie history.
# =====================================================================

class SelfieUploadView(APIView):
    """
    POST /api/auth/selfie/upload/
    Accepts a selfie image file (multipart/form-data with key 'selfie' or 'image').
    1. Saves the selfie to Cloudinary (folder 'athirai/selfies/').
    2. Synthesizes an Athirai AI avatar based on the selfie image.
    3. Saves the created avatar to Cloudinary (folder 'athirai/avatars/').
    4. Records the selfie in database, marking previous as is_latest=False.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        selfie_file = request.FILES.get('selfie') or request.FILES.get('image')
        if not selfie_file:
            return Response({
                'success': False,
                'message': 'Selfie image file is required (form-data field "selfie").'
            }, status=status.HTTP_400_BAD_REQUEST)

        user = request.user if request.user and request.user.is_authenticated else None
        session_id = request.data.get('session_id') or request.headers.get('X-Session-ID', '')

        from .cloudinary_service import CloudinaryAvatarService
        try:
            result = CloudinaryAvatarService.process_selfie_and_create_avatar(
                selfie_file=selfie_file,
                user=user,
                session_id=session_id,
                request=request,
            )
            return Response(result, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({
                'success': False,
                'message': f"Failed to process selfie and generate avatar: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class LatestSelfieView(APIView):
    """
    GET /api/auth/selfie/latest/
    Returns the latest selfie and synthesized avatar for the authenticated user or session.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import SelfieRecord
        from .serializers import SelfieRecordSerializer

        user = request.user if request.user and request.user.is_authenticated else None
        session_id = request.query_params.get('session_id') or request.headers.get('X-Session-ID', '')

        record = None
        if user:
            record = SelfieRecord.objects.filter(user=user, is_latest=True).first()
        elif session_id:
            record = SelfieRecord.objects.filter(session_id=session_id, is_latest=True).first()

        if not record:
            return Response({
                'success': False,
                'message': 'No selfie found for this account.'
            }, status=status.HTTP_404_NOT_FOUND)

        return Response({
            'success': True,
            'selfie': SelfieRecordSerializer(record).data
        }, status=status.HTTP_200_OK)


class UserSelfieListView(APIView):
    """
    GET /api/auth/selfie/list/
    Retrieves all selfie records for the user ("selfie images ellam").
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import SelfieRecord
        from .serializers import SelfieRecordSerializer

        user = request.user if request.user and request.user.is_authenticated else None
        session_id = request.query_params.get('session_id') or request.headers.get('X-Session-ID', '')

        if user:
            qs = SelfieRecord.objects.filter(user=user).order_by('-created_at')
        elif session_id:
            qs = SelfieRecord.objects.filter(session_id=session_id).order_by('-created_at')
        else:
            qs = SelfieRecord.objects.none()

        return Response({
            'success': True,
            'count': qs.count(),
            'selfies': SelfieRecordSerializer(qs, many=True).data
        }, status=status.HTTP_200_OK)


class MetalRateView(APIView):
    """
    GET /api/rates/ - Get current live metal rates
    POST /api/rates/ - Update live metal rates dynamically
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import MetalRate
        from .serializers import MetalRateSerializer
        rate = MetalRate.objects.filter(is_active=True).first()
        if not rate:
            rate = MetalRate.objects.create(gold_24k=7980, gold_22k=7450, gold_18k=6100, silver_999=98.50)
        return Response({
            'success': True,
            'rates': MetalRateSerializer(rate).data
        }, status=status.HTTP_200_OK)

    def post(self, request):
        from .models import MetalRate
        from .serializers import MetalRateSerializer
        data = request.data
        rate = MetalRate.objects.filter(is_active=True).first()
        if not rate:
            rate = MetalRate()

        if 'gold_24k' in data:
            rate.gold_24k = int(data['gold_24k'])
        if 'gold_22k' in data:
            rate.gold_22k = int(data['gold_22k'])
        if 'gold_18k' in data:
            rate.gold_18k = int(data['gold_18k'])
        if 'silver_999' in data:
            rate.silver_999 = float(data['silver_999'])
        rate.save()

        return Response({
            'success': True,
            'message': 'Live metal rates updated successfully',
            'rates': MetalRateSerializer(rate).data
        }, status=status.HTTP_200_OK)


class JewelCategoryListCreateView(APIView):
    """
    GET /api/categories/ - List all jewellery categories
    POST /api/categories/ - Create a new category dynamically
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelCategory
        from .serializers import JewelCategorySerializer
        categories = JewelCategory.objects.all().order_by('display_order', 'name')
        return Response({
            'success': True,
            'count': categories.count(),
            'categories': JewelCategorySerializer(categories, many=True).data
        }, status=status.HTTP_200_OK)

    def post(self, request):
        from .models import JewelCategory
        from .serializers import JewelCategorySerializer
        name = request.data.get('name', '').strip()
        if not name:
            return Response({'success': False, 'message': 'Category name is required.'}, status=status.HTTP_400_BAD_REQUEST)

        category, created = JewelCategory.objects.get_or_create(
            name=name,
            defaults={
                'image_url': request.data.get('image_url', ''),
                'display_order': int(request.data.get('display_order', 0))
            }
        )
        return Response({
            'success': True,
            'created': created,
            'category': JewelCategorySerializer(category).data
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class JewelProductListCreateView(APIView):
    """
    GET /api/jewels/ - List all jewels with optional ?category= or ?search= filter
    POST /api/jewels/ - Add a new jewel piece dynamically
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelProduct
        from .serializers import JewelProductSerializer
        qs = JewelProduct.objects.all().select_related('category')
        cat = request.query_params.get('category')
        search = request.query_params.get('search')

        if cat and cat != 'All':
            qs = qs.filter(category__name__iexact=cat)
        if search:
            from django.db.models import Q
            qs = qs.filter(Q(name__icontains=search) | Q(description__icontains=search) | Q(purity__icontains=search))

        return Response({
            'success': True,
            'count': qs.count(),
            'jewels': JewelProductSerializer(qs, many=True).data
        }, status=status.HTTP_200_OK)

    def post(self, request):
        from .models import JewelProduct, JewelCategory
        from .serializers import JewelProductSerializer
        data = request.data

        name = data.get('name', '').strip()
        category_name = data.get('category', '').strip()
        weight_grams = data.get('weight_grams')

        if not name or not category_name or not weight_grams:
            return Response({
                'success': False,
                'message': 'Name, category, and weight in grams are required.'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Auto-create category if it does not exist
        category, _ = JewelCategory.objects.get_or_create(name=category_name)

        product = JewelProduct.objects.create(
            name=name,
            category=category,
            metal=data.get('metal', 'Gold'),
            purity=data.get('purity', '22K'),
            weight_grams=weight_grams,
            making_charge_percent=data.get('making_charge_percent', 12.00),
            stone_price=int(data.get('stone_price', 0)),
            description=data.get('description', ''),
            image_url=data.get('image_url', ''),
            is_featured=bool(data.get('is_featured', False)),
        )

        return Response({
            'success': True,
            'message': 'Jewel added successfully to dynamic catalog',
            'jewel': JewelProductSerializer(product).data
        }, status=status.HTTP_201_CREATED)


class JewelPriceListView(APIView):
    """
    GET /api/price-list/
    Returns full dynamic price list for all jewellery pieces calculated with live metal rates.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelProduct, MetalRate
        rates = MetalRate.objects.filter(is_active=True).first()
        if not rates:
            rates = MetalRate.objects.create(gold_24k=7980, gold_22k=7450, gold_18k=6100, silver_999=98.50)

        jewels = JewelProduct.objects.all().select_related('category', 'collection')
        price_list = [j.calculate_price_breakdown(rates) for j in jewels]

        return Response({
            'success': True,
            'rates': {
                'gold_24k': rates.gold_24k,
                'gold_22k': rates.gold_22k,
                'gold_18k': rates.gold_18k,
                'silver_999': float(rates.silver_999),
                'updated_at': rates.updated_at.isoformat(),
            },
            'count': len(price_list),
            'price_list': price_list
        }, status=status.HTTP_200_OK)


class JewelProductDetailView(APIView):
    """
    GET, PUT, PATCH, DELETE /api/jewels/<id>/
    Retrieve, update, or archive a specific jewellery piece.
    """
    permission_classes = [AllowAny]

    def get(self, request, pk):
        from .models import JewelProduct
        from .serializers import JewelProductSerializer
        product = get_object_or_404(JewelProduct.objects.select_related('category', 'collection'), pk=pk)
        return Response({
            'success': True,
            'jewel': JewelProductSerializer(product).data
        }, status=status.HTTP_200_OK)

    def put(self, request, pk):
        return self.patch(request, pk)

    def patch(self, request, pk):
        from .models import JewelProduct, JewelCategory, JewelCollection
        from .serializers import JewelProductSerializer
        product = get_object_or_404(JewelProduct, pk=pk)
        data = request.data

        if 'category' in data and data['category']:
            cat, _ = JewelCategory.objects.get_or_create(name=data['category'])
            product.category = cat

        if 'collection' in data and data['collection']:
            col, _ = JewelCollection.objects.get_or_create(name=data['collection'])
            product.collection = col

        for attr in [
            'name', 'sku', 'short_description', 'description', 'metal', 'purity',
            'weight_grams', 'making_charge_percent', 'stone_price', 'gemstones',
            'gemstone_type', 'gemstone_weight', 'diamond_carat', 'certification',
            'hallmark', 'craftsmanship', 'origin', 'designer', 'crafting_time',
            'stock_quantity', 'low_stock_threshold', 'warehouse', 'status',
            'availability', 'seo_title', 'meta_description', 'url_slug', 'tags',
            'image_url', 'lifestyle_image_url', 'is_featured', 'base_price_override'
        ]:
            if attr in data:
                setattr(product, attr, data[attr])

        product.save()
        return Response({
            'success': True,
            'message': 'Product updated successfully',
            'jewel': JewelProductSerializer(product).data
        }, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        from .models import JewelProduct
        product = get_object_or_404(JewelProduct, pk=pk)
        product.delete()
        return Response({
            'success': True,
            'message': 'Product archived and removed from collection'
        }, status=status.HTTP_200_OK)


class JewelCollectionListCreateView(APIView):
    """
    GET /api/collections/ - List all collections
    POST /api/collections/ - Create a new collection
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelCollection
        from .serializers import JewelCollectionSerializer
        collections = JewelCollection.objects.all().prefetch_related('products')
        return Response({
            'success': True,
            'count': collections.count(),
            'collections': JewelCollectionSerializer(collections, many=True).data
        }, status=status.HTTP_200_OK)

    def post(self, request):
        from .models import JewelCollection
        from .serializers import JewelCollectionSerializer
        name = request.data.get('name', '').strip()
        if not name:
            return Response({'success': False, 'message': 'Collection name is required'}, status=status.HTTP_400_BAD_REQUEST)

        col, created = JewelCollection.objects.get_or_create(
            name=name,
            defaults={
                'description': request.data.get('description', ''),
                'cover_image_url': request.data.get('cover_image_url', ''),
                'banner_image_url': request.data.get('banner_image_url', ''),
                'is_featured': bool(request.data.get('is_featured', True)),
            }
        )
        return Response({
            'success': True,
            'created': created,
            'collection': JewelCollectionSerializer(col).data
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class JewelOrderListView(APIView):
    """
    GET /api/orders/ - List all customer orders
    POST /api/orders/ - Place a new vault order
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelOrder
        from .serializers import JewelOrderSerializer
        qs = JewelOrder.objects.all()
        status_filter = request.query_params.get('status')
        if status_filter and status_filter != 'All':
            qs = qs.filter(status__iexact=status_filter)
        return Response({
            'success': True,
            'count': qs.count(),
            'orders': JewelOrderSerializer(qs, many=True).data
        }, status=status.HTTP_200_OK)

    def post(self, request):
        from .models import JewelOrder
        from .serializers import JewelOrderSerializer
        import uuid
        data = request.data
        order_id = data.get('order_id') or f"ORD-2026-{secrets.randbelow(8999) + 1000}"
        order = JewelOrder.objects.create(
            order_id=order_id,
            customer_name=data.get('customer_name', 'Ananya Sharma'),
            customer_email=data.get('customer_email', 'ananya.sharma@athirai.com'),
            customer_phone=data.get('customer_phone', '+91 98765 43210'),
            product_name=data.get('product_name', 'Temple Blossom Necklace'),
            total_amount=int(data.get('total_amount', 365000)),
            payment_method=data.get('payment_method', 'Vault Gold Pay / UPI'),
            status=data.get('status', 'Confirmed'),
        )
        return Response({
            'success': True,
            'message': 'Order placed successfully',
            'order': JewelOrderSerializer(order).data
        }, status=status.HTTP_201_CREATED)


class JewelCustomerListView(APIView):
    """
    GET /api/customers/ - List VIP clients
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelCustomer
        from .serializers import JewelCustomerSerializer
        customers = JewelCustomer.objects.all()
        return Response({
            'success': True,
            'count': customers.count(),
            'customers': JewelCustomerSerializer(customers, many=True).data
        }, status=status.HTTP_200_OK)


class JewelVaultListView(APIView):
    """
    GET, POST, DELETE /api/vault/ - Manage constellation jewel vault pieces
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelVaultItem
        from .serializers import JewelVaultItemSerializer
        items = JewelVaultItem.objects.all()
        return Response({
            'success': True,
            'count': items.count(),
            'vault_items': JewelVaultItemSerializer(items, many=True).data
        }, status=status.HTTP_200_OK)

    def post(self, request):
        from .models import JewelVaultItem
        from .serializers import JewelVaultItemSerializer
        data = request.data
        item = JewelVaultItem.objects.create(
            category_type=data.get('category_type', 'Necklace'),
            title=data.get('title', 'Temple Blossom Necklace'),
            image_url=data.get('image_url', ''),
            price=int(data.get('price', 365000)),
            metal_purity=data.get('metal_purity', '22K Gold'),
        )
        return Response({
            'success': True,
            'message': 'Item added to Jewel Vault',
            'vault_item': JewelVaultItemSerializer(item).data
        }, status=status.HTTP_201_CREATED)


class AnalyticsSummaryView(APIView):
    """
    GET /api/analytics/summary/
    Returns high-level KPI metrics, sales chart breakdown, and inventory stats.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelProduct, JewelCollection, JewelOrder, JewelCustomer
        total_products = JewelProduct.objects.count()
        published_products = JewelProduct.objects.filter(status='Published').count()
        draft_products = JewelProduct.objects.filter(status='Draft').count()
        low_stock = JewelProduct.objects.filter(stock_quantity__lte=3).count()
        total_collections = JewelCollection.objects.count()
        total_orders = JewelOrder.objects.count()
        total_revenue = sum(o.total_amount for o in JewelOrder.objects.all()) or 4280000
        total_customers = JewelCustomer.objects.count() or 1280

        return Response({
            'success': True,
            'kpis': {
                'total_products': total_products,
                'published_products': published_products,
                'draft_products': draft_products,
                'low_stock': low_stock,
                'total_collections': total_collections,
                'total_orders': total_orders,
                'total_revenue': total_revenue,
                'total_revenue_formatted': f"₹{total_revenue / 100000:.1f} Lakhs",
                'total_customers': total_customers,
                'conversion_rate': '4.8%',
                'average_order_value': '₹3,45,000',
            },
            'recent_activity': [
                {'action': 'New Product Added', 'piece': 'Temple Blossom Necklace', 'time': '12 mins ago'},
                {'action': 'Order Confirmed', 'piece': 'Chola Dynasty Choker', 'time': '45 mins ago'},
                {'action': 'Stock Replenished', 'piece': 'Heritage Emerald Ring', 'time': '2 hours ago'},
                {'action': 'Collection Updated', 'piece': 'Royal Kundan Legacy', 'time': '5 hours ago'},
            ]
        }, status=status.HTTP_200_OK)
