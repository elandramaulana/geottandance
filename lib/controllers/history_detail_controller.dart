import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/history_detail_service.dart';
import '../models/history_detail_model.dart';

class AttendanceDetailController extends GetxController {
  final AttendanceDetailService _attendanceDetailService =
      AttendanceDetailService();

  // Reactive states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<AttendanceDetailHistory?> attendanceDetail =
      Rx<AttendanceDetailHistory?>(null);
  final RxnInt currentAttendanceId = RxnInt();

  // Computed property
  bool get hasData => attendanceDetail.value != null;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🎯 AttendanceDetailController initialized');
    }
  }

  /// Load attendance detail by ID
  Future<void> loadAttendanceDetail(int id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      currentAttendanceId.value = id;

      if (kDebugMode) {
        print('📥 Loading attendance detail for ID: $id');
      }

      final response = await _attendanceDetailService.getAttendanceDetail(id);

      if (response.success && response.data != null) {
        attendanceDetail.value = response.data;

        if (kDebugMode) {
          print('✅ Attendance detail loaded successfully');
        }
      } else {
        hasError.value = true;
        errorMessage.value = response.message;

        if (kDebugMode) {
          print('❌ Failed: ${response.message}');
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load attendance detail. Please try again.';

      if (kDebugMode) {
        print('❌ Error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh attendance detail data
  Future<void> refreshData() async {
    if (currentAttendanceId.value != null) {
      await loadAttendanceDetail(currentAttendanceId.value!);
    } else {
      hasError.value = true;
      errorMessage.value = 'No attendance ID available for refresh';
    }
  }

  /// Clear all data
  void clearData() {
    attendanceDetail.value = null;
    currentAttendanceId.value = null;
    hasError.value = false;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🗑️ Attendance detail data cleared');
    }
  }
}
