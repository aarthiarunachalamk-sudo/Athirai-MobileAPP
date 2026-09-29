import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/data/services/secure_storage_service.dart';
import 'api_endpoints.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final int statusCode;
  final T? data;
  final String? errorMessage;

  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.errorMessage,
  });
}

class ApiClient {
  final SecureStorageService _storage;
  final http.Client _client;

  ApiClient({SecureStorageService? storage, http.Client? client})
      : _storage = storage ?? SecureStorageService(),
        _client = client ?? http.Client();

  Map<String, String> _defaultHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(String url, {bool requireAuth = true}) async {
    try {
      String? token;
      if (requireAuth) {
        token = await _storage.getAccessToken();
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: _defaultHeaders(token),
      );

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          token = await _storage.getAccessToken();
          final retryResponse = await _client.get(
            Uri.parse(url),
            headers: _defaultHeaders(token),
          );
          return _handleResponse(retryResponse);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Network error. Please check your connection.',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      String? token;
      if (requireAuth) {
        token = await _storage.getAccessToken();
      }

      final response = await _client.post(
        Uri.parse(url),
        headers: _defaultHeaders(token),
        body: jsonEncode(body ?? {}),
      );

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          token = await _storage.getAccessToken();
          final retryResponse = await _client.post(
            Uri.parse(url),
            headers: _defaultHeaders(token),
            body: jsonEncode(body ?? {}),
          );
          return _handleResponse(retryResponse);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Network error. Please check your connection.',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      String? token;
      if (requireAuth) {
        token = await _storage.getAccessToken();
      }

      final response = await _client.put(
        Uri.parse(url),
        headers: _defaultHeaders(token),
        body: jsonEncode(body ?? {}),
      );

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          token = await _storage.getAccessToken();
          final retryResponse = await _client.put(
            Uri.parse(url),
            headers: _defaultHeaders(token),
            body: jsonEncode(body ?? {}),
          );
          return _handleResponse(retryResponse);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Network error. Please check your connection.',
      );
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _client.post(
        Uri.parse(ApiEndpoints.tokenRefresh),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'] as String?;
        if (newAccess != null) {
          await _storage.saveAccessToken(newAccess);
          final newRefresh = data['refresh'] as String?;
          if (newRefresh != null) {
            await _storage.saveRefreshToken(newRefresh);
          }
          return true;
        }
      }
    } catch (_) {}
    await _storage.clearAll();
    return false;
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      final errorMessage = !isSuccess ? (body['message'] ?? body['detail'] ?? 'An error occurred') : null;

      return ApiResponse(
        isSuccess: isSuccess,
        statusCode: response.statusCode,
        data: body,
        errorMessage: errorMessage?.toString(),
      );
    } catch (_) {
      return ApiResponse(
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        errorMessage: 'Invalid server response',
      );
    }
  }
}
