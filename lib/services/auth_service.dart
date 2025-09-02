// services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:geottandance/core/app_config.dart';
import '../core/base_provider.dart';
import '../services/storage_service.dart';
import '../models/auth_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final BaseApiProvider _apiProvider = BaseApiProvider();
  final StorageService _storageService = StorageService();

  // ========== LOGIN METHODS ==========

  /// Login user dengan email dan password
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      if (kDebugMode) {
        print('🔐 AuthService: Attempting login for: $email');
      }

      final response = await _apiProvider.post<Map<String, dynamic>>(
        Endpoints.login,
        data: loginRequest.toJson(),
      );

      if (response.success && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);

        // Simpan session ke secure storage
        final sessionSaved = await _storageService.saveLoginSession(
          token: loginResponse.token,
          userId: loginResponse.userId,
          role: loginResponse.role,
        );

        if (sessionSaved) {
          if (kDebugMode) {
            print('✅ AuthService: Login successful and session saved');
            print('📝 AuthService: User ID: ${loginResponse.userId}');
            print('📝 AuthService: Role: ${loginResponse.role}');
          }

          return ApiResponse<LoginResponse>(
            success: true,
            message: response.message,
            data: loginResponse,
            statusCode: response.statusCode,
          );
        } else {
          if (kDebugMode) {
            print('❌ AuthService: Login successful but failed to save session');
          }

          return ApiResponse<LoginResponse>(
            success: false,
            message: 'Failed to save login session',
            data: null,
            statusCode: 500,
          );
        }
      }

      if (kDebugMode) {
        print('❌ AuthService: Login failed - ${response.message}');
      }

      return ApiResponse<LoginResponse>(
        success: false,
        message: response.message,
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Login error: $e');
      }

      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Login failed: ${e.toString()}',
        data: null,
        statusCode: null,
      );
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      if (kDebugMode) {
        print('🔓 AuthService: Attempting logout');
      }

      // Panggil logout endpoint ke server
      final response = await _apiProvider.post<void>(Endpoints.logout);

      // Hapus session dari storage terlepas dari response server
      final sessionCleared = await _storageService.clearSession();

      if (sessionCleared) {
        if (kDebugMode) {
          print('✅ AuthService: Logout successful and session cleared');
        }

        return ApiResponse<void>(
          success: true,
          message: 'Logout successful',
          data: null,
          statusCode: response.statusCode,
        );
      } else {
        if (kDebugMode) {
          print('⚠️ AuthService: Logout completed but failed to clear session');
        }

        return ApiResponse<void>(
          success: false,
          message: 'Failed to clear session',
          data: null,
          statusCode: 500,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Logout error: $e');
      }

      // Tetap hapus session lokal meskipun API error
      final sessionCleared = await _storageService.clearSession();

      if (sessionCleared) {
        if (kDebugMode) {
          print('✅ AuthService: Session cleared locally despite API error');
        }
      }

      return ApiResponse<void>(
        success: true,
        message: 'Logged out locally',
        data: null,
        statusCode: null,
      );
    }
  }

  // ========== SESSION METHODS ==========

  /// Check apakah user sudah login
  Future<bool> isLoggedIn() async {
    try {
      final loggedIn = await _storageService.isLoggedIn();

      if (kDebugMode) {
        print('ℹ️ AuthService: Login status check - $loggedIn');
      }

      return loggedIn;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error checking login status: $e');
      }
      return false;
    }
  }

  /// Get current user session
  Future<UserSession?> getCurrentSession() async {
    try {
      final session = await _storageService.getUserSession();

      if (kDebugMode) {
        if (session != null) {
          print(
            '✅ AuthService: Current session retrieved - User ID: ${session.userId}, Role: ${session.role}',
          );
        } else {
          print('ℹ️ AuthService: No active session found');
        }
      }

      return session;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error getting current session: $e');
      }
      return null;
    }
  }

  /// Get current auth token
  Future<String?> getCurrentToken() async {
    try {
      final token = await _storageService.getToken();

      if (kDebugMode) {
        if (token != null && token.isNotEmpty) {
          print(
            '✅ AuthService: Token retrieved - ${token.substring(0, 10)}...',
          );
        } else {
          print('ℹ️ AuthService: No token found');
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error getting token: $e');
      }
      return null;
    }
  }

  /// Get current user ID
  Future<int?> getCurrentUserId() async {
    try {
      final userId = await _storageService.getUserId();

      if (kDebugMode) {
        if (userId != null) {
          print('✅ AuthService: User ID retrieved - $userId');
        } else {
          print('ℹ️ AuthService: No user ID found');
        }
      }

      return userId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error getting user ID: $e');
      }
      return null;
    }
  }

  /// Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final role = await _storageService.getUserRole();

      if (kDebugMode) {
        if (role != null) {
          print('✅ AuthService: User role retrieved - $role');
        } else {
          print('ℹ️ AuthService: No user role found');
        }
      }

      return role;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error getting user role: $e');
      }
      return null;
    }
  }

  // ========== PROFILE METHODS ==========

  /// Get user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      if (kDebugMode) {
        print('👤 AuthService: Getting user profile');
      }

      final response = await _apiProvider.get<Map<String, dynamic>>(
        Endpoints.profile,
      );

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!);

        if (kDebugMode) {
          print('✅ AuthService: Profile retrieved successfully');
          print('📝 AuthService: User - ${user.name} (${user.email})');
        }

        return ApiResponse<User>(
          success: true,
          message: response.message,
          data: user,
          statusCode: response.statusCode,
        );
      }

      if (kDebugMode) {
        print('❌ AuthService: Failed to get profile - ${response.message}');
      }

      return ApiResponse<User>(
        success: false,
        message: response.message,
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Get profile error: $e');
      }

      return ApiResponse<User>(
        success: false,
        message: 'Failed to get profile: ${e.toString()}',
        data: null,
        statusCode: null,
      );
    }
  }

  // ========== UTILITY METHODS ==========

  /// Clear all authentication data
  Future<bool> clearAuthData() async {
    try {
      final cleared = await _storageService.clearSession();

      if (kDebugMode) {
        if (cleared) {
          print('✅ AuthService: All auth data cleared');
        } else {
          print('❌ AuthService: Failed to clear auth data');
        }
      }

      return cleared;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error clearing auth data: $e');
      }
      return false;
    }
  }

  /// Check if token is valid (basic check)
  Future<bool> isTokenValid() async {
    try {
      final token = await getCurrentToken();
      final isValid = token != null && token.isNotEmpty;

      if (kDebugMode) {
        print('ℹ️ AuthService: Token validity check - $isValid');
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error checking token validity: $e');
      }
      return false;
    }
  }

  /// Validate current session
  Future<bool> validateSession() async {
    try {
      final session = await getCurrentSession();
      final isValid =
          session != null && session.isLoggedIn && session.token.isNotEmpty;

      if (kDebugMode) {
        print('ℹ️ AuthService: Session validation - $isValid');
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Error validating session: $e');
      }
      return false;
    }
  }
}
