from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    LoginView,
    RegisterView,
    SSODiscoverView,
    SSOCallbackView,
    UserProfileView,
    LogoutView,
    ForgotPasswordRequestView,
    ResetPasswordConfirmView,
    MockIdPAuthorizeView,
    MockIdPVerifyMFAView,
    SelfieUploadView,
    LatestSelfieView,
    UserSelfieListView,
    MetalRateView,
    JewelCategoryListCreateView,
    JewelProductListCreateView,
    JewelPriceListView,
)

urlpatterns = [
    # Core Authentication
    path('login/', LoginView.as_view(), name='auth_login'),
    path('register/', RegisterView.as_view(), name='auth_register'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', LogoutView.as_view(), name='auth_logout'),
    path('password/forgot/', ForgotPasswordRequestView.as_view(), name='auth_forgot_password'),
    path('password/reset/', ResetPasswordConfirmView.as_view(), name='auth_reset_password'),
    path('me/', UserProfileView.as_view(), name='auth_me'),
    path('profile/', UserProfileView.as_view(), name='auth_profile'),

    # Cloudinary Selfie & AI Avatar Endpoints
    path('selfie/upload/', SelfieUploadView.as_view(), name='selfie_upload'),
    path('selfie/latest/', LatestSelfieView.as_view(), name='selfie_latest'),
    path('selfie/list/', UserSelfieListView.as_view(), name='selfie_list'),

    # Dynamic Metal Rates & Jewellery Endpoints
    path('rates/', MetalRateView.as_view(), name='live_metal_rates'),
    path('categories/', JewelCategoryListCreateView.as_view(), name='jewel_categories'),
    path('jewels/', JewelProductListCreateView.as_view(), name='jewel_products'),
    path('price-list/', JewelPriceListView.as_view(), name='jewel_price_list'),

    # Enterprise SSO Flow
    path('sso/discover/', SSODiscoverView.as_view(), name='sso_discover'),
    path('sso/callback/', SSOCallbackView.as_view(), name='sso_callback'),

    # Mock IdP Endpoints for offline/local simulation of Azure AD / Okta & MFA
    path('mock-idp/authorize/', MockIdPAuthorizeView.as_view(), name='mock_idp_authorize'),
    path('mock-idp/verify-mfa/', MockIdPVerifyMFAView.as_view(), name='mock_idp_verify_mfa'),
]
