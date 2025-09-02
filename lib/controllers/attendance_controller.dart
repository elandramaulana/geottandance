// lib/controllers/attendance_controller.dart - FIXED VERSION
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Enum untuk status attendance
enum AttendanceStatus { notStarted, clockedIn, completed }

// Model untuk Office Location
class OfficeLocation {
  final double latitude;
  final double longitude;
  final double allowedRadius;

  OfficeLocation({
    required this.latitude,
    required this.longitude,
    required this.allowedRadius,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      latitude: (json['office_latitude'] ?? -6.2).toDouble(),
      longitude: (json['office_longitude'] ?? 106.816666).toDouble(),
      allowedRadius: (json['allowed_radius'] ?? 100.0).toDouble(),
    );
  }
}

// Enhanced Model untuk Today's Attendance - FIXED
class TodayAttendance {
  final String? clockInTime;
  final String? clockOutTime;
  final String? workDuration;
  final bool? isClockInLate;
  final String? clockInStatus;
  final String? clockOutStatus;

  TodayAttendance({
    this.clockInTime,
    this.clockOutTime,
    this.workDuration,
    this.isClockInLate,
    this.clockInStatus,
    this.clockOutStatus,
  });

  // FIXED: Factory for API status response
  factory TodayAttendance.fromStatusResponse(Map<String, dynamic> data) {
    final todayAttendance = data['today_attendance'];
    if (todayAttendance != null) {
      return TodayAttendance(
        clockInTime: todayAttendance['clock_in'],
        clockOutTime: todayAttendance['clock_out'],
        workDuration: _calculateDuration(
          todayAttendance['clock_in'],
          todayAttendance['clock_out'],
        ),
        isClockInLate: todayAttendance['status'] == 'late',
        clockInStatus: todayAttendance['status'] ?? 'on_time',
        clockOutStatus: todayAttendance['clock_out'] != null
            ? 'completed'
            : null,
      );
    }
    return TodayAttendance();
  }

  factory TodayAttendance.fromClockInResponse(Map<String, dynamic> data) {
    return TodayAttendance(
      clockInTime: data['clock_in_time'],
      clockOutTime: null,
      workDuration: '0m',
      isClockInLate: data['is_late'] ?? false,
      clockInStatus: data['status'] ?? 'on_time',
      clockOutStatus: null,
    );
  }

  factory TodayAttendance.fromClockOutResponse(
    Map<String, dynamic> data,
    TodayAttendance? previous,
  ) {
    return TodayAttendance(
      clockInTime: previous?.clockInTime ?? 'Earlier',
      clockOutTime: data['clock_out_time'],
      workDuration:
          data['work_duration'] ??
          _calculateDuration(previous?.clockInTime, data['clock_out_time']),
      isClockInLate: previous?.isClockInLate ?? false,
      clockInStatus: previous?.clockInStatus ?? 'completed',
      clockOutStatus: data['status'] ?? 'completed',
    );
  }

  // Helper method to calculate duration
  static String _calculateDuration(String? clockIn, String? clockOut) {
    if (clockIn == null || clockOut == null) return '0m';

    try {
      final inTime = DateFormat('HH:mm:ss').parse(clockIn);
      final outTime = DateFormat('HH:mm:ss').parse(clockOut);
      final duration = outTime.difference(inTime);

      if (duration.inHours > 0) {
        return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
      } else {
        return '${duration.inMinutes}m';
      }
    } catch (e) {
      return '0m';
    }
  }

  // Helper methods for UI display
  String get displayClockInTime => clockInTime ?? 'Not yet';
  String get displayClockOutTime => clockOutTime ?? 'Not yet';
  String get displayWorkDuration => workDuration ?? '0m';

  String get clockInStatusText {
    if (clockInTime == null) return 'Not yet';
    if (isClockInLate == true) return 'Late';
    return 'On Time';
  }

  String get clockOutStatusText {
    if (clockOutTime == null) return 'Not yet';
    return 'Completed';
  }

  Color get clockInStatusColor {
    if (clockInTime == null) return Colors.grey;
    if (isClockInLate == true) return Colors.red;
    return Colors.green;
  }

  Color get clockOutStatusColor {
    if (clockOutTime == null) return Colors.grey;
    return Colors.green;
  }
}

class AttendanceController extends GetxController {
  final BaseApiProvider _apiProvider = BaseApiProvider();

  // Observables
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final Rx<OfficeLocation?> _officeLocation = Rx<OfficeLocation?>(null);
  final RxBool _isLoading = false.obs;
  final RxDouble _distance = 0.0.obs;
  final RxList<AttendanceRecord> _attendanceRecords = <AttendanceRecord>[].obs;
  final Rx<AttendanceStatus> _attendanceStatus =
      AttendanceStatus.notStarted.obs;
  final Rx<TodayAttendance?> _todayAttendance = Rx<TodayAttendance?>(null);
  final RxString _errorMessage = ''.obs;
  final RxString _currentAddress = ''.obs;

  // Add initialization flag to prevent multiple init calls
  final RxBool _isInitialized = false.obs;
  final RxBool _isInitializing = false.obs;

  // Add flags for allowing outside radius actions
  final RxBool _allowOutsideRadiusClockIn = false.obs;
  final RxBool _allowOutsideRadiusClockOut = false.obs;

  // Add working day status
  final RxBool _isWorkingDay = true.obs;

  // NEW: Add server sync flags
  final RxBool _canClockInFromServer = true.obs;
  final RxBool _canClockOutFromServer = false.obs;

  // Getters
  Position? get currentPosition => _currentPosition.value;
  OfficeLocation? get officeLocation => _officeLocation.value;
  bool get isLoading => _isLoading.value;
  double get distance => _distance.value;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceStatus get attendanceStatus => _attendanceStatus.value;
  TodayAttendance? get todayAttendance => _todayAttendance.value;
  String get errorMessage => _errorMessage.value;
  String get currentAddress => _currentAddress.value;
  bool get isWorkingDay => _isWorkingDay.value;

  bool get isWithinRadius {
    if (_officeLocation.value == null || _currentPosition.value == null) {
      return false;
    }
    return _distance.value <= _officeLocation.value!.allowedRadius;
  }

  // FIXED: Improved button state logic with server sync
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

    // Only initialize once
    if (!_isInitialized.value && !_isInitializing.value) {
      _initializeAttendance();
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

  // FIXED: Improved initialization with API status check
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

      await _requestLocationPermission();
      await _getCurrentLocation();
      await _getCurrentAddress();
      await _getOfficeLocation();

      _calculateDistance();

      // FIXED: Get current attendance status from server
      await _getAttendanceStatus();

      _isInitialized.value = true;

      if (kDebugMode) {
        print('✅ Attendance initialization completed successfully');
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      if (kDebugMode) {
        print('❌ Initialize attendance error: $e');
      }

      // Set default office location if API fails
      if (_officeLocation.value == null) {
        _officeLocation.value = OfficeLocation(
          latitude: -6.2,
          longitude: 106.816666,
          allowedRadius: 100.0,
        );
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
    } finally {
      _isLoading.value = false;
      _isInitializing.value = false;
    }
  }

  // NEW: Get attendance status from server
  Future<void> _getAttendanceStatus() async {
    try {
      if (kDebugMode) {
        print('📤 Getting attendance status from server...');
      }

      final response = await _apiProvider
          .get<Map<String, dynamic>>('/attendance/status')
          .timeout(const Duration(seconds: 15));

      if (response.success && response.data != null) {
        final data = response.data!;

        // Update server capabilities
        _canClockInFromServer.value = data['can_clock_in'] ?? true;
        _canClockOutFromServer.value = data['can_clock_out'] ?? false;

        // Check if it's a working day
        final message = data['message'] ?? '';
        if (message.contains('not a working day')) {
          _isWorkingDay.value = false;
          _attendanceStatus.value = AttendanceStatus.notStarted;
          _todayAttendance.value = null;
        } else {
          _isWorkingDay.value = true;

          // Update today's attendance data
          if (data['today_attendance'] != null) {
            _todayAttendance.value = TodayAttendance.fromStatusResponse(data);

            // Determine attendance status based on server data
            final todayData = data['today_attendance'];
            if (todayData['clock_out'] != null) {
              _attendanceStatus.value = AttendanceStatus.completed;
            } else if (todayData['clock_in'] != null) {
              _attendanceStatus.value = AttendanceStatus.clockedIn;
            } else {
              _attendanceStatus.value = AttendanceStatus.notStarted;
            }
          } else {
            // No attendance data for today
            _attendanceStatus.value = AttendanceStatus.notStarted;
            _todayAttendance.value = null;
          }
        }

        // Save the current state to local storage
        await _saveAttendanceStatus();

        if (kDebugMode) {
          print('✅ Attendance status loaded from server');
          print('Working day: ${_isWorkingDay.value}');
          print('Can clock in: ${_canClockInFromServer.value}');
          print('Can clock out: ${_canClockOutFromServer.value}');
          print('Current status: ${_attendanceStatus.value}');
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get attendance status error: $e');
      }

      // Fallback: Check local storage for today's data
      await _checkAndRestoreLocalData();
    }
  }

  // NEW: Check and restore local data as fallback
  Future<void> _checkAndRestoreLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastAttendanceDate = prefs.getString('last_attendance_date');

      if (kDebugMode) {
        print('📅 Fallback: Today: $today, Last date: $lastAttendanceDate');
      }

      if (lastAttendanceDate == today) {
        // Same day - restore attendance status from storage
        final savedStatus = prefs.getInt('attendance_status') ?? 0;
        _attendanceStatus.value = AttendanceStatus.values[savedStatus];

        // Restore today's attendance data if exists
        final clockInTime = prefs.getString('today_clock_in_time');
        final clockOutTime = prefs.getString('today_clock_out_time');
        final workDuration = prefs.getString('today_work_duration');
        final isLate = prefs.getBool('today_is_late') ?? false;

        if (clockInTime != null) {
          _todayAttendance.value = TodayAttendance(
            clockInTime: clockInTime,
            clockOutTime: clockOutTime,
            workDuration: workDuration ?? '0m',
            isClockInLate: isLate,
            clockInStatus: isLate ? 'late' : 'on_time',
            clockOutStatus: clockOutTime != null ? 'completed' : null,
          );

          // Update server capabilities based on local data
          _canClockInFromServer.value = false;
          _canClockOutFromServer.value = clockOutTime == null;
        }

        if (kDebugMode) {
          print(
            '📱 Restored attendance status from local storage: ${_attendanceStatus.value}',
          );
        }
      } else {
        // New day - reset everything
        _attendanceStatus.value = AttendanceStatus.notStarted;
        _todayAttendance.value = null;
        _isWorkingDay.value = true;
        _canClockInFromServer.value = true;
        _canClockOutFromServer.value = false;

        await prefs.setString('last_attendance_date', today);

        if (kDebugMode) {
          print('🔄 New day detected - attendance status reset');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error restoring local data: $e');
      }
    }
  }

  // UPDATED: Save attendance status to storage
  Future<void> _saveAttendanceStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await prefs.setString('last_attendance_date', today);
      await prefs.setInt('attendance_status', _attendanceStatus.value.index);

      // Save today's attendance data
      if (_todayAttendance.value != null) {
        final attendance = _todayAttendance.value!;
        if (attendance.clockInTime != null) {
          await prefs.setString('today_clock_in_time', attendance.clockInTime!);
          await prefs.setBool(
            'today_is_late',
            attendance.isClockInLate ?? false,
          );
        }
        if (attendance.clockOutTime != null) {
          await prefs.setString(
            'today_clock_out_time',
            attendance.clockOutTime!,
          );
        }
        if (attendance.workDuration != null) {
          await prefs.setString(
            'today_work_duration',
            attendance.workDuration!,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving attendance status: $e');
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      if (kDebugMode) {
        print('✅ Location permission granted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Location permission error: $e');
      }
      rethrow;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 30),
      );

      final Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () async {
              if (kDebugMode) {
                print('⏰ Location timeout, trying last known position...');
              }
              final lastPosition = await Geolocator.getLastKnownPosition();
              if (lastPosition != null) {
                return lastPosition;
              }
              throw Exception('Location timeout and no last known position');
            },
          );

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

  Future<void> _getOfficeLocation() async {
    try {
      final requestData = {
        'latitude': _currentPosition.value?.latitude ?? -6.2,
        'longitude': _currentPosition.value?.longitude ?? 106.816666,
      };

      if (kDebugMode) {
        print('📤 Office location request: $requestData');
      }

      final response = await _apiProvider
          .post<Map<String, dynamic>>('/office/location', data: requestData)
          .timeout(const Duration(seconds: 15));

      if (response.success && response.data != null) {
        _officeLocation.value = OfficeLocation.fromJson(response.data!);

        if (kDebugMode) {
          print(
            '🏢 Office location loaded: ${_officeLocation.value!.latitude}, ${_officeLocation.value!.longitude}',
          );
          print('📏 Allowed radius: ${_officeLocation.value!.allowedRadius}m');
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get office location error: $e');
      }
      // Use default location instead of throwing
      _officeLocation.value = OfficeLocation(
        latitude: -6.2,
        longitude: 106.816666,
        allowedRadius: 100.0,
      );
      if (kDebugMode) {
        print('🏢 Using default office location');
      }
    }
  }

  void _calculateDistance() {
    if (_currentPosition.value == null || _officeLocation.value == null) {
      _distance.value = double.infinity;
      return;
    }

    try {
      final double distanceInMeters = Geolocator.distanceBetween(
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

  // FIXED: Clock In with server status update
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

      final requestData = {
        'latitude': _currentPosition.value!.latitude,
        'longitude': _currentPosition.value!.longitude,
        'location_address': _currentAddress.value,
        'action': 'clock_in',
      };

      if (kDebugMode) {
        print('📤 Clock in request: $requestData');
      }

      final response = await _apiProvider
          .post<Map<String, dynamic>>('/attendance/clock', data: requestData)
          .timeout(const Duration(seconds: 30));

      if (response.success && response.data != null) {
        // Update today's attendance
        _todayAttendance.value = TodayAttendance.fromClockInResponse(
          response.data!,
        );

        // Update attendance status and server capabilities
        _attendanceStatus.value = AttendanceStatus.clockedIn;
        _canClockInFromServer.value = false;
        _canClockOutFromServer.value = true;

        // Save to storage
        await _saveAttendanceStatus();

        Get.snackbar(
          'Clock In Successful',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        if (kDebugMode) {
          print('✅ Clock in successful');
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleClockError(e, isClockIn: true);
    } finally {
      _isLoading.value = false;
    }
  }

  // FIXED: Clock Out with server status update
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

      final requestData = {
        'latitude': _currentPosition.value!.latitude,
        'longitude': _currentPosition.value!.longitude,
        'location_address': _currentAddress.value,
        'action': 'clock_out',
      };

      if (kDebugMode) {
        print('📤 Clock out request: $requestData');
      }

      final response = await _apiProvider
          .post<Map<String, dynamic>>('/attendance/clock', data: requestData)
          .timeout(const Duration(seconds: 30));

      if (response.success && response.data != null) {
        // Update today's attendance
        _todayAttendance.value = TodayAttendance.fromClockOutResponse(
          response.data!,
          _todayAttendance.value,
        );

        // Update attendance status and server capabilities
        _attendanceStatus.value = AttendanceStatus.completed;
        _canClockInFromServer.value = false;
        _canClockOutFromServer.value = false;

        // Save to storage
        await _saveAttendanceStatus();

        Get.snackbar(
          'Clock Out Successful',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        if (kDebugMode) {
          print('✅ Clock out successful');
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleClockError(e, isClockIn: false);
    } finally {
      _isLoading.value = false;
    }
  }

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

  // UPDATED: Refresh with server status sync
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

  // NEW: Manual refresh attendance status from server
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

// Model untuk Attendance Record (unchanged)
class AttendanceRecord {
  final int id;
  final String type;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;
  final bool isLate;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isLate,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['attendance_id'] ?? 0,
      type: json['action'] ?? 'clock_in',
      timestamp: DateTime.now(),
      latitude: 0.0,
      longitude: 0.0,
      address: json['location'] ?? '',
      isLate: json['is_late'] ?? false,
      status: json['status'] ?? '',
    );
  }
}
