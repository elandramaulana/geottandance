import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';
import '../services/storage_service.dart';
import '../core/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // User data
  final Rx<UserSession?> currentSession = Rx<UserSession?>(null);
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode) {
      print('🎯 AuthController: Ready - Login status: ${isLoggedIn.value}');
    }
  }

  // ========== INITIALIZATION ==========

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      if (kDebugMode) {
        print('🚀 AuthController: Initializing authentication...');
      }

      await _checkLoginStatus();

      // Listen to login status changes for auto-navigation
      ever(isLoggedIn, (bool loggedIn) {
        if (loggedIn && Get.currentRoute == '/login') {
          // Auto navigate to home if we're on login screen and user becomes logged in
          Get.offAllNamed(AppRoutes.bottomNav);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Error during initialization: $e');
      }
    }
  }

  // ========== AUTHENTICATION METHODS ==========

  /// Login method
  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearMessages();

      if (kDebugMode) {
        print('🔐 AuthController: Starting login process for: $email');
      }

      // Validate input
      if (email.trim().isEmpty || password.isEmpty) {
        errorMessage.value = 'Email dan password wajib diisi';
        return false;
      }

      // Validate email format
      if (!GetUtils.isEmail(email.trim())) {
        errorMessage.value = 'Format email tidak valid';
        return false;
      }

      final response = await _authService.login(
        email: email.trim(),
        password: password,
      );

      if (response.success && response.data != null) {
        // Update state
        isLoggedIn.value = true;
        successMessage.value = response.message;

        // Refresh session data
        await _refreshSessionData();

        if (kDebugMode) {
          print('✅ AuthController: Login successful');
          print('📝 AuthController: User ID: ${currentSession.value?.userId}');
          print('📝 AuthController: Role: ${currentSession.value?.role}');
        }

        return true;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Login gagal. Silakan coba lagi.';

        if (kDebugMode) {
          print('❌ AuthController: Login failed - ${response.message}');
        }

        return false;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat login: ${e.toString()}';

      if (kDebugMode) {
        print('❌ AuthController: Login exception - $e');
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout method
  Future<bool> logout() async {
    try {
      _setLoading(true);

      if (kDebugMode) {
        print('🔓 AuthController: Starting logout process');
      }

      final response = await _authService.logout();

      if (response.success) {
        // Clear state
        _clearUserData();
        successMessage.value = 'Berhasil logout';

        if (kDebugMode) {
          print('✅ AuthController: Logout successful');
        }

        return true;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Gagal logout. Silakan coba lagi.';

        if (kDebugMode) {
          print('❌ AuthController: Logout failed - ${response.message}');
        }

        return false;
      }
    } catch (e) {
      // Force logout locally even if API fails
      _clearUserData();
      successMessage.value = 'Logout berhasil secara lokal';

      if (kDebugMode) {
        print('⚠️ AuthController: Logout exception, cleared locally - $e');
      }

      return true; // Return true because we cleared locally
    } finally {
      _setLoading(false);
    }
  }

  // ========== SESSION METHODS ==========

  /// Check login status on app start
  Future<void> _checkLoginStatus() async {
    try {
      if (kDebugMode) {
        print('🔍 AuthController: Checking login status...');
      }

      final loggedIn = await _authService.isLoggedIn();

      if (loggedIn) {
        isLoggedIn.value = true;
        await _refreshSessionData();

        if (kDebugMode) {
          print('✅ AuthController: User is already logged in');
          print('📝 AuthController: Session: ${currentSession.value}');
        }
      } else {
        isLoggedIn.value = false;
        if (kDebugMode) {
          print('ℹ️ AuthController: User is not logged in');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Error checking login status - $e');
      }

      // Default to not logged in if error occurs
      isLoggedIn.value = false;
    }
  }

  /// Refresh session data from storage
  Future<void> _refreshSessionData() async {
    try {
      currentSession.value = await _authService.getCurrentSession();

      // Try to get user profile if session exists
      if (currentSession.value != null) {
        await _getUserProfile();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Error refreshing session data - $e');
      }
    }
  }

  /// Get user profile
  Future<void> _getUserProfile() async {
    try {
      if (kDebugMode) {
        print('👤 AuthController: Getting user profile');
      }

      final response = await _authService.getProfile();

      if (response.success && response.data != null) {
        currentUser.value = response.data;

        if (kDebugMode) {
          print('✅ AuthController: Profile retrieved successfully');
          print('📝 AuthController: User: ${currentUser.value?.name}');
        }
      } else {
        if (kDebugMode) {
          print(
            '⚠️ AuthController: Failed to get profile - ${response.message}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Get profile exception - $e');
      }
    }
  }

  /// Validate current session
  Future<bool> validateSession() async {
    try {
      final isValid = await _authService.validateSession();

      if (!isValid && isLoggedIn.value) {
        // Session is invalid but we think we're logged in
        _clearUserData();

        if (kDebugMode) {
          print(
            '⚠️ AuthController: Invalid session detected, clearing user data',
          );
        }
      } else if (isValid && !isLoggedIn.value) {
        // Session is valid but we think we're not logged in
        isLoggedIn.value = true;
        await _refreshSessionData();

        if (kDebugMode) {
          print('✅ AuthController: Valid session found, updating login status');
        }
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Error validating session - $e');
      }
      return false;
    }
  }

  // ========== UTILITY METHODS ==========

  /// Set loading state
  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  /// Clear all error and success messages
  void _clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Clear all user data
  void _clearUserData() {
    isLoggedIn.value = false;
    currentSession.value = null;
    currentUser.value = null;
    _clearMessages();
  }

  /// Public method to clear messages
  void clearMessages() {
    _clearMessages();
  }

  /// Force refresh session (useful after app resume)
  Future<void> refreshSession() async {
    try {
      if (kDebugMode) {
        print('🔄 AuthController: Refreshing session...');
      }

      await _checkLoginStatus();
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Error refreshing session - $e');
      }
    }
  }

  /// Force logout (clear all data)
  Future<void> forceLogout() async {
    try {
      if (kDebugMode) {
        print('🚪 AuthController: Force logout initiated');
      }

      await _authService.clearAuthData();
      _clearUserData();
      successMessage.value = 'Sesi telah berakhir';

      if (kDebugMode) {
        print('✅ AuthController: Force logout completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthController: Error during force logout - $e');
      }
    }
  }

  // ========== GETTERS ==========

  /// Get current user ID
  int? get currentUserId => currentSession.value?.userId;

  /// Get current user role
  String? get currentUserRole => currentSession.value?.role;

  /// Get current auth token
  String? get currentToken => currentSession.value?.token;

  /// Get current user name
  String? get currentUserName => currentUser.value?.name;

  /// Get current user email
  String? get currentUserEmail => currentUser.value?.email;

  /// Check if user has specific role
  bool hasRole(String role) {
    return currentUserRole?.toLowerCase() == role.toLowerCase();
  }

  /// Check if current user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if current user is employee
  bool get isEmployee => hasRole('employee');

  /// Check if there's an active error
  bool get hasError => errorMessage.value.isNotEmpty;

  /// Check if there's a success message
  bool get hasSuccessMessage => successMessage.value.isNotEmpty;
}
