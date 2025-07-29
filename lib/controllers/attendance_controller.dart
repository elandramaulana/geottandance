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

  // New observables for daily tracking
  final _hasClickedInToday = false.obs;
  final _hasClockedOutToday = false.obs;
  final _todayClockIn = Rxn<AttendanceRecord>();
  final _todayClockOut = Rxn<AttendanceRecord>();

  RxList<AttendanceRecord> get attendanceRecordsObservable =>
      _attendanceRecords;
  RxList<AttendanceRecord> get todayRecordsObservable => _todayRecords;
  RxBool get isClockedInObservable => _isClockedIn;
  Rxn<AttendanceRecord> get lastAttendanceObservable => _lastAttendance;

  // New getters for daily tracking
  RxBool get hasClickedInTodayObservable => _hasClickedInToday;
  RxBool get hasClockedOutTodayObservable => _hasClockedOutToday;
  Rxn<AttendanceRecord> get todayClockInObservable => _todayClockIn;
  Rxn<AttendanceRecord> get todayClockOutObservable => _todayClockOut;

  // Getters
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceRecord? get lastAttendance => _lastAttendance.value;
  Position? get currentPosition => _currentPosition.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isClockedIn => _isClockedIn.value;
  Duration get workDuration => _workDuration.value;
  // New getters for daily tracking
  bool get hasClickedInToday => _hasClickedInToday.value;
  bool get hasClockedOutToday => _hasClockedOutToday.value;
  AttendanceRecord? get todayClockIn => _todayClockIn.value;
  AttendanceRecord? get todayClockOut => _todayClockOut.value;

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
      await _loadDailyAttendanceStatus();
      await _checkClockStatus();
      await _loadTodayRecords();
      _updateWorkDuration();

      // Clean up old records (optional)
      await _databaseHelper.cleanupOldDailyStatus();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load daily attendance status
  Future<void> _loadDailyAttendanceStatus() async {
    try {
      _hasClickedInToday.value = await _databaseHelper.hasClickedInToday();
      _hasClockedOutToday.value = await _databaseHelper.hasClockedOutToday();
      _todayClockIn.value = await _databaseHelper.getTodayClockIn();
      _todayClockOut.value = await _databaseHelper.getTodayClockOut();
    } catch (e) {
      _setError('Failed to load daily attendance status: $e');
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
    // Check if user is currently clocked in based on today's records
    if (_hasClickedInToday.value && !_hasClockedOutToday.value) {
      _isClockedIn.value = true;
      _clockInTime = _todayClockIn.value?.timestamp;
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
    } else if (_todayClockIn.value != null && _todayClockOut.value != null) {
      _workDuration.value = _todayClockOut.value!.timestamp.difference(
        _todayClockIn.value!.timestamp,
      );
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

  /// Clock in functionality with daily restriction
  Future<bool> clockIn() async {
    if (_currentPosition.value == null) {
      _setError('Location not available. Please enable location services.');
      return false;
    }

    // Check if already clocked in today
    if (_hasClickedInToday.value) {
      _setError(
        'You have already clocked in today. You can only clock in once per day.',
      );
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

      // Insert attendance record
      final recordId = await _databaseHelper.insertAttendance(record);

      // Update daily attendance status
      await _databaseHelper.updateDailyAttendanceStatus(
        hasClickedIn: true,
        clockInId: recordId,
      );

      // Reload data
      await _loadAttendanceRecords();
      await _loadTodayRecords();
      await _loadDailyAttendanceStatus();

      _isClockedIn.value = true;
      _clockInTime = record.timestamp;
      _clearError();

      // Notify history controller to refresh
      _notifyHistoryController();

      _showSuccessSnackbar(
        title: 'Clock In Successful',
        message: 'Welcome! Your work session has started for today.',
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

  /// Clock out functionality with daily restriction
  Future<bool> clockOut() async {
    if (_currentPosition.value == null) {
      _setError('Location not available. Please enable location services.');
      return false;
    }

    // Check if already clocked out today
    if (_hasClockedOutToday.value) {
      _setError(
        'You have already clocked out today. You can only clock out once per day.',
      );
      return false;
    }

    // Check if user hasn't clocked in today
    if (!_hasClickedInToday.value) {
      _setError('You must clock in first before you can clock out.');
      return false;
    }

    if (!_isClockedIn.value) {
      _setError('You are not currently clocked in.');
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

      // Insert attendance record
      final recordId = await _databaseHelper.insertAttendance(record);

      // Update daily attendance status
      await _databaseHelper.updateDailyAttendanceStatus(
        hasClockedOut: true,
        clockOutId: recordId,
      );

      // Reload data
      await _loadAttendanceRecords();
      await _loadTodayRecords();
      await _loadDailyAttendanceStatus();

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
            'Work session completed for today. Duration: ${_formatDuration(workDuration)}',
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

  /// Get work statistics for today (updated)
  Map<String, dynamic> getTodayWorkStats() {
    Duration workDuration = Duration.zero;
    String status = 'Not started';

    if (_todayClockIn.value != null) {
      if (_todayClockOut.value != null) {
        workDuration = _todayClockOut.value!.timestamp.difference(
          _todayClockIn.value!.timestamp,
        );
        status = 'Completed';
      } else {
        workDuration = DateTime.now().difference(
          _todayClockIn.value!.timestamp,
        );
        status = 'In progress';
      }
    }

    return {
      'clockInTime': _todayClockIn.value?.timestamp,
      'clockOutTime': _todayClockOut.value?.timestamp,
      'workDuration': workDuration,
      'status': status,
      'hasClickedInToday': _hasClickedInToday.value,
      'hasClockedOutToday': _hasClockedOutToday.value,
    };
  }

  /// Check if user can clock in today
  bool canClockInToday() {
    return !_hasClickedInToday.value && _currentPosition.value != null;
  }

  /// Check if user can clock out today
  bool canClockOutToday() {
    return _hasClickedInToday.value &&
        !_hasClockedOutToday.value &&
        _isClockedIn.value &&
        _currentPosition.value != null;
  }

  /// Get remaining actions for today
  String getTodayActionStatus() {
    if (!_hasClickedInToday.value) {
      return 'Ready to clock in';
    } else if (_hasClickedInToday.value && !_hasClockedOutToday.value) {
      return 'Ready to clock out';
    } else {
      return 'Attendance completed for today';
    }
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
        snackPosition: SnackPosition.TOP,
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
      snackPosition: SnackPosition.TOP,
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
      snackPosition: SnackPosition.TOP,
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

  /// Manual reset for testing purposes (remove in production)
  Future<void> resetTodayAttendance() async {
    try {
      await _databaseHelper.updateDailyAttendanceStatus(
        hasClickedIn: false,
        hasClockedOut: false,
        clockInId: null,
        clockOutId: null,
      );
      await _loadDailyAttendanceStatus();
      await _checkClockStatus();
      _showInfoSnackbar(
        title: 'Reset Successful',
        message: 'Today\'s attendance has been reset',
        icon: Icons.refresh_rounded,
      );
    } catch (e) {
      _setError('Failed to reset attendance: $e');
    }
  }
}
