from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    LoginView,
    RegisterView,
    SSODiscoverView,
    SSOCallbackView,
    UserProfileView,
    LogoutView,
    MockIdPAuthorizeView,
    MockIdPVerifyMFAView,
)

urlpatterns = [
    # Core Authentication
    path('login/', LoginView.as_view(), name='auth_login'),
    path('register/', RegisterView.as_view(), name='auth_register'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', LogoutView.as_view(), name='auth_logout'),
    path('me/', UserProfileView.as_view(), name='auth_me'),
    path('profile/', UserProfileView.as_view(), name='auth_profile'),

    # Enterprise SSO Flow
    path('sso/discover/', SSODiscoverView.as_view(), name='sso_discover'),
    path('sso/callback/', SSOCallbackView.as_view(), name='sso_callback'),

    # Mock IdP Endpoints for offline/local simulation of Azure AD / Okta & MFA
    path('mock-idp/authorize/', MockIdPAuthorizeView.as_view(), name='mock_idp_authorize'),
    path('mock-idp/verify-mfa/', MockIdPVerifyMFAView.as_view(), name='mock_idp_verify_mfa'),
]
