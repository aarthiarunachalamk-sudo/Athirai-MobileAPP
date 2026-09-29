import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/organization_model.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRepository({ApiClient? apiClient, SecureStorageService? storage})
      : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? SecureStorageService();

  Future<ApiResponse<Map<String, dynamic>>> login(String identifier, {String? password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {
        'identifier': identifier,
        'password': password ?? '',
      },
    );

    if (response.isSuccess && response.data != null) {
      final tokens = response.data!['tokens'];
      if (tokens != null) {
        await _storage.saveTokens(
          accessToken: tokens['access'] ?? '',
          refreshToken: tokens['refresh'] ?? '',
        );
      }
      if (response.data!['user'] != null && response.data!['user']['email'] != null) {
        await _storage.saveUserEmail(response.data!['user']['email']);
      }
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    String? fullName,
    String? mobileNumber,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      body: {
        'email': email,
        'password': password,
        'full_name': fullName ?? '',
        'mobile_number': mobileNumber ?? '',
      },
    );

    if (response.isSuccess && response.data != null) {
      final tokens = response.data!['tokens'];
      if (tokens != null) {
        await _storage.saveTokens(
          accessToken: tokens['access'] ?? '',
          refreshToken: tokens['refresh'] ?? '',
        );
      }
    }

    return response;
  }

  Future<ApiResponse<OrganizationModel>> discoverSSO(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.ssoDiscover,
      body: {'email': email},
    );

    if (response.isSuccess && response.data != null) {
      final orgData = response.data!['organization'] as Map<String, dynamic>;
      final authUrl = response.data!['authorization_url'] as String?;
      final state = response.data!['state'] as String?;

      final org = OrganizationModel.fromJson(orgData, authorizationUrl: authUrl, state: state);
      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        data: org,
      );
    }

    return ApiResponse(
      isSuccess: false,
      statusCode: response.statusCode,
      errorMessage: response.errorMessage ?? 'Unable to find organization for this email domain.',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> callbackSSO({
    required String code,
    required String state,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.ssoCallback,
      body: {
        'code': code,
        'state': state,
      },
    );

    if (response.isSuccess && response.data != null) {
      final tokens = response.data!['tokens'];
      if (tokens != null) {
        await _storage.saveTokens(
          accessToken: tokens['access'] ?? '',
          refreshToken: tokens['refresh'] ?? '',
        );
      }
      if (response.data!['user'] != null && response.data!['user']['email'] != null) {
        await _storage.saveUserEmail(response.data!['user']['email']);
      }
    }

    return response;
  }

  Future<ApiResponse<UserModel>> updateProfile({
    required String fullName,
    String? mobileNumber,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.profile,
      body: {
        'full_name': fullName,
        'mobile_number': mobileNumber ?? '',
        'avatar_url': avatarUrl,
      },
      requireAuth: true,
    );

    if (response.isSuccess && response.data != null && response.data!['user'] != null) {
      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        data: UserModel.fromJson(response.data!['user']),
      );
    }

    return ApiResponse(
      isSuccess: false,
      statusCode: response.statusCode,
      errorMessage: response.errorMessage ?? 'Failed to update profile',
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me, requireAuth: true);

    if (response.isSuccess && response.data != null && response.data!['user'] != null) {
      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        data: UserModel.fromJson(response.data!['user']),
      );
    }

    return ApiResponse(
      isSuccess: false,
      statusCode: response.statusCode,
      errorMessage: response.errorMessage ?? 'Failed to fetch user profile',
    );
  }

  Future<void> logout() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      await _apiClient.post(
        ApiEndpoints.logout,
        body: {'refresh': refresh},
        requireAuth: true,
      );
    }
    await _storage.clearAll();
  }

  // Mock IdP simulation calls for end-to-end testing
  Future<ApiResponse<Map<String, dynamic>>> mockIdpAuthorize({
    required String email,
    required String password,
    required String state,
    bool simulateMfa = true,
  }) async {
    return await _apiClient.post(
      ApiEndpoints.mockIdpAuthorize,
      body: {
        'email': email,
        'password': password,
        'state': state,
        'simulate_mfa': simulateMfa,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> mockIdpVerifyMfa({
    required String otp,
    required String state,
    required String email,
  }) async {
    return await _apiClient.post(
      ApiEndpoints.mockIdpVerifyMfa,
      body: {
        'otp': otp,
        'state': state,
        'email': email,
      },
    );
  }
}
