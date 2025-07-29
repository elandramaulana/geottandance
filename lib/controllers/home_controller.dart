import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geottandance/controllers/attendance_controller.dart';

class HomeController extends GetxController {
  late AttendanceController attendanceController;
  Timer? _updateTimer;

  // Observable untuk waktu clock in dan clock out
  var clockInTime = ''.obs;
  var clockOutTime = ''.obs;
  var clockInStatus = 'Not Yet'.obs;
  var clockOutStatus = 'Not Yet'.obs;

  @override
  void onInit() {
    super.onInit();
    // Get atau create AttendanceController instance
    attendanceController = Get.find<AttendanceController>();

    // Initial update
    _updateClockTimes();

    // Listen to attendance controller changes
    _listenToAttendanceChanges();

    // Start periodic updates for real-time clock
    _startPeriodicUpdates();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  void _listenToAttendanceChanges() {
    // Listen to attendance records changes menggunakan public getter
    ever(attendanceController.attendanceRecordsObservable, (_) {
      _updateClockTimes();
    });

    // Listen to today's records changes
    ever(attendanceController.todayRecordsObservable, (_) {
      _updateClockTimes();
    });

    // Listen to clock status changes
    ever(attendanceController.isClockedInObservable, (_) {
      _updateClockTimes();
    });

    // Listen to last attendance changes
    ever(attendanceController.lastAttendanceObservable, (_) {
      _updateClockTimes();
    });
  }

  void _startPeriodicUpdates() {
    // Update setiap 1 menit untuk real-time duration
    _updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (attendanceController.isClockedIn) {
        _updateClockTimes(); // Hanya update jika sedang clock in
      }
    });
  }

  void _updateClockTimes() {
    final todayStats = attendanceController.getTodayWorkStats();

    // Update clock in time
    if (todayStats['clockInTime'] != null) {
      final clockInDateTime = todayStats['clockInTime'] as DateTime;
      clockInTime.value = DateFormat('HH:mm').format(clockInDateTime);
      clockInStatus.value = _getClockInStatus(clockInDateTime);
    } else {
      clockInTime.value = '--:--';
      clockInStatus.value = 'Not Yet';
    }

    // Update clock out time
    if (todayStats['clockOutTime'] != null) {
      final clockOutDateTime = todayStats['clockOutTime'] as DateTime;
      clockOutTime.value = DateFormat('HH:mm').format(clockOutDateTime);
      clockOutStatus.value = 'Completed';
    } else {
      clockOutTime.value = '--:--';
      clockOutStatus.value = attendanceController.isClockedIn
          ? 'In Progress'
          : 'Not Yet';
    }

    // Force update UI
    update();
  }

  String _getClockInStatus(DateTime clockInTime) {
    // Assume work starts at 8:00 AM
    final workStartTime = DateTime(
      clockInTime.year,
      clockInTime.month,
      clockInTime.day,
      8, // 8 AM
      0,
    );

    if (clockInTime.isBefore(workStartTime)) {
      return 'Early';
    } else if (clockInTime.isAfter(workStartTime.add(Duration(minutes: 15)))) {
      return 'Late';
    } else {
      return 'On Time';
    }
  }

  // Method untuk clock in - delegate to AttendanceController
  Future<void> clockIn() async {
    final success = await attendanceController.clockIn();
    if (success) {
      // Update akan otomatis terjadi karena listener
      await Future.delayed(Duration(milliseconds: 100)); // Small delay
      _updateClockTimes(); // Immediate update untuk responsivitas
    }
  }

  // Method untuk clock out - delegate to AttendanceController
  Future<void> clockOut() async {
    final success = await attendanceController.clockOut();
    if (success) {
      // Update akan otomatis terjadi karena listener
      await Future.delayed(Duration(milliseconds: 100)); // Small delay
      _updateClockTimes(); // Immediate update untuk responsivitas
    }
  }

  // Method untuk refresh data
  Future<void> refreshData() async {
    await attendanceController.refreshAllData();
    _updateClockTimes();
  }

  // Force update clock times (untuk dipanggil manual jika perlu)
  void forceUpdateClockTimes() {
    _updateClockTimes();
  }

  // Getter untuk mendapatkan status kerja hari ini
  String get todayWorkStatus {
    final todayStats = attendanceController.getTodayWorkStats();
    return todayStats['status'] as String;
  }

  // Getter untuk durasi kerja hari ini (observable)
  String get todayWorkDuration {
    final todayStats = attendanceController.getTodayWorkStats();
    final duration = todayStats['workDuration'] as Duration;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }

  // Check if user is currently clocked in
  bool get isCurrentlyClockedIn => attendanceController.isClockedIn;
}
