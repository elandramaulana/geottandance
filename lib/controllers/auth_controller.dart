// controllers/auth_controller.dart

import 'package:geottandance/models/user_session.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../core/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  // Observable variables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final currentSession = Rx<UserSession?>(null);

  // Injected service
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    _initializeAuth();
  }

  // ========== INITIALIZATION ==========

  Future<void> _initializeAuth() async {
    try {
      await _checkLoginStatus();

      // Auto navigation listener
      ever(isLoggedIn, (bool loggedIn) {
        if (loggedIn && Get.currentRoute == '/login') {
          Get.offAllNamed(AppRoutes.bottomNav);
        }
      });
    } catch (e) {
      // Silent error handling
    }
  }

  // ========== AUTHENTICATION METHODS ==========

  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoadingState(true);
      _clearMessages();

      // Input validation
      if (email.trim().isEmpty || password.isEmpty) {
        errorMessage.value = 'Email dan password wajib diisi';
        return false;
      }

      if (!GetUtils.isEmail(email.trim())) {
        errorMessage.value = 'Format email tidak valid';
        return false;
      }

      final response = await _authService.login(
        email: email.trim(),
        password: password,
      );

      if (response.success && response.data != null) {
        isLoggedIn.value = true;
        successMessage.value = response.message;
        await _refreshSessionData();
        return true;
      } else {
        errorMessage.value = response.message.isEmpty
            ? 'Login gagal. Silakan coba lagi.'
            : response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat login';
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  Future<bool> logout() async {
    try {
      _setLoadingState(true);

      final response = await _authService.logout();

      if (response.success) {
        _clearUserData();
        successMessage.value = 'Berhasil logout';
        return true;
      } else {
        errorMessage.value = response.message.isEmpty
            ? 'Gagal logout. Silakan coba lagi.'
            : response.message;
        return false;
      }
    } catch (e) {
      // Force logout locally even if API fails
      _clearUserData();
      successMessage.value = 'Logout berhasil';
      return true;
    } finally {
      _setLoadingState(false);
    }
  }

  // ========== SESSION METHODS ==========

  Future<void> _checkLoginStatus() async {
    try {
      final loggedIn = await _authService.isLoggedIn();

      if (loggedIn) {
        isLoggedIn.value = true;
        await _refreshSessionData();
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      isLoggedIn.value = false;
    }
  }

  Future<void> _refreshSessionData() async {
    try {
      currentSession.value = await _authService.getCurrentSession();
    } catch (e) {
      // Silent error handling
    }
  }

  Future<bool> validateSession() async {
    try {
      final isValid = await _authService.validateSession();

      if (!isValid && isLoggedIn.value) {
        _clearUserData();
      } else if (isValid && !isLoggedIn.value) {
        isLoggedIn.value = true;
        await _refreshSessionData();
      }

      return isValid;
    } catch (e) {
      return false;
    }
  }

  // ========== UTILITY METHODS ==========

  void _setLoadingState(bool loading) => isLoading.value = loading;

  void _clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  void _clearUserData() {
    isLoggedIn.value = false;
    currentSession.value = null;
    _clearMessages();
  }

  // Public methods
  void clearMessages() => _clearMessages();

  Future<void> refreshSession() async {
    await _checkLoginStatus();
  }

  Future<void> forceLogout() async {
    try {
      await _authService.clearAuthData();
      _clearUserData();
      successMessage.value = 'Sesi telah berakhir';
    } catch (e) {
      // Silent error handling
    }
  }

  // ========== GETTERS ==========

  int? get currentUserId => currentSession.value?.userId;
  String? get currentUserRole => currentSession.value?.role;
  String? get currentToken => currentSession.value?.token;

  bool hasRole(String role) =>
      currentUserRole?.toLowerCase() == role.toLowerCase();

  bool get isAdmin => hasRole('admin');
  bool get isEmployee => hasRole('employee');
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasSuccessMessage => successMessage.value.isNotEmpty;
}
