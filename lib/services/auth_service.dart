// services/auth_service.dart

import 'package:geottandance/core/app_config.dart';
import 'package:geottandance/models/user_session.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import '../core/base_provider.dart';
import '../services/storage_service.dart';
import '../models/auth_models.dart';

class AuthService extends GetxService {
  final BaseApiProvider _apiProvider = BaseApiProvider();
  final StorageService _storageService = StorageService();

  // ========== LOGIN METHODS ==========

  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _apiProvider.post<Map<String, dynamic>>(
        Endpoints.login,
        data: loginRequest.toJson(),
      );

      if (response.success && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);

        final sessionSaved = await _storageService.saveLoginSession(
          token: loginResponse.token,
          userId: loginResponse.userId,
          role: loginResponse.role,
        );

        if (sessionSaved) {
          return ApiResponse<LoginResponse>(
            success: true,
            message: response.message,
            data: loginResponse,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<LoginResponse>(
            success: false,
            message: 'Failed to save login session',
            data: null,
            statusCode: 500,
          );
        }
      }

      return ApiResponse<LoginResponse>(
        success: false,
        message: response.message,
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Login failed: ${e.toString()}',
        data: null,
        statusCode: null,
      );
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiProvider.post<void>(Endpoints.logout);
      final sessionCleared = await _storageService.clearSession();

      if (sessionCleared) {
        return ApiResponse<void>(
          success: true,
          message: 'Logout successful',
          data: null,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'Failed to clear session',
          data: null,
          statusCode: 500,
        );
      }
    } catch (e) {
      final sessionCleared = await _storageService.clearSession();
      return ApiResponse<void>(
        success: sessionCleared,
        message: sessionCleared ? 'Logged out locally' : 'Failed to logout',
        data: null,
        statusCode: null,
      );
    }
  }

  // ========== PROFILE METHODS ==========

  /// Get user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _apiProvider.get<Map<String, dynamic>>(
        Endpoints.profile,
      );

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!);

        return ApiResponse<User>(
          success: true,
          message: response.message,
          data: user,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<User>(
        success: false,
        message: response.message,
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Failed to get profile: ${e.toString()}',
        data: null,
        statusCode: null,
      );
    }
  }

  // ========== SESSION METHODS ==========

  Future<bool> isLoggedIn() async {
    try {
      return await _storageService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  Future<UserSession?> getCurrentSession() async {
    try {
      return await _storageService.getUserSession();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCurrentToken() async {
    try {
      return await _storageService.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<int?> getCurrentUserId() async {
    try {
      return await _storageService.getUserId();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCurrentUserRole() async {
    try {
      return await _storageService.getUserRole();
    } catch (e) {
      return null;
    }
  }

  // ========== UTILITY METHODS ==========

  Future<bool> clearAuthData() async {
    try {
      return await _storageService.clearSession();
    } catch (e) {
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final token = await getCurrentToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateSession() async {
    try {
      final session = await getCurrentSession();
      return session != null && session.isLoggedIn && session.token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
