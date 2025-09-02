// services/profile_service.dart
import 'package:flutter/foundation.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/services/storage_service.dart';
import 'package:geottandance/models/profile_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final BaseApiProvider _apiProvider = BaseApiProvider();
  final StorageService _storageService = StorageService();

  // Cache untuk profile data
  ProfileModel? _cachedProfile;
  DateTime? _lastFetchTime;

  // Cache duration (5 menit)
  static const Duration _cacheDuration = Duration(minutes: 5);

  // API endpoints
  static const String _profileEndpoint = '/user/profile';

  // ========== GET PROFILE METHODS ==========

  /// Mengambil data profile user yang sedang login
  Future<ApiResponse<ProfileModel>> getProfile({
    bool forceRefresh = false,
  }) async {
    try {
      // Periksa cache jika tidak force refresh
      if (!forceRefresh && _isProfileCacheValid()) {
        if (kDebugMode) {
          print('📋 Using cached profile data');
        }
        return ApiResponse<ProfileModel>(
          success: true,
          message: 'Profile data retrieved from cache',
          data: _cachedProfile,
          statusCode: 200,
        );
      }

      if (kDebugMode) {
        print('📡 Fetching profile data from server...');
      }

      // Ambil data dari API
      final response = await _apiProvider.get<Map<String, dynamic>>(
        _profileEndpoint,
      );

      if (response.success && response.data != null) {
        final profileData = response.data!;
        final profile = ProfileModel.fromJson(profileData);

        // Cache profile data
        _cachedProfile = profile;
        _lastFetchTime = DateTime.now();

        // Simpan beberapa data penting ke storage
        await _saveProfileToStorage(profile);

        if (kDebugMode) {
          print('✅ Profile data retrieved successfully');
          print('👤 User: ${profile.name} (${profile.employeeId})');
        }

        return ApiResponse<ProfileModel>(
          success: true,
          message: response.message,
          data: profile,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<ProfileModel>(
        success: false,
        message: response.message,
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getProfile: $e');
      }

      // Coba ambil dari cache jika ada error
      if (_cachedProfile != null) {
        return ApiResponse<ProfileModel>(
          success: true,
          message: 'Profile data retrieved from cache (offline)',
          data: _cachedProfile,
          statusCode: 200,
        );
      }

      return ApiResponse<ProfileModel>(
        success: false,
        message: 'Failed to get profile data: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Mengambil profile dengan user ID tertentu (untuk admin atau manager)
  Future<ApiResponse<ProfileModel>> getProfileById(int userId) async {
    try {
      if (kDebugMode) {
        print('📡 Fetching profile data for user ID: $userId');
      }

      final response = await _apiProvider.get<Map<String, dynamic>>(
        '$_profileEndpoint/$userId',
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);

        if (kDebugMode) {
          print('✅ Profile data retrieved for user: ${profile.name}');
        }

        return ApiResponse<ProfileModel>(
          success: true,
          message: response.message,
          data: profile,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<ProfileModel>(
        success: false,
        message: response.message,
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getProfileById: $e');
      }

      return ApiResponse<ProfileModel>(
        success: false,
        message: 'Failed to get profile data: ${e.toString()}',
        data: null,
      );
    }
  }

  // ========== CACHE MANAGEMENT ==========

  /// Periksa apakah cache profile masih valid
  bool _isProfileCacheValid() {
    if (_cachedProfile == null || _lastFetchTime == null) {
      return false;
    }

    final now = DateTime.now();
    final timeDifference = now.difference(_lastFetchTime!);

    return timeDifference <= _cacheDuration;
  }

  /// Clear cache profile
  void clearCache() {
    _cachedProfile = null;
    _lastFetchTime = null;

    if (kDebugMode) {
      print('🗑️ Profile cache cleared');
    }
  }

  /// Get cached profile jika ada
  ProfileModel? getCachedProfile() {
    if (_isProfileCacheValid()) {
      return _cachedProfile;
    }
    return null;
  }

  // ========== STORAGE METHODS ==========

  /// Simpan data profile penting ke storage
  Future<void> _saveProfileToStorage(ProfileModel profile) async {
    try {
      await Future.wait([
        _storageService.saveString('profile_name', profile.name),
        _storageService.saveString('profile_employee_id', profile.employeeId),
        _storageService.saveString('profile_position', profile.position),
        _storageService.saveString('profile_department', profile.department),
        _storageService.saveString('profile_role', profile.roleName),
        if (profile.avatar != null)
          _storageService.saveString('profile_avatar', profile.avatar!),
      ]);

      if (kDebugMode) {
        print('💾 Profile data saved to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving profile to storage: $e');
      }
    }
  }

  /// Ambil data profile basic dari storage (untuk offline)
  Future<Map<String, String?>> getBasicProfileFromStorage() async {
    try {
      final results = await Future.wait([
        _storageService.getString('profile_name'),
        _storageService.getString('profile_employee_id'),
        _storageService.getString('profile_position'),
        _storageService.getString('profile_department'),
        _storageService.getString('profile_role'),
        _storageService.getString('profile_avatar'),
      ]);

      return {
        'name': results[0],
        'employee_id': results[1],
        'position': results[2],
        'department': results[3],
        'role': results[4],
        'avatar': results[5],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting profile from storage: $e');
      }
      return {};
    }
  }

  /// Clear profile data dari storage
  Future<void> clearProfileFromStorage() async {
    try {
      await Future.wait([
        _storageService.remove('profile_name'),
        _storageService.remove('profile_employee_id'),
        _storageService.remove('profile_position'),
        _storageService.remove('profile_department'),
        _storageService.remove('profile_role'),
        _storageService.remove('profile_avatar'),
      ]);

      if (kDebugMode) {
        print('🗑️ Profile data cleared from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing profile from storage: $e');
      }
    }
  }

  // ========== UTILITY METHODS ==========

  /// Refresh profile data (force refresh)
  Future<ApiResponse<ProfileModel>> refreshProfile() async {
    return await getProfile(forceRefresh: true);
  }

  /// Check if user has valid profile data
  Future<bool> hasValidProfile() async {
    try {
      final response = await getProfile();
      return response.success && response.data != null;
    } catch (e) {
      return false;
    }
  }

  /// Get profile avatar URL or return null
  String? getAvatarUrl() {
    final profile = getCachedProfile();
    if (profile?.avatar != null && profile!.avatar!.isNotEmpty) {
      // Jika avatar sudah berupa URL lengkap, return as is
      if (profile.avatar!.startsWith('http')) {
        return profile.avatar;
      }
      // Jika hanya filename, gabung dengan base URL
      return '${BaseApiProvider.baseUrl}/storage/avatars/${profile.avatar}';
    }
    return null;
  }

  /// Get user initials for avatar placeholder
  String getUserInitials() {
    final profile = getCachedProfile();
    return profile?.initials ?? '??';
  }

  /// Clear all profile data (cache + storage)
  Future<void> clearAllProfileData() async {
    clearCache();
    await clearProfileFromStorage();

    if (kDebugMode) {
      print('🗑️ All profile data cleared');
    }
  }
}
