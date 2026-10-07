import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// Automatically tries candidate URLs (USB reverse, local Wi-Fi, Emulator)
  /// if the active Android URL cannot connect.
  Future<http.Response?> _retryFallback(
    String currentUrl,
    Future<http.Response> Function(String candidateUrl) execute,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    final currentBase = ApiEndpoints.baseUrl;
    for (final candidate in ApiEndpoints.androidCandidates) {
      if (candidate == currentBase) continue;
      try {
        final candidateUrl = currentUrl.startsWith(currentBase)
            ? currentUrl.replaceFirst(currentBase, candidate)
            : currentUrl;
        final res = await execute(candidateUrl).timeout(const Duration(seconds: 4));
        if (res.statusCode > 0) {
          ApiEndpoints.setBaseUrl(candidate);
          return res;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(String url, {bool requireAuth = true}) async {
    try {
      String? token = await _storage.getAccessToken();

      http.Response response;
      try {
        response = await _client.get(
          Uri.parse(url),
          headers: _defaultHeaders(token),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        final fallback = await _retryFallback(
          url,
          (target) => _client.get(Uri.parse(target), headers: _defaultHeaders(token)),
        );
        if (fallback != null) {
          response = fallback;
        } else {
          rethrow;
        }
      }

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
      String? token = await _storage.getAccessToken();

      http.Response response;
      try {
        response = await _client.post(
          Uri.parse(url),
          headers: _defaultHeaders(token),
          body: jsonEncode(body ?? {}),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        final fallback = await _retryFallback(
          url,
          (target) => _client.post(
            Uri.parse(target),
            headers: _defaultHeaders(token),
            body: jsonEncode(body ?? {}),
          ),
        );
        if (fallback != null) {
          response = fallback;
        } else {
          rethrow;
        }
      }

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
      String? token = await _storage.getAccessToken();

      http.Response response;
      try {
        response = await _client.put(
          Uri.parse(url),
          headers: _defaultHeaders(token),
          body: jsonEncode(body ?? {}),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        final fallback = await _retryFallback(
          url,
          (target) => _client.put(
            Uri.parse(target),
            headers: _defaultHeaders(token),
            body: jsonEncode(body ?? {}),
          ),
        );
        if (fallback != null) {
          response = fallback;
        } else {
          rethrow;
        }
      }

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

  Future<ApiResponse<Map<String, dynamic>>> multipartPost(
    String url, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
    bool requireAuth = false,
  }) async {
    try {
      String? token;
      if (requireAuth) {
        token = await _storage.getAccessToken();
      }

      Future<http.Response> sendMultipart(String targetUrl) async {
        final uri = Uri.parse(targetUrl);
        final request = http.MultipartRequest('POST', uri);
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';
        if (fields != null) {
          request.fields.addAll(fields);
        }
        final file = await http.MultipartFile.fromPath(fileField, filePath);
        request.files.add(file);

        final streamed = await _client.send(request).timeout(const Duration(seconds: 15));
        return http.Response.fromStream(streamed);
      }

      http.Response response;
      try {
        response = await sendMultipart(url);
      } catch (_) {
        final fallback = await _retryFallback(url, sendMultipart);
        if (fallback != null) {
          response = fallback;
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          token = await _storage.getAccessToken();
          final retryResponse = await sendMultipart(url);
          return _handleResponse(retryResponse);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Network error while uploading image: $e',
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
    await _storage.clearSession();
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
