// lib/controllers/attendance_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geottandance/models/attendance_model.dart';
import 'package:get/get.dart';
import '../services/attendance_service.dart';
import '../services/location_service.dart';

class AttendanceController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final LocationService _locationService = LocationService();

  // Observables
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final Rx<OfficeLocation?> _officeLocation = Rx<OfficeLocation?>(null);
  final RxBool _isLoading = false.obs;
  final RxDouble _distance = 0.0.obs;
  final Rx<AttendanceStatus> _attendanceStatus =
      AttendanceStatus.notStarted.obs;
  final Rx<TodayAttendance?> _todayAttendance = Rx<TodayAttendance?>(null);
  final RxString _errorMessage = ''.obs;
  final RxString _currentAddress = ''.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isInitializing = false.obs;
  final RxList<AttendanceRecord> _attendanceRecords = <AttendanceRecord>[].obs;

  // Server sync flags
  final RxBool _canClockInFromServer = true.obs;
  final RxBool _canClockOutFromServer = false.obs;
  final RxBool _isWorkingDay = true.obs;

  // Outside radius flags (temporary)
  final RxBool _allowOutsideRadiusClockIn = false.obs;
  final RxBool _allowOutsideRadiusClockOut = false.obs;

  // Getters
  Position? get currentPosition => _currentPosition.value;
  OfficeLocation? get officeLocation => _officeLocation.value;
  bool get isLoading => _isLoading.value;
  double get distance => _distance.value;
  AttendanceStatus get attendanceStatus => _attendanceStatus.value;
  TodayAttendance? get todayAttendance => _todayAttendance.value;
  String get errorMessage => _errorMessage.value;
  String get currentAddress => _currentAddress.value;
  bool get isWorkingDay => _isWorkingDay.value;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  bool get isWithinRadius {
    if (_officeLocation.value == null || _currentPosition.value == null) {
      return false;
    }
    return _distance.value <= _officeLocation.value!.allowedRadius;
  }

  bool get canClockIn {
    return !isLoading &&
        _isInitialized.value &&
        _isWorkingDay.value &&
        _canClockInFromServer.value &&
        _attendanceStatus.value == AttendanceStatus.notStarted &&
        (isWithinRadius || _allowOutsideRadiusClockIn.value);
  }

  bool get canClockOut {
    return !isLoading &&
        _isInitialized.value &&
        _isWorkingDay.value &&
        _canClockOutFromServer.value &&
        _attendanceStatus.value == AttendanceStatus.clockedIn &&
        (isWithinRadius || _allowOutsideRadiusClockOut.value);
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('🚀 AttendanceController onInit called');
    }

    if (!_isInitialized.value && !_isInitializing.value) {
      _initializeAttendance();
    }
  }

  /// Initialize attendance system
  Future<void> _initializeAttendance() async {
    if (_isInitializing.value || _isInitialized.value) {
      if (kDebugMode) {
        print('⚠️ Initialization already in progress or completed');
      }
      return;
    }

    _isInitializing.value = true;
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      if (kDebugMode) {
        print('🔄 Starting attendance initialization...');
      }

      // Get current location
      await _getCurrentLocation();
      await _getCurrentAddress();

      // Get office location
      await _getOfficeLocation();

      // Calculate distance
      _calculateDistance();

      // Get current attendance status from server
      await _getAttendanceStatus();

      _isInitialized.value = true;

      if (kDebugMode) {
        print('✅ Attendance initialization completed successfully');
      }
    } catch (e) {
      _handleInitializationError(e);
    } finally {
      _isLoading.value = false;
      _isInitializing.value = false;
    }
  }

  /// Handle initialization errors
  void _handleInitializationError(dynamic error) {
    _errorMessage.value = error.toString();
    if (kDebugMode) {
      print('❌ Initialize attendance error: $error');
    }

    // Set default office location if API fails
    if (_officeLocation.value == null) {
      _officeLocation.value = OfficeLocation.defaultLocation;
      _calculateDistance();
      _isInitialized.value = true;
    }

    // Don't show snackbar if widget is not ready
    if (Get.context != null) {
      Get.snackbar(
        'Warning',
        'Failed to connect to server. Using offline mode.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Get current location using location service
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      _currentPosition.value = position;

      if (kDebugMode) {
        print(
          '📍 Current location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get current location error: $e');
      }
      throw Exception('Failed to get current location: $e');
    }
  }

  /// Get current address from coordinates
  Future<void> _getCurrentAddress() async {
    if (_currentPosition.value == null) {
      _currentAddress.value = 'Location not available';
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts =
            [
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                ]
                .where((element) => element != null && element.isNotEmpty)
                .map((e) => e!)
                .toList();

        _currentAddress.value = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Address not available';

        if (kDebugMode) {
          print('📍 Current address: ${_currentAddress.value}');
        }
      } else {
        _currentAddress.value = 'Address not available';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get current address error: $e');
      }
      _currentAddress.value = 'Address not available';
    }
  }

  /// Get office location from server
  Future<void> _getOfficeLocation() async {
    try {
      final officeLocation = await _attendanceService.getOfficeLocation(
        userLatitude: _currentPosition.value?.latitude ?? -6.2,
        userLongitude: _currentPosition.value?.longitude ?? 106.816666,
      );

      _officeLocation.value = officeLocation;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get office location error: $e');
      }
      // Use default location instead of throwing
      _officeLocation.value = OfficeLocation.defaultLocation;
      if (kDebugMode) {
        print('🏢 Using default office location');
      }
    }
  }

  /// Calculate distance to office
  void _calculateDistance() {
    if (_currentPosition.value == null || _officeLocation.value == null) {
      _distance.value = double.infinity;
      return;
    }

    try {
      final double distanceInMeters = _locationService.calculateDistance(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
        _officeLocation.value!.latitude,
        _officeLocation.value!.longitude,
      );

      _distance.value = distanceInMeters;

      if (kDebugMode) {
        print('📏 Distance to office: ${distanceInMeters.toStringAsFixed(2)}m');
        print('✅ Within radius: $isWithinRadius');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Calculate distance error: $e');
      }
      _distance.value = double.infinity;
    }
  }

  /// Get attendance status from server
  Future<void> _getAttendanceStatus() async {
    try {
      final statusResponse = await _attendanceService.getAttendanceStatus();

      // Update server capabilities
      _canClockInFromServer.value = statusResponse.canClockIn;
      _canClockOutFromServer.value = statusResponse.canClockOut;
      _isWorkingDay.value = statusResponse.isWorkingDay;

      if (statusResponse.isWorkingDay) {
        // Update today's attendance data
        if (statusResponse.todayAttendance != null) {
          _todayAttendance.value = statusResponse.todayAttendance;

          // Determine attendance status based on server data
          if (statusResponse.todayAttendance!.clockOutTime != null) {
            _attendanceStatus.value = AttendanceStatus.completed;
          } else if (statusResponse.todayAttendance!.clockInTime != null) {
            _attendanceStatus.value = AttendanceStatus.clockedIn;
          } else {
            _attendanceStatus.value = AttendanceStatus.notStarted;
          }
        } else {
          // No attendance data for today
          _attendanceStatus.value = AttendanceStatus.notStarted;
          _todayAttendance.value = null;
        }
      } else {
        _attendanceStatus.value = AttendanceStatus.notStarted;
        _todayAttendance.value = null;
      }

      if (kDebugMode) {
        print('✅ Attendance status loaded from server');
        print('Working day: ${_isWorkingDay.value}');
        print('Can clock in: ${_canClockInFromServer.value}');
        print('Can clock out: ${_canClockOutFromServer.value}');
        print('Current status: ${_attendanceStatus.value}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get attendance status error: $e');
      }
      rethrow;
    }
  }

  /// Clock in attendance
  Future<void> clockIn() async {
    if (_isLoading.value) {
      if (kDebugMode) {
        print('⚠️ Clock in already in progress');
      }
      return;
    }

    _isLoading.value = true;

    try {
      // Quick location refresh
      await _getCurrentLocation();
      await _getCurrentAddress();
      _calculateDistance();

      final attendance = await _attendanceService.clockIn(
        latitude: _currentPosition.value!.latitude,
        longitude: _currentPosition.value!.longitude,
        locationAddress: _currentAddress.value,
      );

      // Update state
      _todayAttendance.value = attendance;
      _attendanceStatus.value = AttendanceStatus.clockedIn;
      _canClockInFromServer.value = false;
      _canClockOutFromServer.value = true;

      Get.snackbar(
        'Clock In Successful',
        'You have successfully clocked in',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      if (kDebugMode) {
        print('✅ Clock in successful');
      }
    } catch (e) {
      _handleClockError(e, isClockIn: true);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('🔚 AttendanceController onClose called');
    }
    _attendanceRecords.clear();
    super.onClose();
  }

  /// Clock out attendance
  Future<void> clockOut() async {
    if (_isLoading.value) {
      if (kDebugMode) {
        print('⚠️ Clock out already in progress');
      }
      return;
    }

    _isLoading.value = true;

    try {
      // Quick location refresh
      await _getCurrentLocation();
      await _getCurrentAddress();
      _calculateDistance();

      final attendance = await _attendanceService.clockOut(
        latitude: _currentPosition.value!.latitude,
        longitude: _currentPosition.value!.longitude,
        locationAddress: _currentAddress.value,
        previousAttendance: _todayAttendance.value,
      );

      // Update state
      _todayAttendance.value = attendance;
      _attendanceStatus.value = AttendanceStatus.completed;
      _canClockInFromServer.value = false;
      _canClockOutFromServer.value = false;

      Get.snackbar(
        'Clock Out Successful',
        'You have successfully clocked out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      if (kDebugMode) {
        print('✅ Clock out successful');
      }
    } catch (e) {
      _handleClockError(e, isClockIn: false);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Handle clock errors
  void _handleClockError(dynamic e, {required bool isClockIn}) {
    if (kDebugMode) {
      print('❌ ${isClockIn ? 'Clock in' : 'Clock out'} error: $e');
    }

    String errorMessage = e.toString().replaceAll('Exception: ', '');

    if (errorMessage.contains('outside office radius')) {
      _showOutsideRadiusDialog(isClockIn: isClockIn);
    } else if (errorMessage.contains('non-working day') ||
        errorMessage.contains('Cannot clock in/out on non-working day')) {
      // Update working day status
      _isWorkingDay.value = false;
      _canClockInFromServer.value = false;
      _canClockOutFromServer.value = false;

      Get.snackbar(
        'Not a Working Day',
        'Attendance is not available today. Clock in/out is only allowed on working days.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } else if (errorMessage.contains('already clocked')) {
      // Handle already clocked cases - refresh status from server
      _getAttendanceStatus();

      Get.snackbar(
        'Already ${isClockIn ? 'Clocked In' : 'Clocked Out'}',
        'You have already ${isClockIn ? 'clocked in' : 'clocked out'} today',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        '${isClockIn ? 'Clock In' : 'Clock Out'} Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Show outside radius dialog
  void _showOutsideRadiusDialog({required bool isClockIn}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.location_off_rounded,
              color: const Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Outside Office Area'),
          ],
        ),
        content: Text(
          'You are ${_distance.value.toStringAsFixed(0)}m away from office. '
          'Do you want to proceed with ${isClockIn ? 'Clock In' : 'Clock Out'}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (isClockIn) {
                _allowOutsideRadiusClockIn.value = true;
                clockIn();
                _allowOutsideRadiusClockIn.value = false;
              } else {
                _allowOutsideRadiusClockOut.value = true;
                clockOut();
                _allowOutsideRadiusClockOut.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Proceed',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Refresh location and office data
  Future<void> refreshLocation() async {
    if (_isLoading.value) {
      if (kDebugMode) {
        print('⚠️ Refresh already in progress');
      }
      return;
    }

    _isLoading.value = true;
    try {
      await _getCurrentLocation();
      await _getCurrentAddress();
      await _getOfficeLocation();
      _calculateDistance();

      // Also refresh attendance status from server
      await _getAttendanceStatus();

      Get.snackbar(
        'Location Refreshed',
        'Distance: ${_distance.value.toStringAsFixed(0)}m from office',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Refresh Failed',
        'Failed to refresh location: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Retry initialization
  Future<void> retry() async {
    if (_isInitializing.value) {
      if (kDebugMode) {
        print('⚠️ Initialization already in progress');
      }
      return;
    }

    _isInitialized.value = false;
    await _initializeAttendance();
  }

  /// Manual refresh attendance status from server
  Future<void> refreshAttendanceStatus() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    try {
      await _getAttendanceStatus();

      Get.snackbar(
        'Status Updated',
        'Attendance status refreshed from server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Refresh Failed',
        'Failed to refresh attendance status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
