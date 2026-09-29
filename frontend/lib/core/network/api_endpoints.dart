import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// Automatically resolves base URL depending on platform:
  /// - Android emulator: http://10.0.2.2:8000
  /// - Web / iOS / Windows Desktop: http://127.0.0.1:8000
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get login => '$baseUrl/api/auth/login/';
  static String get register => '$baseUrl/api/auth/register/';
  static String get ssoDiscover => '$baseUrl/api/auth/sso/discover/';
  static String get ssoCallback => '$baseUrl/api/auth/sso/callback/';
  static String get tokenRefresh => '$baseUrl/api/auth/token/refresh/';
  static String get logout => '$baseUrl/api/auth/logout/';
  static String get me => '$baseUrl/api/auth/me/';
  static String get profile => '$baseUrl/api/auth/profile/';

  // Mock IdP simulation endpoints
  static String get mockIdpAuthorize => '$baseUrl/api/auth/mock-idp/authorize/';
  static String get mockIdpVerifyMfa => '$baseUrl/api/auth/mock-idp/verify-mfa/';
}
