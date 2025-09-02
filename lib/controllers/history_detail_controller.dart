import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/history_detail_service.dart';
import '../models/history_detail_model.dart';

class AttendanceDetailController extends GetxController {
  final AttendanceDetailService _attendanceDetailService =
      AttendanceDetailService();

  // Loading states
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Error handling
  final RxBool _hasError = false.obs;
  bool get hasError => _hasError.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  // Data
  final Rx<AttendanceDetailHistory?> _attendanceDetail =
      Rx<AttendanceDetailHistory?>(null);
  AttendanceDetailHistory? get attendanceDetail => _attendanceDetail.value;

  // Data availability
  bool get hasData => _attendanceDetail.value != null;

  // Current attendance ID
  final RxnInt _currentAttendanceId = RxnInt();
  int? get currentAttendanceId => _currentAttendanceId.value;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🎯 AttendanceDetailController initialized');
    }
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('🎯 AttendanceDetailController disposed');
    }
    super.onClose();
  }

  /// Load attendance detail by ID
  Future<void> loadAttendanceDetail(int id) async {
    try {
      _setLoading(true);
      _clearError();
      _currentAttendanceId.value = id;

      if (kDebugMode) {
        print('📥 Loading attendance detail for ID: $id');
        print(
          '🔄 Builder called - isLoading: $isLoading, hasError: $hasError, hasData: $hasData',
        );
      }

      final response = await _attendanceDetailService.getAttendanceDetail(id);

      if (kDebugMode) {
        print(
          '📨 Service response: success=${response.success}, message=${response.message}',
        );
        print('📨 Service data: ${response.data}');
      }

      if (response.success && response.data != null) {
        _attendanceDetail.value = response.data;

        if (kDebugMode) {
          print('✅ Attendance detail loaded successfully');
          print('📝 Controller data: ${_attendanceDetail.value.toString()}');
          print(
            '🔄 After success - isLoading: $isLoading, hasError: $hasError, hasData: $hasData',
          );
        }

        _setLoading(false);
        update(); // Trigger UI update
      } else {
        _setError(response.message);
        if (kDebugMode) {
          print('❌ Failed to load attendance detail: ${response.message}');
          print(
            '🔄 After error - isLoading: $isLoading, hasError: $hasError, hasData: $hasData',
          );
        }
      }
    } catch (e) {
      _setError('Failed to load attendance detail. Please try again.');
      if (kDebugMode) {
        print('❌ Error in loadAttendanceDetail: $e');
        print('❌ Stack trace: ${StackTrace.current}');
        print(
          '🔄 After exception - isLoading: $isLoading, hasError: $hasError, hasData: $hasData',
        );
      }
    }
  }

  /// Refresh attendance detail data
  Future<void> refreshData() async {
    if (kDebugMode) {
      print('🔄 Refreshing data...');
    }

    if (_currentAttendanceId.value != null) {
      await loadAttendanceDetail(_currentAttendanceId.value!);
    } else {
      _setError('No attendance ID available for refresh');
    }
  }

  /// Clear all data
  void clearData() {
    _attendanceDetail.value = null;
    _currentAttendanceId.value = null;
    _clearError();

    if (kDebugMode) {
      print('🗑️ Attendance detail data cleared');
    }

    update(); // Trigger UI update
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading.value = loading;
    if (!loading) _clearError();

    if (kDebugMode) {
      print('🔄 Loading state changed to: $loading');
    }

    update(); // Trigger UI update immediately
  }

  /// Set error state
  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
    _isLoading.value = false;

    if (kDebugMode) {
      print('❌ Error state set: $message');
    }

    update(); // Trigger UI update
  }

  /// Clear error state
  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';

    if (kDebugMode) {
      print('✅ Error state cleared');
    }
  }

  /// Utility methods for UI

  /// Get formatted date for display
  String get formattedDate {
    if (_attendanceDetail.value == null) return '';

    try {
      final date = DateTime.parse(_attendanceDetail.value!.date);
      return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return _attendanceDetail.value!.date;
    }
  }

  /// Get status color for UI
  int get statusColor {
    if (_attendanceDetail.value == null) return 0xFF666666;

    switch (_attendanceDetail.value!.status.toLowerCase()) {
      case 'present':
        return 0xFF4CAF50;
      case 'late':
        return 0xFFFF9800;
      case 'absent':
        return 0xFFF44336;
      case 'sick':
        return 0xFF9C27B0;
      case 'holiday':
        return 0xFFE91E63;
      default:
        return 0xFF666666;
    }
  }

  /// Get status translation
  String get translatedStatus {
    if (_attendanceDetail.value == null) return '';

    return _translateStatusToEnglish(_attendanceDetail.value!.statusLabel);
  }

  /// Get day name translation
  String get translatedDayName {
    if (_attendanceDetail.value == null) return '';

    return _translateDayToEnglish(_attendanceDetail.value!.dayName);
  }

  /// Check if attendance has overtime
  bool get hasOvertime =>
      _attendanceDetail.value?.overtimeDurationMinutes != null &&
      _attendanceDetail.value!.overtimeDurationMinutes > 0;

  /// Check if attendance is complete (has both clock in and out)
  bool get isAttendanceComplete => _attendanceDetail.value?.isComplete ?? false;

  /// Check if has check in location
  bool get hasCheckInLocation =>
      _attendanceDetail.value?.clockInLocation.hasCoordinates ?? false;

  /// Check if has check out location
  bool get hasCheckOutLocation =>
      _attendanceDetail.value?.clockOutLocation.hasCoordinates ?? false;

  /// Get check in location display text
  String get checkInLocationText {
    if (_attendanceDetail.value?.clockInLocation.hasAddress == true) {
      return _attendanceDetail.value!.clockInLocation.address!;
    } else if (hasCheckInLocation) {
      return 'Lat: ${_attendanceDetail.value!.clockInLocation.latitude?.toStringAsFixed(6)}, Lng: ${_attendanceDetail.value!.clockInLocation.longitude?.toStringAsFixed(6)}';
    }
    return 'Location not available';
  }

  /// Get check out location display text
  String get checkOutLocationText {
    if (_attendanceDetail.value?.clockOutLocation.hasAddress == true) {
      return _attendanceDetail.value!.clockOutLocation.address!;
    } else if (hasCheckOutLocation) {
      return 'Lat: ${_attendanceDetail.value!.clockOutLocation.latitude?.toStringAsFixed(6)}, Lng: ${_attendanceDetail.value!.clockOutLocation.longitude?.toStringAsFixed(6)}';
    }
    return 'Location not available';
  }

  /// Private helper methods

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _translateStatusToEnglish(String indonesianStatus) {
    switch (indonesianStatus.toLowerCase()) {
      case 'hadir':
        return 'Present';
      case 'terlambat':
        return 'Late';
      case 'tidak hadir':
      case 'absent':
      case 'alfa':
        return 'Absent';
      case 'sakit':
      case 'izin':
      case 'cuti':
        return 'Sick/Leave';
      case 'libur':
      case 'hari libur':
        return 'Holiday';
      case 'wfh':
      case 'work from home':
        return 'Work From Home';
      case 'dinas luar':
      case 'perjalanan dinas':
        return 'Business Trip';
      default:
        return indonesianStatus;
    }
  }

  String _translateDayToEnglish(String indonesianDay) {
    switch (indonesianDay.toLowerCase()) {
      case 'senin':
        return 'Monday';
      case 'selasa':
        return 'Tuesday';
      case 'rabu':
        return 'Wednesday';
      case 'kamis':
        return 'Thursday';
      case 'jumat':
        return 'Friday';
      case 'sabtu':
        return 'Saturday';
      case 'minggu':
        return 'Sunday';
      default:
        return indonesianDay;
    }
  }
}
