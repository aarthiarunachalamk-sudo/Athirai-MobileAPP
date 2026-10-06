import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _accessTokenKey = 'athirai_access_token';
  static const _refreshTokenKey = 'athirai_refresh_token';
  static const _userEmailKey = 'athirai_user_email';
  static const _rememberedIdentifierKey = 'athirai_remembered_identifier';
  static const _isSessionActiveKey = 'athirai_session_active';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await setSessionActive(true);
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> setSessionActive(bool active) async {
    await _storage.write(key: _isSessionActiveKey, value: active ? 'true' : 'false');
  }

  Future<bool> isSessionActive() async {
    final val = await _storage.read(key: _isSessionActiveKey);
    return val == 'true';
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<void> saveRememberedIdentifier(String identifier) async {
    await _storage.write(key: _rememberedIdentifierKey, value: identifier);
  }

  Future<String?> getRememberedIdentifier() async {
    return await _storage.read(key: _rememberedIdentifierKey);
  }

  Future<void> clearRememberedIdentifier() async {
    await _storage.delete(key: _rememberedIdentifierKey);
  }

  /// Clears only the active session tokens.
  /// Preserves the user's remembered identifier (login screen pre-fill).
  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _isSessionActiveKey);
  }

  Future<void> clearAll({bool preserveRemembered = true}) async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _isSessionActiveKey);
    if (!preserveRemembered) {
      await _storage.delete(key: _rememberedIdentifierKey);
    }
  }
}
