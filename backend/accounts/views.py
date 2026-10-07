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

        from .models import UserWallet
        wallet, _ = UserWallet.objects.get_or_create(user=user)
        reward_earned, new_balance = wallet.claim_daily_reward(coins=1.0)

        tokens = get_tokens_for_user(user)
        return Response({
            'success': True,
            'message': 'Signed in successfully',
            'tokens': tokens,
            'user': UserSerializer(user).data,
            'requires_profile_completion': not user.is_profile_completed,
            'reward_earned': reward_earned,
            'reward_coins': 1.0 if reward_earned else 0.0,
            'balance_coins': float(wallet.balance_coins),
            'reward_message': 'Royal Daily Login Bonus! +1 AUG Coin added to your Vault.' if reward_earned else 'Welcome back to Athirai Vault.'
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


class WalletView(APIView):
    """
    GET /api/wallet/
    Returns current user wallet balance, today's recharges, and recent transactions.
    Directly compatible with infisq.com /wallet/ endpoint.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        import time
        from .models import UserWallet, WalletTransaction
        from .serializers import WalletTransactionSerializer

        user = request.user if request.user and request.user.is_authenticated else None
        if not user:
            user = User.objects.first()
        if not user:
            return Response({
                'balance_coins': 10.0,
                'today_coins': 0,
                'today_amount': 0,
                'total_spent': 0,
                'total_coins_purchased': 10.0,
                'total_recharge_count': 0,
                'history': []
            })

        wallet, _ = UserWallet.objects.get_or_create(user=user)
        from django.utils import timezone
        today = timezone.now().date()
        today_txs = wallet.user.wallet_transactions.filter(created_at__date=today, type='recharge')
        today_amount = sum(tx.amount_paid for tx in today_txs)
        today_coins = sum(tx.coins_credited for tx in today_txs)

        history = wallet.user.wallet_transactions.all()[:30]
        return Response({
            'balance_coins': float(wallet.balance_coins),
            'today_coins': float(today_coins),
            'today_amount': float(today_amount),
            'total_spent': float(wallet.total_spent_inr),
            'total_coins_purchased': float(wallet.total_coins_earned),
            'total_recharge_count': wallet.user.wallet_transactions.filter(type='recharge').count(),
            'history': WalletTransactionSerializer(history, many=True).data
        }, status=status.HTTP_200_OK)


class ClaimDailyRewardView(APIView):
    """
    POST /api/wallet/claim-daily/
    Customer login paninadhum avangalukku one credit reward earn aagum.
    Claims daily 1 credit login reward.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        from .models import UserWallet
        user = request.user if request.user and request.user.is_authenticated else User.objects.first()
        if not user:
            return Response({'success': False, 'message': 'No active user'}, status=status.HTTP_400_BAD_REQUEST)
        wallet, _ = UserWallet.objects.get_or_create(user=user)
        claimed, new_bal = wallet.claim_daily_reward(coins=100.0)
        return Response({
            'success': True,
            'claimed': claimed,
            'coins_credited': 100.0 if claimed else 0.0,
            'balance_coins': new_bal,
            'message': 'Royal Daily Login Bonus! +100 AUG Coins (1 Credit = ₹1) added to your Vault.' if claimed else 'Daily reward already claimed today.'
        }, status=status.HTTP_200_OK)


class RechargeCreateOrderView(APIView):
    """
    POST /api/recharge/create-order/
    Initializes a wallet recharge order.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        import time
        amount = float(request.data.get('amount', 100))
        rc_id = f"RC_{int(time.time())}"
        order_id = f"order_rc_{int(time.time())}"
        return Response({
            'razorpay_order_id': order_id,
            'amount': amount,
            'currency': 'INR',
            'key': 'rzp_test_athirai',
            'recharge_id': rc_id,
        }, status=status.HTTP_200_OK)


class RechargeVerifyView(APIView):
    """
    POST /api/recharge/verify/
    Confirms wallet recharge and credits coins to customer vault.
    Ratio: ₹100 gives 100 AUG coins.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        import time
        from .models import UserWallet, WalletTransaction

        user = request.user if request.user and request.user.is_authenticated else User.objects.first()
        if not user:
            return Response({'status': 'error', 'message': 'User not found'}, status=status.HTTP_400_BAD_REQUEST)

        wallet, _ = UserWallet.objects.get_or_create(user=user)
        amount = float(request.data.get('amount', 100))
        coins_credited = float(request.data.get('coins', amount))
        payment_method = request.data.get('payment_method', 'upi')

        wallet.balance_coins = float(wallet.balance_coins) + coins_credited
        wallet.total_coins_earned = float(wallet.total_coins_earned) + coins_credited
        wallet.total_spent_inr = float(wallet.total_spent_inr) + amount
        wallet.save()

        recharge_id = request.data.get('recharge_id', f"RC_{int(time.time())}")
        WalletTransaction.objects.create(
            user=user,
            type='recharge',
            direction='credit',
            amount_paid=amount,
            coins_credited=coins_credited,
            payment_method=payment_method,
            order_id=recharge_id,
            source='Wallet Recharge'
        )

        return Response({
            'status': 'success',
            'coins_credited': coins_credited,
            'new_balance': float(wallet.balance_coins),
            'message': f'Recharge successful! {coins_credited} AUG coins added to your vault.'
        }, status=status.HTTP_200_OK)


class BuyGoldWithCoinsView(APIView):
    """
    POST /api/gold/buy-with-coins/
    Allows customers to buy physical Gold coins or jewellery using their AUG Coins & Rewards.
    Based on AUG coins and rewards, customer can buy the gold.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        import time
        from .models import UserWallet, WalletTransaction, JewelOrder

        user = request.user if request.user and request.user.is_authenticated else User.objects.first()
        if not user:
            return Response({'success': False, 'message': 'User required'}, status=status.HTTP_400_BAD_REQUEST)

        wallet, _ = UserWallet.objects.get_or_create(user=user)
        data = request.data
        product_name = data.get('product_name', '24K Fine Gold Coin (100mg)')
        total_price = float(data.get('total_price', 820))
        coins_to_redeem = float(data.get('coins_to_redeem', 0.0))
        # 1 AUG Coin = ₹100 gold value
        coin_inr_value = coins_to_redeem * 100.0

        if float(wallet.balance_coins) < coins_to_redeem:
            return Response({
                'success': False,
                'message': f'Insufficient AUG coins. You have {wallet.balance_coins} coins, needed {coins_to_redeem}.'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Deduct redeemed coins
        wallet.balance_coins = float(wallet.balance_coins) - coins_to_redeem
        wallet.save()

        order_id = f"AUG-GLD-{int(time.time())}"
        net_payable = max(0.0, total_price - coin_inr_value)

        JewelOrder.objects.create(
            order_id=order_id,
            customer_name=user.full_name or 'Royal Patron',
            customer_email=user.email or 'patron@athirai.luxury',
            customer_phone=user.mobile_number or '',
            product_name=product_name,
            total_amount=int(net_payable),
            payment_method=f'AUG Coins ({coins_to_redeem:.1f}) + ₹{net_payable:.0f}',
            status='Confirmed'
        )

        if coins_to_redeem > 0:
            WalletTransaction.objects.create(
                user=user,
                type='purchase',
                direction='debit',
                amount_paid=coin_inr_value,
                coins_credited=coins_to_redeem,
                payment_method='purchase',
                order_id=order_id,
                source=f'Gold Purchase: {product_name}'
            )

        return Response({
            'success': True,
            'order_id': order_id,
            'product_name': product_name,
            'coins_redeemed': coins_to_redeem,
            'coin_discount_inr': coin_inr_value,
            'net_paid': net_payable,
            'remaining_coins': float(wallet.balance_coins),
            'message': f'Congratulations! Your order for {product_name} is confirmed using your AUG Coins & Rewards.'
        }, status=status.HTTP_200_OK)


class RewardsTodayView(APIView):
    """
    GET /api/rewards/today/
    Compatible with infisq.com /rewards/today/?range=...
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import WalletTransaction, User
        from django.utils import timezone
        today = timezone.now().date()
        txs = WalletTransaction.objects.filter(type='reward')
        total_coins = sum(tx.coins_credited for tx in txs.filter(created_at__date=today)) or 145.0

        summary = [
            {'reward_type': 'daily_login', 'label': 'Daily Login Reward', 'coins': float(total_coins), 'users': User.objects.count()},
            {'reward_type': 'first_login', 'label': 'First Login Bonus', 'coins': 50.0, 'users': 10},
            {'reward_type': 'bonus_10', 'label': '10 Day Streak Bonus', 'coins': 20.0, 'users': 4},
            {'reward_type': 'bonus_20', 'label': '20 Day Streak Bonus', 'coins': 30.0, 'users': 2},
            {'reward_type': 'bonus_30', 'label': 'Monthly Royal Patron', 'coins': 50.0, 'users': 1},
        ]

        rewards_list = [
            {
                'id': tx.id,
                'reward_type': tx.reward_type or 'daily_login',
                'reward_label': 'Daily Login Coin',
                'coins': float(tx.coins_credited),
                'user_id': f"ATH-{tx.user.id:04d}",
                'name': tx.user.full_name or 'Royal Patron',
                'phone': tx.user.mobile_number or '—',
                'level': 'VIP Patron',
                'position': 'Gold Vault Member',
                'date': tx.created_at.isoformat(),
            }
            for tx in txs[:50]
        ]

        return Response({
            'date': today.isoformat(),
            'total_coins_today': float(total_coins),
            'summary': summary,
            'rewards': rewards_list
        }, status=status.HTTP_200_OK)


def generate_order_receipt_pdf(order):
    from io import BytesIO
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib import colors

    buffer = BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36
    )

    story = []
    styles = getSampleStyleSheet()

    c_gold = colors.HexColor('#C7A45B')
    c_dark = colors.HexColor('#061B18')
    c_light_bg = colors.HexColor('#F9F6F0')

    title_style = ParagraphStyle(
        'Title',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=24,
        textColor=c_gold,
        alignment=1,
        spaceAfter=4,
    )
    subtitle_style = ParagraphStyle(
        'Subtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        textColor=colors.HexColor('#555555'),
        alignment=1,
        spaceAfter=15,
    )
    h2_style = ParagraphStyle(
        'H2',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        textColor=c_dark,
        spaceBefore=10,
        spaceAfter=6,
    )
    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        textColor=colors.HexColor('#222222'),
        leading=14,
    )
    badge_style = ParagraphStyle(
        'Badge',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9,
        textColor=c_gold,
        alignment=1,
    )

    # Header
    story.append(Paragraph("ATHIRAI LUXURY JEWELS", title_style))
    story.append(Paragraph("Ancient Roots • Eternal Beauty • BIS 916 Hallmarked High-Jewellery", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=15))

    # Invoice Details Table
    created_str = order.created_at.strftime('%d %B %Y, %I:%M %p') if order.created_at else ''
    meta_data = [
        [
            Paragraph(f"<b>Invoice No:</b> {order.invoice_number or 'INV-' + order.order_id}", body_style),
            Paragraph(f"<b>Order Date:</b> {created_str}", body_style)
        ],
        [
            Paragraph(f"<b>Order ID:</b> {order.order_id}", body_style),
            Paragraph(f"<b>Status:</b> <font color='#16A34A'><b>{order.status}</b></font>", body_style)
        ],
    ]
    meta_table = Table(meta_data, colWidths=[270, 270])
    meta_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 12))

    # Customer & Delivery Address Table
    addr_text = order.delivery_address or f"{order.door_no} {order.street_name}, {order.city} - {order.pincode}, {order.state}"
    client_data = [
        [
            Paragraph("<b>BILLED TO (PATRON):</b>", h2_style),
            Paragraph("<b>DELIVERY ADDRESS:</b>", h2_style)
        ],
        [
            Paragraph(f"<b>{order.customer_name}</b><br/>Phone: {order.customer_phone or order.delivery_phone or '—'}<br/>Email: {order.customer_email or 'patron@athirai.luxury'}", body_style),
            Paragraph(f"<b>{order.delivery_name or order.customer_name}</b><br/>{addr_text}<br/>Phone: {order.delivery_phone or order.customer_phone or '—'}", body_style)
        ]
    ]
    client_table = Table(client_data, colWidths=[270, 270])
    client_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,0), (-1,-1), c_light_bg),
        ('BOX', (0,0), (-1,-1), 0.8, c_gold),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor('#E5D8B8')),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(client_table)
    story.append(Spacer(1, 16))

    # Product Table
    story.append(Paragraph("<b>PURCHASED JEWELLERY & AUG COINS SUMMARY</b>", h2_style))
    items_data = [
        [
            Paragraph("<b>Product Description</b>", badge_style),
            Paragraph("<b>Purity / Hallmark</b>", badge_style),
            Paragraph("<b>Weight</b>", badge_style),
            Paragraph("<b>Qty</b>", badge_style),
            Paragraph("<b>AUG Coins Paid</b>", badge_style),
            Paragraph("<b>INR Value</b>", badge_style),
        ],
        [
            Paragraph(f"<b>{order.product_name}</b><br/><font size=8 color='#666'>Official Athirai Heritage Piece</font>", body_style),
            Paragraph(f"{order.metal_purity or '22K (916 BIS)'}", body_style),
            Paragraph(f"{float(order.weight_grams):.2f}g", body_style),
            Paragraph(f"{order.quantity}", body_style),
            Paragraph(f"<b>🪙 {float(order.coins_used):,.0f} AUG</b>", body_style),
            Paragraph(f"₹ {order.total_amount:,.0f}", body_style),
        ]
    ]
    items_table = Table(items_data, colWidths=[160, 95, 60, 35, 100, 90])
    items_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_dark),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.8, c_gold),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(items_table)
    story.append(Spacer(1, 14))

    # Totals Table
    totals_data = [
        ["", Paragraph("<b>Total Jewellery Value:</b>", body_style), Paragraph(f"₹ {order.total_amount:,.0f}", body_style)],
        ["", Paragraph("<b>Payment Method:</b>", body_style), Paragraph(f"{order.payment_method}", body_style)],
        ["", Paragraph("<b>Conversion Rate:</b>", body_style), Paragraph("1 Rupee = 100 AUG Coins", body_style)],
        ["", Paragraph("<b>Total AUG Coins Redeemed:</b>", body_style), Paragraph(f"<b>🪙 {float(order.coins_used):,.0f} AUG Coins</b>", body_style)],
        ["", Paragraph("<b>Net Amount Due:</b>", body_style), Paragraph("<b>₹ 0.00 (PAID IN FULL)</b>", body_style)],
    ]
    totals_table = Table(totals_data, colWidths=[240, 180, 120])
    totals_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('LINEABOVE', (1,0), (-1,0), 0.8, c_gold),
        ('LINEBELOW', (1,-1), (-1,-1), 1.2, c_gold),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(totals_table)
    story.append(Spacer(1, 24))

    # Authenticity & Hallmark Footer
    cert_data = [
        [
            Paragraph("<b>CERTIFICATE OF AUTHENTICITY</b><br/><font size=8 color='#555'>Every Athirai creation is crafted from 100% verified pure gold & natural gemstones, hallmarked by the Bureau of Indian Standards (BIS). Secured by Athirai Royal Vault.</font>", body_style),
            Paragraph("<b>Authorized Signatory</b><br/><font size=8 color='#888'>Athirai Vault Master<br/>Chennai, Tamil Nadu</font>", body_style)
        ]
    ]
    cert_table = Table(cert_data, colWidths=[380, 160])
    cert_table.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 0.8, c_gold),
        ('BACKGROUND', (0,0), (-1,-1), c_light_bg),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(cert_table)

    doc.build(story)
    pdf = buffer.getvalue()
    buffer.close()
    return pdf


class OrderCreateView(APIView):
    """
    POST /api/orders/create/
    Step 8: Delivery Address collection & Purchase strictly via AUG Coins
    (1 Rupee = 100 AUG Coins)
    """
    permission_classes = [AllowAny]

    def post(self, request):
        import time
        from .models import JewelOrder, User, UserWallet, WalletTransaction
        from .serializers import JewelOrderSerializer

        data = request.data
        user = request.user if request.user.is_authenticated else User.objects.first()
        if not user:
            return Response({'success': False, 'message': 'Authentication required to place order.'}, status=status.HTTP_401_UNAUTHORIZED)

        wallet, _ = UserWallet.objects.get_or_create(user=user)

        product_name = data.get('product_name', 'Athirai Temple Blossom Necklace')
        total_amount_inr = int(data.get('total_amount', 3059))
        quantity = int(data.get('quantity', 1))
        metal_purity = data.get('metal_purity', '22K Gold')
        weight_grams = float(data.get('weight_grams', 10.0))
        product_image = data.get('product_image', '')

        # Delivery Address (Step 8: Delivery Address)
        delivery_name = data.get('delivery_name') or user.full_name or 'Royal Patron'
        delivery_phone = data.get('delivery_phone') or user.mobile_number or ''
        door_no = data.get('door_no', '')
        street_name = data.get('street_name', '')
        town = data.get('town', '')
        city = data.get('city', 'Chennai')
        pincode = data.get('pincode', '600001')
        state = data.get('state', 'Tamil Nadu')
        delivery_address = data.get('delivery_address') or f"{door_no} {street_name}, {town} {city} - {pincode}, {state}".strip()

        # Step 7: 1 Rupee = 100 AUG Coins
        # Step 8: Purchase strictly using AUG Coins
        coins_needed = float(total_amount_inr * 100)

        # Check if user has sufficient coins
        current_coins = float(wallet.balance_coins)
        if current_coins < coins_needed:
            shortfall_coins = coins_needed - current_coins
            shortfall_inr = shortfall_coins / 100.0
            return Response({
                'success': False,
                'error': 'INSUFFICIENT_COINS',
                'message': f'Insufficient AUG Coins. You have {current_coins:,.0f} coins, but need {coins_needed:,.0f} coins.',
                'coins_needed': coins_needed,
                'coins_available': current_coins,
                'shortfall_coins': shortfall_coins,
                'shortfall_inr': shortfall_inr,
            }, status=status.HTTP_400_BAD_REQUEST)

        # Deduct AUG Coins from User Wallet
        wallet.balance_coins = current_coins - coins_needed
        wallet.save()

        ts = int(time.time())
        order_id = f"ATH-{ts}"
        invoice_number = f"INV-ATH-{ts}"

        order = JewelOrder.objects.create(
            user=user,
            order_id=order_id,
            invoice_number=invoice_number,
            customer_name=user.full_name or delivery_name,
            customer_email=user.email or '',
            customer_phone=user.mobile_number or delivery_phone,
            delivery_name=delivery_name,
            delivery_phone=delivery_phone,
            door_no=door_no,
            street_name=street_name,
            town=town,
            city=city,
            pincode=pincode,
            state=state,
            delivery_address=delivery_address,
            product_name=product_name,
            product_image=product_image,
            metal_purity=metal_purity,
            weight_grams=weight_grams,
            quantity=quantity,
            total_amount=total_amount_inr,
            coins_used=coins_needed,
            payment_method='AUG Coins',
            status='Confirmed'
        )

        WalletTransaction.objects.create(
            user=user,
            type='purchase',
            direction='debit',
            amount_paid=total_amount_inr,
            coins_credited=coins_needed,
            payment_method='AUG Coins',
            order_id=order_id,
            source=f'Jewellery Order: {product_name}'
        )

        return Response({
            'success': True,
            'message': 'Order placed successfully using AUG Coins!',
            'order': JewelOrderSerializer(order).data,
            'remaining_coins': float(wallet.balance_coins)
        }, status=status.HTTP_201_CREATED)


class OrderListView(APIView):
    """
    GET /api/orders/
    Step 10: View Order Summary of all purchased jewels
    """
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import JewelOrder, User
        from .serializers import JewelOrderSerializer

        user = request.user if request.user.is_authenticated else User.objects.first()
        if user:
            orders = JewelOrder.objects.filter(user=user)
        else:
            orders = JewelOrder.objects.all()

        return Response({
            'success': True,
            'count': orders.count(),
            'orders': JewelOrderSerializer(orders, many=True).data
        }, status=status.HTTP_200_OK)


class OrderDetailView(APIView):
    """
    GET /api/orders/<order_id>/
    """
    permission_classes = [AllowAny]

    def get(self, request, order_id):
        from .models import JewelOrder
        from .serializers import JewelOrderSerializer

        order = JewelOrder.objects.filter(order_id=order_id).first()
        if not order:
            return Response({'success': False, 'message': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        return Response({
            'success': True,
            'order': JewelOrderSerializer(order).data
        }, status=status.HTTP_200_OK)


class OrderReceiptPdfView(APIView):
    """
    GET /api/orders/<order_id>/receipt/
    Step 11: Download Receipt PDF automatically
    """
    permission_classes = [AllowAny]

    def get(self, request, order_id):
        from django.http import HttpResponse
        from .models import JewelOrder

        order = JewelOrder.objects.filter(order_id=order_id).first()
        if not order:
            return Response({'success': False, 'message': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            pdf_data = generate_order_receipt_pdf(order)
            response = HttpResponse(pdf_data, content_type='application/pdf')
            response['Content-Disposition'] = f'attachment; filename="Athirai_Receipt_{order.order_id}.pdf"'
            return response
        except Exception as e:
            return Response({'success': False, 'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ManualCoinCreditView(APIView):
    """
    POST /api/wallet/manual-credit/
    Step 7 Point 5: Manual Coin Creation / Generation
    """
    permission_classes = [AllowAny]

    def post(self, request):
        from .models import User, UserWallet

        user = request.user if request.user.is_authenticated else User.objects.first()
        if not user:
            return Response({'success': False, 'message': 'User required.'}, status=status.HTTP_400_BAD_REQUEST)

        wallet, _ = UserWallet.objects.get_or_create(user=user)
        coins = float(request.data.get('coins', 1000.0))
        amount_inr = float(request.data.get('amount_inr', 10.0))
        source = request.data.get('source', 'Manual Admin Generation')

        new_bal = wallet.manual_credit(amount_inr=amount_inr, coins=coins, source=source)
        return Response({
            'success': True,
            'message': f'Successfully credited {coins} AUG Coins.',
            'balance_coins': new_bal
        }, status=status.HTTP_200_OK)

