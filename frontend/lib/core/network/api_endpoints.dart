import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String? _resolvedBaseUrl;

  /// Candidate backend URLs for Android devices:
  /// 1. http://127.0.0.1:8000 (USB debugging via adb reverse)
  /// 2. http://192.168.0.104:8000 (Local Wi-Fi network)
  /// 3. http://10.0.2.2:8000 (Android Emulator)
  static const List<String> androidCandidates = [
    'http://192.168.0.104:8000',
    'http://127.0.0.1:8000',
    'http://10.0.2.2:8000',
    'http://192.168.0.105:8000',
    'http://192.168.0.100:8000',
    'http://192.168.0.106:8000',
  ];

  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) return configuredUrl;
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;

    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) {
      // Default to active local machine Wi-Fi host IP
      return 'http://192.168.0.104:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static void setBaseUrl(String url) {
    _resolvedBaseUrl = url;
  }


  static String get login => '$baseUrl/api/auth/login/';
  static String get register => '$baseUrl/api/auth/register/';
  static String get ssoDiscover => '$baseUrl/api/auth/sso/discover/';
  static String get ssoCallback => '$baseUrl/api/auth/sso/callback/';
  static String get tokenRefresh => '$baseUrl/api/auth/token/refresh/';
  static String get logout => '$baseUrl/api/auth/logout/';
  static String get forgotPassword => '$baseUrl/api/auth/password/forgot/';
  static String get resetPassword => '$baseUrl/api/auth/password/reset/';
  static String get me => '$baseUrl/api/auth/me/';
  static String get profile => '$baseUrl/api/auth/profile/';
  static String get mockIdpAuthorize => '$baseUrl/api/auth/mock-idp/authorize/';
  static String get mockIdpVerifyMfa =>
      '$baseUrl/api/auth/mock-idp/verify-mfa/';

  // Cloudinary Selfie & AI Avatar Endpoints
  static String get selfieUpload => '$baseUrl/api/auth/selfie/upload/';
  static String get selfieLatest => '$baseUrl/api/auth/selfie/latest/';
  static String get selfieList => '$baseUrl/api/auth/selfie/list/';

  // Dynamic Jewellery, Categories & Price List Endpoints
  static String get rates => '$baseUrl/api/rates/';
  static String get categories => '$baseUrl/api/categories/';
  static String get jewels => '$baseUrl/api/jewels/';
  static String get priceList => '$baseUrl/api/price-list/';

  // AUG Coins, Wallet, Rewards & Buy Gold Endpoints
  static String get wallet => '$baseUrl/api/wallet/';
  static String get claimDailyReward => '$baseUrl/api/wallet/claim-daily/';
  static String get rechargeOrder => '$baseUrl/api/recharge/create-order/';
  static String get rechargeVerify => '$baseUrl/api/recharge/verify/';
  static String get buyGoldWithCoins => '$baseUrl/api/gold/buy-with-coins/';
  static String get rewardsToday => '$baseUrl/api/rewards/today/';

  // Order & Receipt Endpoints (Steps 8, 10, 11)
  static String get orderCreate => '$baseUrl/api/orders/create/';
  static String get myOrders => '$baseUrl/api/orders/my-orders/';
  static String orderDetail(String id) => '$baseUrl/api/orders/$id/';
  static String orderReceiptPdf(String id) => '$baseUrl/api/orders/$id/receipt/';
  static String get manualCoinCredit => '$baseUrl/api/wallet/manual-credit/';
}

