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

        # If user exists and password is provided, check password
        if user:
            if password and user.has_usable_password():
                if not user.check_password(password):
                    return Response({
                        'success': False,
                        'message': 'Invalid credentials. Please verify your password.'
                    }, status=status.HTTP_401_UNAUTHORIZED)
        else:
            # First time user entering identifier on main screen - auto create lightweight Athirai account
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
        user = User.objects.create_user(
            email=data['email'],
            password=data['password'],
            full_name=data.get('full_name', ''),
            mobile_number=data.get('mobile_number', ''),
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
