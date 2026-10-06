import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/organization_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/secure_storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? currentUser;
  final OrganizationModel? currentOrganization;
  final String? currentSsoState;
  final String? currentSsoEmail;
  final String? errorMessage;
  final bool requiresProfileCompletion;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.currentUser,
    this.currentOrganization,
    this.currentSsoState,
    this.currentSsoEmail,
    this.errorMessage,
    this.requiresProfileCompletion = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? currentUser,
    OrganizationModel? currentOrganization,
    String? currentSsoState,
    String? currentSsoEmail,
    String? errorMessage,
    bool? requiresProfileCompletion,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      currentOrganization: currentOrganization ?? this.currentOrganization,
      currentSsoState: currentSsoState ?? this.currentSsoState,
      currentSsoEmail: currentSsoEmail ?? this.currentSsoEmail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requiresProfileCompletion:
          requiresProfileCompletion ?? this.requiresProfileCompletion,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Restores a previous email/mobile sign-in from the securely stored session.
  Future<bool> restoreSession() async {
    final storage = SecureStorageService();
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      return false;
    }

    final response = await _repository.getProfile();
    if (!response.isSuccess || response.data == null) {
      state = const AuthState();
      return false;
    }

    final user = response.data!;
    state = state.copyWith(
      isAuthenticated: true,
      currentUser: user,
      requiresProfileCompletion: !user.isProfileCompleted,
    );
    return true;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setSsoEmail(String email) {
    state = state.copyWith(currentSsoEmail: email);
  }

  Future<bool> loginWithIdentifier(
    String identifier, {
    String password = '',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository
          .login(identifier, password: password)
          .timeout(const Duration(seconds: 25));

      if (response.isSuccess && response.data != null) {
        final userData = response.data!['user'];
        final user = userData != null ? UserModel.fromJson(userData) : null;
        final reqProfile =
            response.data!['requires_profile_completion'] as bool? ?? false;

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
          requiresProfileCompletion: reqProfile,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            response.errorMessage ??
            'Unable to sign in. Please verify your details.',
      );
      return false;
    } on TimeoutException {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'The server is taking too long to respond. Please try again.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Could not connect to the sign-in service. Please try again.',
      );
      return false;
    }
  }

  Future<bool> discoverSSO(String email) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentSsoEmail: email,
    );
    final response = await _repository.discoverSSO(email);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        currentOrganization: response.data,
        currentSsoState: response.data!.state,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            response.errorMessage ??
            'We couldn’t find an organization for this email.',
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> submitIdpCredentials(
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ssoState = state.currentSsoState ?? 'athirai_state_default';

    final response = await _repository.mockIdpAuthorize(
      email: email,
      password: password,
      state: ssoState,
      simulateMfa: true,
    );

    state = state.copyWith(isLoading: false);
    if (response.isSuccess && response.data != null) {
      return response.data;
    } else {
      state = state.copyWith(
        errorMessage: response.errorMessage ?? 'Invalid corporate credentials.',
      );
      return null;
    }
  }

  Future<String?> verifyMfaCode(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ssoState = state.currentSsoState ?? 'athirai_state_default';
    final email = state.currentSsoEmail ?? '';

    final response = await _repository.mockIdpVerifyMfa(
      otp: otp,
      state: ssoState,
      email: email,
    );

    state = state.copyWith(isLoading: false);
    if (response.isSuccess && response.data != null) {
      return response.data!['code'] as String?;
    } else {
      state = state.copyWith(
        errorMessage:
            response.errorMessage ??
            'Invalid verification code. Please try again.',
      );
      return null;
    }
  }

  Future<bool> completeSsoCallback(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ssoState = state.currentSsoState ?? 'athirai_state_default';

    final response = await _repository.callbackSSO(code: code, state: ssoState);

    if (response.isSuccess && response.data != null) {
      final userData = response.data!['user'];
      final user = userData != null ? UserModel.fromJson(userData) : null;
      final reqProfile =
          response.data!['requires_profile_completion'] as bool? ?? false;

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: user,
        requiresProfileCompletion: reqProfile,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            response.errorMessage ?? 'Failed to finalize SSO authentication.',
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? mobileNumber,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.updateProfile(
      fullName: fullName,
      mobileNumber: mobileNumber,
      avatarUrl: avatarUrl,
    );

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        currentUser: response.data,
        requiresProfileCompletion: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.errorMessage ?? 'Failed to update profile.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
