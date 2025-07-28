// lib/controllers/attendance_controller.dart
import 'package:geottandance/controllers/history_controller.dart';
import 'package:geottandance/core/database_helper.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/location_service.dart';

class AttendanceController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Observable variables
  final _attendanceRecords = <AttendanceRecord>[].obs;
  final _lastAttendance = Rxn<AttendanceRecord>();
  final _currentPosition = Rxn<Position>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isClockedIn = false.obs;
  final _workDuration = Duration.zero.obs;
  final _todayRecords = <AttendanceRecord>[].obs;

  // Getters
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceRecord? get lastAttendance => _lastAttendance.value;
  Position? get currentPosition => _currentPosition.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isClockedIn => _isClockedIn.value;
  Duration get workDuration => _workDuration.value;
  List<AttendanceRecord> get todayRecords => _todayRecords;

  // Work session tracking
  DateTime? _clockInTime;
  DateTime? get clockInTime => _clockInTime;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }

  /// Initialize the controller
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadAttendanceRecords();
      await _updateCurrentLocation();
      await _checkClockStatus();
      await _loadTodayRecords();
      _updateWorkDuration();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load all attendance records from database
  Future<void> _loadAttendanceRecords() async {
    try {
      final records = await _databaseHelper.getAllAttendance();
      _attendanceRecords.assignAll(records);
      _lastAttendance.value = await _databaseHelper.getLastAttendance();
    } catch (e) {
      _setError('Failed to load attendance records: $e');
    }
  }

  /// Update current location
  Future<void> _updateCurrentLocation() async {
    try {
      _currentPosition.value = await LocationService.getCurrentLocation();
    } catch (e) {
      _setError('Failed to get current location: $e');
      rethrow;
    }
  }

  /// Check current clock status
  Future<void> _checkClockStatus() async {
    if (_lastAttendance.value != null) {
      _isClockedIn.value = _lastAttendance.value!.type == 'clock_in';
      if (_isClockedIn.value) {
        _clockInTime = _lastAttendance.value!.timestamp;
      }
    } else {
      _isClockedIn.value = false;
      _clockInTime = null;
    }
  }

  /// Load today's attendance records
  Future<void> _loadTodayRecords() async {
    try {
      final today = DateTime.now();
      final records = await _databaseHelper.getAttendanceByDate(today);
      _todayRecords.assignAll(records);
    } catch (e) {
      _setError('Failed to load today\'s records: $e');
    }
  }

  /// Update work duration
  void _updateWorkDuration() {
    if (_isClockedIn.value && _clockInTime != null) {
      _workDuration.value = DateTime.now().difference(_clockInTime!);
    } else {
      _workDuration.value = Duration.zero;
    }
  }

  void _notifyHistoryController() {
    // Get history controller instance if it exists
    try {
      final historyController = Get.find<HistoryController>();
      historyController.refreshHistory();
    } catch (e) {
      // History controller might not be initialized yet
      print('History controller not found: $e');
    }
  }

  /// Clock in functionality
  Future<bool> clockIn() async {
    if (_currentPosition.value == null) {
      _setError('Location not available. Please enable location services.');
      return false;
    }

    if (_isClockedIn.value) {
      _setError('You are already clocked in.');
      return false;
    }

    _setLoading(true);
    try {
      final address = await LocationService.getAddressFromCoordinates(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      );

      final record = AttendanceRecord(
        timestamp: DateTime.now(),
        latitude: _currentPosition.value!.latitude,
        longitude: _currentPosition.value!.longitude,
        type: 'clock_in',
        address: address,
      );

      await _databaseHelper.insertAttendance(record);
      await _loadAttendanceRecords();
      await _loadTodayRecords();

      _isClockedIn.value = true;
      _clockInTime = record.timestamp;
      _clearError();

      // Notify history controller to refresh
      _notifyHistoryController();

      _showSuccessSnackbar(
        title: 'Clock In Successful',
        message: 'Welcome! Your work session has started.',
        icon: Icons.login_rounded,
        color: const Color(0xFF10B981),
      );

      return true;
    } catch (e) {
      _setError('Failed to clock in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updated clock out functionality with history notification
  Future<bool> clockOut() async {
    if (_currentPosition.value == null) {
      _setError('Location not available. Please enable location services.');
      return false;
    }

    if (!_isClockedIn.value) {
      _setError('You are not clocked in.');
      return false;
    }

    _setLoading(true);
    try {
      final address = await LocationService.getAddressFromCoordinates(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      );

      final record = AttendanceRecord(
        timestamp: DateTime.now(),
        latitude: _currentPosition.value!.latitude,
        longitude: _currentPosition.value!.longitude,
        type: 'clock_out',
        address: address,
      );

      await _databaseHelper.insertAttendance(record);
      await _loadAttendanceRecords();
      await _loadTodayRecords();

      _isClockedIn.value = false;
      final workDuration = _clockInTime != null
          ? record.timestamp.difference(_clockInTime!)
          : Duration.zero;
      _clockInTime = null;
      _clearError();

      // Notify history controller to refresh
      _notifyHistoryController();

      _showSuccessSnackbar(
        title: 'Clock Out Successful',
        message:
            'Work session ended. Duration: ${_formatDuration(workDuration)}',
        icon: Icons.logout_rounded,
        color: const Color(0xFFEF4444),
      );

      return true;
    } catch (e) {
      _setError('Failed to clock out: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current location
  Future<void> refreshLocation() async {
    _setLoading(true);
    try {
      await _updateCurrentLocation();
      _showInfoSnackbar(
        title: 'Location Updated',
        message: 'Current location has been refreshed',
        icon: Icons.refresh_rounded,
      );
    } catch (e) {
      _setError('Failed to refresh location: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get attendance records by date
  Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    try {
      return await _databaseHelper.getAttendanceByDate(date);
    } catch (e) {
      _setError('Failed to get attendance by date: $e');
      return [];
    }
  }

  /// Get work statistics for today
  Map<String, dynamic> getTodayWorkStats() {
    final today = DateTime.now();
    final todayRecords = _todayRecords.where((record) {
      return record.timestamp.day == today.day &&
          record.timestamp.month == today.month &&
          record.timestamp.year == today.year;
    }).toList();

    if (todayRecords.isEmpty) {
      return {
        'clockInTime': null,
        'clockOutTime': null,
        'workDuration': Duration.zero,
        'status': 'Not started',
      };
    }

    final clockInRecord = todayRecords.firstWhereOrNull(
      (record) => record.type == 'clock_in',
    );
    final clockOutRecord = todayRecords.lastWhere(
      (record) => record.type == 'clock_out',
    );

    Duration workDuration = Duration.zero;
    String status = 'Not started';

    if (clockInRecord != null) {
      if (clockOutRecord != null &&
          clockOutRecord.timestamp.isAfter(clockInRecord.timestamp)) {
        workDuration = clockOutRecord.timestamp.difference(
          clockInRecord.timestamp,
        );
        status = 'Completed';
      } else {
        workDuration = DateTime.now().difference(clockInRecord.timestamp);
        status = 'In progress';
      }
    }

    return {
      'clockInTime': clockInRecord?.timestamp,
      'clockOutTime': clockOutRecord?.timestamp,
      'workDuration': workDuration,
      'status': status,
    };
  }

  /// Format duration to readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Set error message and show snackbar
  void _setError(String error) {
    _errorMessage.value = error;
    if (error.isNotEmpty) {
      Get.snackbar(
        'Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Clear error message
  void _clearError() {
    _errorMessage.value = '';
  }

  /// Show success snackbar
  void _showSuccessSnackbar({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Show info snackbar
  void _showInfoSnackbar({
    required String title,
    required String message,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF667EEA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Public method to clear error (for UI)
  void clearError() {
    _clearError();
  }

  /// Force refresh all data
  Future<void> refreshAllData() async {
    await initialize();
  }

  /// Check if user can clock in/out based on location (for geofencing)
  bool canPerformActionAtLocation({double radiusInMeters = 100.0}) {
    // This can be extended to check if user is within allowed location
    return _currentPosition.value != null;
  }

  /// Get formatted work duration for current session
  String get currentWorkDurationFormatted {
    _updateWorkDuration();
    return _formatDuration(_workDuration.value);
  }
}
