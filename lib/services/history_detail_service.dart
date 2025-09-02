import 'package:flutter/foundation.dart';
import 'package:geottandance/core/app_config.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/models/history_detail_model.dart';

class AttendanceDetailService {
  static final AttendanceDetailService _instance =
      AttendanceDetailService._internal();
  factory AttendanceDetailService() => _instance;
  AttendanceDetailService._internal();

  final BaseApiProvider _apiProvider = BaseApiProvider();

  /// Get attendance detail by ID
  Future<ServiceResponse<AttendanceDetailHistory>> getAttendanceDetail(
    int id,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching attendance detail for ID: $id');
      }

      final response = await _apiProvider.get<Map<String, dynamic>>(
        Endpoints.attendanceDetail.replaceFirst(':id', id.toString()),
      );

      if (response.success && response.data != null) {
        if (kDebugMode) {
          print('📨 Raw data: ${response.data}');
        }

        try {
          // Pastikan data dalam format yang benar
          Map<String, dynamic> rawData;
          if (response.data is Map<String, dynamic>) {
            rawData = response.data!;
          } else {
            throw Exception(
              'Invalid data format: expected Map<String, dynamic>',
            );
          }

          // Parse attendance detail dengan error handling yang lebih baik
          final attendanceDetail = AttendanceDetailHistory.fromJson(rawData);

          if (kDebugMode) {
            print('✅ Attendance detail parsed successfully');
            print('📝 Detail: ${attendanceDetail.toString()}');
          }

          return ServiceResponse<AttendanceDetailHistory>(
            success: true,
            message: response.message,
            data: attendanceDetail,
          );
        } catch (parseError) {
          if (kDebugMode) {
            print('❌ Parse error: $parseError');
            print('📨 Raw data type: ${response.data.runtimeType}');
            print('📨 Raw data content: ${response.data}');
          }

          return ServiceResponse<AttendanceDetailHistory>(
            success: false,
            message: 'Failed to parse attendance detail data: $parseError',
            data: null,
          );
        }
      } else {
        if (kDebugMode) {
          print('❌ API call failed: ${response.message}');
        }

        return ServiceResponse<AttendanceDetailHistory>(
          success: false,
          message: response.message,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Service error: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }

      return ServiceResponse<AttendanceDetailHistory>(
        success: false,
        message: 'Network error. Please check your connection and try again.',
        data: null,
      );
    }
  }

  /// Check if attendance detail exists (optional method for validation)
  Future<ServiceResponse<bool>> checkAttendanceExists(int id) async {
    try {
      if (kDebugMode) {
        print('🔍 Checking if attendance exists for ID: $id');
      }

      final response = await _apiProvider.get<Map<String, dynamic>>(
        '/attendance/history/$id',
      );

      return ServiceResponse<bool>(
        success: true,
        message: response.message,
        data: response.success,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking attendance existence: $e');
      }

      return ServiceResponse<bool>(
        success: false,
        message: 'Failed to check attendance existence',
        data: false,
      );
    }
  }
}

/// Generic service response model
class ServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ServiceResponse{success: $success, message: $message, data: $data, statusCode: $statusCode}';
  }
}
