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
    JewelProductDetailView,
    JewelCollectionListCreateView,
    JewelOrderListView,
    JewelCustomerListView,
    JewelVaultListView,
    AnalyticsSummaryView,
    WalletView,
    ClaimDailyRewardView,
    RechargeCreateOrderView,
    RechargeVerifyView,
    BuyGoldWithCoinsView,
    RewardsTodayView,
    OrderCreateView,
    OrderListView,
    OrderDetailView,
    OrderReceiptPdfView,
    ManualCoinCreditView,
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

    # AUG Coins, Recharge, Daily Rewards & Buy Gold via Coins Endpoints
    path('wallet/', WalletView.as_view(), name='wallet'),
    path('wallet/claim-daily/', ClaimDailyRewardView.as_view(), name='wallet_claim_daily'),
    path('recharge/create-order/', RechargeCreateOrderView.as_view(), name='recharge_create_order'),
    path('recharge/verify/', RechargeVerifyView.as_view(), name='recharge_verify'),
    path('gold/buy-with-coins/', BuyGoldWithCoinsView.as_view(), name='buy_gold_with_coins'),
    path('rewards/today/', RewardsTodayView.as_view(), name='rewards_today'),

    # Cloudinary Selfie & AI Avatar Endpoints
    path('selfie/upload/', SelfieUploadView.as_view(), name='selfie_upload'),
    path('selfie/latest/', LatestSelfieView.as_view(), name='selfie_latest'),
    path('selfie/list/', UserSelfieListView.as_view(), name='selfie_list'),

    # Dynamic Metal Rates & Jewellery CMS Endpoints
    path('rates/', MetalRateView.as_view(), name='live_metal_rates'),
    path('categories/', JewelCategoryListCreateView.as_view(), name='jewel_categories'),
    path('jewels/', JewelProductListCreateView.as_view(), name='jewel_products'),
    path('jewels/<int:pk>/', JewelProductDetailView.as_view(), name='jewel_detail'),
    path('collections/', JewelCollectionListCreateView.as_view(), name='jewel_collections'),
    path('orders/', JewelOrderListView.as_view(), name='jewel_orders'),
    path('orders/create/', OrderCreateView.as_view(), name='order_create'),
    path('orders/my-orders/', OrderListView.as_view(), name='my_orders'),
    path('orders/<str:order_id>/', OrderDetailView.as_view(), name='order_detail'),
    path('orders/<str:order_id>/receipt/', OrderReceiptPdfView.as_view(), name='order_receipt_pdf'),
    path('wallet/manual-credit/', ManualCoinCreditView.as_view(), name='wallet_manual_credit'),
    path('customers/', JewelCustomerListView.as_view(), name='jewel_customers'),
    path('vault/', JewelVaultListView.as_view(), name='jewel_vault'),
    path('analytics/summary/', AnalyticsSummaryView.as_view(), name='analytics_summary'),
    path('price-list/', JewelPriceListView.as_view(), name='jewel_price_list'),

    # Enterprise SSO Flow
    path('sso/discover/', SSODiscoverView.as_view(), name='sso_discover'),
    path('sso/callback/', SSOCallbackView.as_view(), name='sso_callback'),

    # Mock IdP Endpoints for offline/local simulation of Azure AD / Okta & MFA
    path('mock-idp/authorize/', MockIdPAuthorizeView.as_view(), name='mock_idp_authorize'),
    path('mock-idp/verify-mfa/', MockIdPVerifyMFAView.as_view(), name='mock_idp_verify_mfa'),
]

