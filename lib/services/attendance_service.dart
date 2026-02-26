// lib/services/attendance_service.dart
import 'package:flutter/foundation.dart';
import 'package:geottandance/core/app_config.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/models/attendance_model.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final BaseApiProvider _apiProvider = BaseApiProvider();

  /// Get office location from server
  Future<OfficeLocation> getOfficeLocation({
    required double userLatitude,
    required double userLongitude,
  }) async {
    try {
      final requestData = {
        'latitude': userLatitude,
        'longitude': userLongitude,
      };

      if (kDebugMode) {
        print('📤 Office location request: $requestData');
      }

      final response = await _apiProvider
          .post<Map<String, dynamic>>(
            Endpoints.getOfficeInfo,
            data: requestData,
          )
          .timeout(const Duration(seconds: 15));

      if (response.success && response.data != null) {
        final officeLocation = OfficeLocation.fromJson(response.data!);

        if (kDebugMode) {
          print(
            '🏢 Office location loaded: ${officeLocation.latitude}, ${officeLocation.longitude}',
          );
          print('📏 Allowed radius: ${officeLocation.allowedRadius}m');
        }

        return officeLocation;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get office location error: $e');
      }
      rethrow;
    }
  }

  /// Get current attendance status from server
  Future<AttendanceStatusResponse> getAttendanceStatus() async {
    try {
      if (kDebugMode) {
        print('📤 Getting attendance status from server...');
      }

      final response = await _apiProvider
          .get<Map<String, dynamic>>(Endpoints.attendanceStatus)
          .timeout(const Duration(seconds: 15));

      if (response.success && response.data != null) {
        final statusResponse = AttendanceStatusResponse.fromJson(
          response.data!,
        );

        if (kDebugMode) {
          print('✅ Attendance status loaded from server');
          print('Working day: ${statusResponse.isWorkingDay}');
          print('Can clock in: ${statusResponse.canClockIn}');
          print('Can clock out: ${statusResponse.canClockOut}');
        }

        return statusResponse;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get attendance status error: $e');
      }
      rethrow;
    }
  }

  /// Clock in to attendance system
  Future<TodayAttendance> clockIn({
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) async {
    try {
      final requestData = {
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress,
        'action': 'clock_in',
      };

      if (kDebugMode) {
        print('📤 Clock in request: $requestData');
      }

      final response = await _apiProvider
          .post<Map<String, dynamic>>(
            Endpoints.storeAttendance,
            data: requestData,
          )
          .timeout(const Duration(seconds: 30));

      if (response.success && response.data != null) {
        final attendance = TodayAttendance.fromClockInResponse(response.data!);

        if (kDebugMode) {
          print('✅ Clock in successful');
        }

        return attendance;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Clock in error: $e');
      }
      rethrow;
    }
  }

  /// Clock out from attendance system
  Future<TodayAttendance> clockOut({
    required double latitude,
    required double longitude,
    required String locationAddress,
    TodayAttendance? previousAttendance,
  }) async {
    try {
      final requestData = {
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress,
        'action': 'clock_out',
      };

      if (kDebugMode) {
        print('📤 Clock out request: $requestData');
      }

      final response = await _apiProvider
          .post<Map<String, dynamic>>(
            Endpoints.storeAttendance,
            data: requestData,
          )
          .timeout(const Duration(seconds: 30));

      if (response.success && response.data != null) {
        final attendance = TodayAttendance.fromClockOutResponse(
          response.data!,
          previousAttendance,
        );

        if (kDebugMode) {
          print('✅ Clock out successful');
        }

        return attendance;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Clock out error: $e');
      }
      rethrow;
    }
  }
}
