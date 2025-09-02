// lib/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:geottandance/models/home_model.dart';
import 'package:geottandance/services/home_service.dart';
import 'package:geottandance/controllers/auth_controller.dart';
import 'package:geottandance/core/base_provider.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();

  // Reactive variables
  final _isLoading = false.obs;
  final _attendanceStatus = Rxn<AttendanceStatusModel>();
  final _recentActivities = <ActivityModel>[].obs;
  final _errorMessage = ''.obs;
  final _isRefreshing = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  AttendanceStatusModel? get attendanceStatus => _attendanceStatus.value;
  List<ActivityModel> get recentActivities => _recentActivities;
  String get errorMessage => _errorMessage.value;

  // Current user info - get from AuthController with fallback
  String? get currentUserName {
    try {
      final authController = Get.find<AuthController>();
      return attendanceStatus?.employeeName ??
          authController.currentUserName ??
          'User';
    } catch (e) {
      return attendanceStatus?.employeeName ?? 'User';
    }
  }

  String? get currentOfficeName => attendanceStatus?.officeName;

  // Today's attendance info - FIXED with proper null checking
  TodayAttendanceModel? get todayAttendance =>
      attendanceStatus?.todayAttendance;

  bool get canClockIn => attendanceStatus?.canClockIn ?? false;
  bool get canClockOut => attendanceStatus?.canClockOut ?? false;
  String get attendanceMessage => attendanceStatus?.message ?? '';

  // FIXED: Proper working day logic
  bool get isWorkingDay {
    if (attendanceStatus == null) return true; // Default to working day
    return attendanceStatus!.isWorkingDay;
  }

  bool get hasCompletedAttendance =>
      attendanceStatus?.hasCompletedAttendance ?? false;

  // Overtime info
  OvertimeInfoModel? get overtimeInfo => attendanceStatus?.overtimeInfo;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  /// Load all home screen data with enhanced error handling
  Future<void> loadHomeData() async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('🏠 HomeController: Loading home data...');
      }

      final results = await _homeService.refreshHomeData();

      // Handle attendance status with null safety
      final attendanceResponse =
          results['attendanceStatus'] as ApiResponse<AttendanceStatusModel>?;
      if (attendanceResponse != null &&
          attendanceResponse.success &&
          attendanceResponse.data != null) {
        _attendanceStatus.value = attendanceResponse.data;

        if (kDebugMode) {
          print('✅ HomeController: Attendance status loaded successfully');
          print('   - Can clock in: ${attendanceResponse.data!.canClockIn}');
          print('   - Can clock out: ${attendanceResponse.data!.canClockOut}');
          print(
            '   - Is working day: ${attendanceResponse.data!.isWorkingDay}',
          );
          print('   - Message: ${attendanceResponse.data!.message}');
          if (attendanceResponse.data!.todayAttendance != null) {
            print(
              '   - Today attendance: ${attendanceResponse.data!.todayAttendance!.toJson()}',
            );
          }
        }
      } else {
        final errorMsg =
            attendanceResponse?.message ??
            'Unknown error loading attendance status';
        _setError(errorMsg);
        if (kDebugMode) {
          print('❌ Failed to load attendance status: $errorMsg');
        }
      }

      // Handle recent activities with null safety
      final activitiesResponse =
          results['recentActivities'] as ApiResponse<List<ActivityModel>>?;
      if (activitiesResponse != null &&
          activitiesResponse.success &&
          activitiesResponse.data != null) {
        _recentActivities.value = activitiesResponse.data!;

        if (kDebugMode) {
          print(
            '✅ HomeController: Recent activities loaded successfully (${activitiesResponse.data!.length} items)',
          );
        }
      } else {
        final errorMsg =
            activitiesResponse?.message ?? 'Unknown error loading activities';
        _setError(errorMsg);
        if (kDebugMode) {
          print('❌ Failed to load recent activities: $errorMsg');
        }
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Failed to load home data: $e';
      _setError(errorMsg);
      if (kDebugMode) {
        print('❌ HomeController Error: $e');
        print('Stack trace: $stackTrace');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh home data (pull to refresh)
  Future<void> refreshHomeData() async {
    try {
      _setRefreshing(true);
      await loadHomeData();
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error refreshing home data: $e');
      }
    } finally {
      _setRefreshing(false);
    }
  }

  /// Load only attendance status
  Future<void> loadAttendanceStatus() async {
    try {
      final response = await _homeService.getAttendanceStatus();

      if (response.success && response.data != null) {
        _attendanceStatus.value = response.data;
        _clearError();

        if (kDebugMode) {
          print('✅ HomeController: Attendance status reloaded');
        }
      } else {
        _setError(response.message);
        if (kDebugMode) {
          print(
            '❌ HomeController: Failed to reload attendance status: ${response.message}',
          );
        }
      }
    } catch (e) {
      final errorMsg = 'Failed to load attendance status: $e';
      _setError(errorMsg);
      if (kDebugMode) {
        print('❌ HomeController: Exception loading attendance status: $e');
      }
    }
  }

  /// Load only recent activities
  Future<void> loadRecentActivities() async {
    try {
      final response = await _homeService.getRecentActivities(limit: 5);

      if (response.success && response.data != null) {
        _recentActivities.value = response.data!;
        _clearError();

        if (kDebugMode) {
          print(
            '✅ HomeController: Recent activities reloaded (${response.data!.length} items)',
          );
        }
      } else {
        _setError(response.message);
        if (kDebugMode) {
          print(
            '❌ HomeController: Failed to reload activities: ${response.message}',
          );
        }
      }
    } catch (e) {
      final errorMsg = 'Failed to load recent activities: $e';
      _setError(errorMsg);
      if (kDebugMode) {
        print('❌ HomeController: Exception loading activities: $e');
      }
    }
  }

  /// Get activities by type with null safety
  List<ActivityModel> getActivitiesByType(String type) {
    try {
      return _recentActivities
          .where(
            (activity) =>
                activity.activityType.toLowerCase() == type.toLowerCase(),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error filtering activities by type: $e');
      }
      return [];
    }
  }

  /// Get today's activities with enhanced date checking
  List<ActivityModel> getTodayActivities() {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return _recentActivities.where((activity) {
        final activityDate = DateTime(
          activity.activityTime.year,
          activity.activityTime.month,
          activity.activityTime.day,
        );
        return activityDate == today;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error getting today activities: $e');
      }
      return [];
    }
  }

  /// Check if user has clocked in today - FIXED
  bool get hasClockedInToday {
    try {
      // First check from API attendance status
      if (todayAttendance?.clockIn != null &&
          todayAttendance!.clockIn!.isNotEmpty) {
        return true;
      }

      // Fallback: check from activities
      final todayActivities = getTodayActivities();
      return todayActivities.any(
        (activity) => activity.activityType.toLowerCase() == 'clock_in',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error checking clock in status: $e');
      }
      return false;
    }
  }

  /// Check if user has clocked out today - FIXED
  bool get hasClockedOutToday {
    try {
      // First check from API attendance status
      if (todayAttendance?.clockOut != null &&
          todayAttendance!.clockOut!.isNotEmpty) {
        return true;
      }

      // Fallback: check from activities
      final todayActivities = getTodayActivities();
      return todayActivities.any(
        (activity) => activity.activityType.toLowerCase() == 'clock_out',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error checking clock out status: $e');
      }
      return false;
    }
  }

  /// Get latest clock in time today - FIXED
  String? get todayClockInTime {
    try {
      // First try from API attendance status
      if (todayAttendance?.clockIn != null &&
          todayAttendance!.clockIn!.isNotEmpty) {
        return todayAttendance!.clockIn;
      }

      // Fallback: get from activities
      final todayActivities = getTodayActivities();
      final clockInActivities = todayActivities
          .where(
            (activity) => activity.activityType.toLowerCase() == 'clock_in',
          )
          .toList();

      if (clockInActivities.isNotEmpty) {
        return clockInActivities.last.formattedTime;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error getting clock in time: $e');
      }
      return null;
    }
  }

  /// Get latest clock out time today - FIXED
  String? get todayClockOutTime {
    try {
      // First try from API attendance status
      if (todayAttendance?.clockOut != null &&
          todayAttendance!.clockOut!.isNotEmpty) {
        return todayAttendance!.clockOut;
      }

      // Fallback: get from activities
      final todayActivities = getTodayActivities();
      final clockOutActivities = todayActivities
          .where(
            (activity) => activity.activityType.toLowerCase() == 'clock_out',
          )
          .toList();

      if (clockOutActivities.isNotEmpty) {
        return clockOutActivities.last.formattedTime;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeController: Error getting clock out time: $e');
      }
      return null;
    }
  }

  // Private helper methods with enhanced logging
  void _setLoading(bool loading) {
    _isLoading.value = loading;
    if (kDebugMode) {
      print('🔄 HomeController: Loading state changed to $loading');
    }
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing.value = refreshing;
    if (kDebugMode) {
      print('🔄 HomeController: Refreshing state changed to $refreshing');
    }
  }

  void _setError(String message) {
    _errorMessage.value = message;
    if (kDebugMode) {
      print('❌ HomeController: Error set: $message');
    }
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  /// Handle errors with user-friendly messages and enhanced logging
  void handleError(String error) {
    if (kDebugMode) {
      print('🚨 HomeController: Handling error: $error');
    }

    if (error.contains('timeout')) {
      _setError('Connection timeout. Please check your internet connection.');
    } else if (error.contains('401') || error.contains('unauthorized')) {
      _setError('Session expired. Please login again.');
      // Navigate to login if needed with safety check
      try {
        Get.find<AuthController>().logout();
      } catch (e) {
        if (kDebugMode) {
          print('❌ HomeController: Error during logout: $e');
        }
      }
    } else if (error.contains('no internet') || error.contains('connection')) {
      _setError('No internet connection. Please check your network.');
    } else if (error.contains('FormatException') || error.contains('parse')) {
      _setError('Data format error. Please try again later.');
    } else {
      _setError('Something went wrong. Please try again.');
    }
  }

  /// Clear error message (public method for UI)
  void clearError() {
    _clearError();
  }

  /// Check if data is fresh (within last 5 minutes)
  bool get isDataFresh {
    // Simple implementation - you might want to store last update time
    return !isLoading && errorMessage.isEmpty && attendanceStatus != null;
  }

  /// Get status summary for debugging
  String get statusSummary {
    if (attendanceStatus == null) return 'No attendance data';

    return '''
    Working Day: $isWorkingDay
    Can Clock In: $canClockIn
    Can Clock Out: $canClockOut
    Has Clocked In Today: $hasClockedInToday
    Has Clocked Out Today: $hasClockedOutToday
    Today Clock In: ${todayClockInTime ?? 'None'}
    Today Clock Out: ${todayClockOutTime ?? 'None'}
    Message: $attendanceMessage
    Employee: ${currentUserName ?? 'Unknown'}
    Office: ${currentOfficeName ?? 'Unknown'}
    ''';
  }

  @override
  void onClose() {
    // Clean up resources
    _isLoading.close();
    _attendanceStatus.close();
    _recentActivities.close();
    _errorMessage.close();
    _isRefreshing.close();
    super.onClose();
  }
}
