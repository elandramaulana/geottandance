// controllers/profile_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geottandance/services/profile_service.dart';
import 'package:geottandance/models/profile_model.dart';

enum ProfileState { initial, loading, loaded, error, refreshing }

class ProfileController extends GetxController {
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();

  final ProfileService _profileService = ProfileService();

  // Reactive variables
  final Rx<ProfileState> _state = ProfileState.initial.obs;
  final Rx<ProfileModel?> _profile = Rx<ProfileModel?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isInitialized = false.obs;

  // Getters
  ProfileState get state => _state.value;
  ProfileModel? get profile => _profile.value;
  String get errorMessage => _errorMessage.value;
  bool get isInitialized => _isInitialized.value;
  bool get isLoading => _state.value == ProfileState.loading;
  bool get isRefreshing => _state.value == ProfileState.refreshing;
  bool get hasError => _state.value == ProfileState.error;
  bool get hasProfile => _profile.value != null;

  // Profile data getters (safe access)
  String get userName => _profile.value?.name ?? 'Unknown';
  String get userEmployeeId => _profile.value?.employeeId ?? '';
  String get userPosition => _profile.value?.position ?? '';
  String get userDepartment => _profile.value?.department ?? '';
  String get userRole => _profile.value?.roleName ?? '';
  String get userPhone => _profile.value?.phone ?? '';
  String? get userAvatar => _profile.value?.avatar;
  String get userInitials => _profile.value?.initials ?? '??';
  String? get avatarUrl => _profileService.getAvatarUrl();

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🎯 ProfileController: Initialized');
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode) {
      print('🎯 ProfileController: Ready');
    }
  }

  // ========== MAIN METHODS ==========

  /// Initialize controller - load profile data
  Future<void> initialize() async {
    if (_isInitialized.value && _profile.value != null) {
      return; // Sudah di-initialize dan ada data
    }

    await loadProfile(showLoading: !_isInitialized.value);
    _isInitialized.value = true;
  }

  /// Load profile data
  Future<void> loadProfile({bool showLoading = true}) async {
    if (showLoading) {
      _setState(ProfileState.loading);
    }

    try {
      // Cek cached data terlebih dahulu jika tidak showLoading
      if (!showLoading) {
        final cachedProfile = _profileService.getCachedProfile();
        if (cachedProfile != null) {
          _profile.value = cachedProfile;
          _setState(ProfileState.loaded);
          return;
        }
      }

      final response = await _profileService.getProfile();

      if (response.success && response.data != null) {
        _profile.value = response.data;
        _errorMessage.value = '';
        _setState(ProfileState.loaded);

        if (kDebugMode) {
          print('✅ Profile loaded: ${_profile.value!.name}');
        }
      } else {
        _errorMessage.value = response.message;
        _setState(ProfileState.error);

        if (kDebugMode) {
          print('❌ Failed to load profile: ${response.message}');
        }
      }
    } catch (e) {
      _errorMessage.value = 'Failed to load profile: ${e.toString()}';
      _setState(ProfileState.error);

      if (kDebugMode) {
        print('❌ Error loading profile: $e');
      }
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    if (_state.value == ProfileState.refreshing) {
      return; // Sudah dalam proses refresh
    }

    _setState(ProfileState.refreshing);

    try {
      final response = await _profileService.refreshProfile();

      if (response.success && response.data != null) {
        _profile.value = response.data;
        _errorMessage.value = '';
        _setState(ProfileState.loaded);

        if (kDebugMode) {
          print('✅ Profile refreshed: ${_profile.value!.name}');
        }
      } else {
        _errorMessage.value = response.message;
        // Jika refresh gagal tapi masih ada data lama, tetap di state loaded
        _setState(
          _profile.value != null ? ProfileState.loaded : ProfileState.error,
        );

        if (kDebugMode) {
          print('❌ Failed to refresh profile: ${response.message}');
        }
      }
    } catch (e) {
      _errorMessage.value = 'Failed to refresh profile: ${e.toString()}';
      // Jika refresh gagal tapi masih ada data lama, tetap di state loaded
      _setState(
        _profile.value != null ? ProfileState.loaded : ProfileState.error,
      );

      if (kDebugMode) {
        print('❌ Error refreshing profile: $e');
      }
    }
  }

  /// Load profile by ID (untuk admin/manager)
  Future<ProfileModel?> loadProfileById(int userId) async {
    try {
      final response = await _profileService.getProfileById(userId);

      if (response.success && response.data != null) {
        if (kDebugMode) {
          print('✅ Profile loaded for user ID $userId: ${response.data!.name}');
        }
        return response.data;
      } else {
        if (kDebugMode) {
          print(
            '❌ Failed to load profile for user ID $userId: ${response.message}',
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading profile for user ID $userId: $e');
      }
      return null;
    }
  }

  // ========== UTILITY METHODS ==========

  /// Check if profile is valid and complete
  bool isProfileComplete() {
    if (_profile.value == null) return false;

    return _profile.value!.name.isNotEmpty &&
        _profile.value!.employeeId.isNotEmpty &&
        _profile.value!.position.isNotEmpty &&
        _profile.value!.department.isNotEmpty;
  }

  /// Get profile completion percentage
  double getProfileCompletionPercentage() {
    if (_profile.value == null) return 0.0;

    int completedFields = 0;
    int totalFields = 8; // Total field yang bisa diisi

    // Required fields
    if (_profile.value!.name.isNotEmpty) completedFields++;
    if (_profile.value!.phone.isNotEmpty) completedFields++;
    if (_profile.value!.position.isNotEmpty) completedFields++;
    if (_profile.value!.department.isNotEmpty) completedFields++;

    // Optional fields
    if (_profile.value!.birthDate != null &&
        _profile.value!.birthDate!.isNotEmpty) {
      completedFields++;
    }
    if (_profile.value!.gender != null && _profile.value!.gender!.isNotEmpty) {
      completedFields++;
    }
    if (_profile.value!.address != null &&
        _profile.value!.address!.isNotEmpty) {
      completedFields++;
    }
    if (_profile.value!.avatar != null && _profile.value!.avatar!.isNotEmpty) {
      completedFields++;
    }

    return (completedFields / totalFields) * 100;
  }

  /// Get missing profile fields
  List<String> getMissingFields() {
    if (_profile.value == null) return ['Profile data'];

    List<String> missing = [];

    if (_profile.value!.birthDate == null ||
        _profile.value!.birthDate!.isEmpty) {
      missing.add('Birth Date');
    }
    if (_profile.value!.gender == null || _profile.value!.gender!.isEmpty) {
      missing.add('Gender');
    }
    if (_profile.value!.address == null || _profile.value!.address!.isEmpty) {
      missing.add('Address');
    }
    if (_profile.value!.avatar == null || _profile.value!.avatar!.isEmpty) {
      missing.add('Profile Picture');
    }

    return missing;
  }

  /// Check user permissions
  bool canViewOtherProfiles() {
    return _profile.value?.roleName.toLowerCase() == 'admin' ||
        _profile.value?.roleName.toLowerCase() == 'manager';
  }

  bool isEmployee() => _profile.value?.roleName.toLowerCase() == 'employee';
  bool isManager() => _profile.value?.roleName.toLowerCase() == 'manager';
  bool isAdmin() => _profile.value?.roleName.toLowerCase() == 'admin';

  /// Get formatted employment info
  String getEmploymentStatusText() {
    if (_profile.value == null) return '';

    String status = _profile.value!.employmentStatus;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String getFormattedHireDate() {
    if (_profile.value == null || _profile.value!.hireDate.isEmpty) return '';

    try {
      DateTime date = DateTime.parse(_profile.value!.hireDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return _profile.value!.hireDate;
    }
  }

  // ========== CACHE & CLEANUP METHODS ==========

  /// Clear all profile data
  Future<void> clearProfile() async {
    _profile.value = null;
    _errorMessage.value = '';
    _isInitialized.value = false;
    _setState(ProfileState.initial);

    await _profileService.clearAllProfileData();

    if (kDebugMode) {
      print('🗑️ Profile controller cleared');
    }
  }

  /// Force reload profile (bypass cache)
  Future<void> forceReload() async {
    _profileService.clearCache();
    await loadProfile();
  }

  /// Get basic profile from storage (offline)
  Future<Map<String, String?>> getBasicProfileFromStorage() async {
    return await _profileService.getBasicProfileFromStorage();
  }

  // ========== PRIVATE METHODS ==========

  void _setState(ProfileState newState) {
    if (_state.value != newState) {
      _state.value = newState;
      update(); // Trigger GetBuilder update

      if (kDebugMode) {
        print('📱 Profile state changed to: ${newState.name}');
      }
    }
  }

  // ========== DISPOSE ==========

  @override
  void onClose() {
    super.onClose();
    if (kDebugMode) {
      print('🗑️ Profile controller disposed');
    }
  }
}
