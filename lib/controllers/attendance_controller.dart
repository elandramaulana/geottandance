// lib/controllers/attendance_controller.dart
import 'package:geottandance/core/database_helper.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
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

  // Getters
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceRecord? get lastAttendance => _lastAttendance.value;
  Position? get currentPosition => _currentPosition.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isClockedIn => _isClockedIn.value;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    _setLoading(true);
    await _loadAttendanceRecords();
    await _updateCurrentLocation();
    await _checkClockStatus();
    _setLoading(false);
  }

  Future<void> _loadAttendanceRecords() async {
    try {
      final records = await _databaseHelper.getAllAttendance();
      _attendanceRecords.assignAll(records);
      _lastAttendance.value = await _databaseHelper.getLastAttendance();
    } catch (e) {
      _setError('Failed to load attendance records: $e');
    }
  }

  Future<void> _updateCurrentLocation() async {
    try {
      _currentPosition.value = await LocationService.getCurrentLocation();
    } catch (e) {
      _setError('Failed to get current location: $e');
    }
  }

  Future<void> _checkClockStatus() async {
    if (_lastAttendance.value != null) {
      _isClockedIn.value = _lastAttendance.value!.type == 'clock_in';
    } else {
      _isClockedIn.value = false;
    }
  }

  Future<bool> clockIn() async {
    if (_currentPosition.value == null) {
      _setError('Location not available. Please enable location services.');
      return false;
    }

    _setLoading(true);
    try {
      String address = await LocationService.getAddressFromCoordinates(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      );

      AttendanceRecord record = AttendanceRecord(
        timestamp: DateTime.now(),
        latitude: _currentPosition.value!.latitude,
        longitude: _currentPosition.value!.longitude,
        type: 'clock_in',
        address: address,
      );

      await _databaseHelper.insertAttendance(record);
      await _loadAttendanceRecords();
      _isClockedIn.value = true;
      _clearError();
      _setLoading(false);

      // Show success message
      Get.snackbar(
        'Success',
        'Successfully clocked in!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      return true;
    } catch (e) {
      _setError('Failed to clock in: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> clockOut() async {
    if (_currentPosition.value == null) {
      _setError('Location not available. Please enable location services.');
      return false;
    }

    _setLoading(true);
    try {
      String address = await LocationService.getAddressFromCoordinates(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      );

      AttendanceRecord record = AttendanceRecord(
        timestamp: DateTime.now(),
        latitude: _currentPosition.value!.latitude,
        longitude: _currentPosition.value!.longitude,
        type: 'clock_out',
        address: address,
      );

      await _databaseHelper.insertAttendance(record);
      await _loadAttendanceRecords();
      _isClockedIn.value = false;
      _clearError();
      _setLoading(false);

      // Show success message
      Get.snackbar(
        'Success',
        'Successfully clocked out!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );

      return true;
    } catch (e) {
      _setError('Failed to clock out: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshLocation() async {
    await _updateCurrentLocation();
    Get.snackbar(
      'Location Updated',
      'Current location has been refreshed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    return await _databaseHelper.getAttendanceByDate(date);
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String error) {
    _errorMessage.value = error;
    if (error.isNotEmpty) {
      Get.snackbar(
        'Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  void clearError() {
    _clearError();
  }
}
