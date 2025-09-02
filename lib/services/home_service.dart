// lib/services/home_service.dart
import 'package:flutter/foundation.dart';
import 'package:geottandance/core/app_config.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/models/home_model.dart';

class HomeService {
  final BaseApiProvider _apiProvider = BaseApiProvider();

  /// Get attendance status for today with enhanced error handling
  Future<ApiResponse<AttendanceStatusModel>> getAttendanceStatus() async {
    try {
      if (kDebugMode) {
        print('🏠 HomeService: Fetching attendance status...');
      }

      final response = await _apiProvider.get<Map<String, dynamic>>(
        Endpoints.attendanceStatus,
      );

      if (kDebugMode) {
        print(
          '🏠 HomeService: Attendance API response: ${response.statusCode}',
        );
        print('🏠 HomeService: Response data: ${response.data}');
      }

      if (response.success && response.data != null) {
        try {
          final attendanceStatus = AttendanceStatusModel.fromJson(
            response.data!,
          );

          if (kDebugMode) {
            print('✅ HomeService: Attendance status parsed successfully');
            print('   - Working day: ${attendanceStatus.isWorkingDay}');
            print('   - Can clock in: ${attendanceStatus.canClockIn}');
            print('   - Can clock out: ${attendanceStatus.canClockOut}');
            print('   - Message: ${attendanceStatus.message}');
          }

          return ApiResponse<AttendanceStatusModel>(
            success: true,
            message: response.message,
            data: attendanceStatus,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          if (kDebugMode) {
            print(
              '❌ HomeService: Failed to parse attendance status: $parseError',
            );
          }

          return ApiResponse<AttendanceStatusModel>(
            success: false,
            message: 'Failed to parse attendance data: $parseError',
            data: null,
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse<AttendanceStatusModel>(
        success: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to get attendance status',
        data: null,
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ HomeService: Exception getting attendance status: $e');
        print('Stack trace: $stackTrace');
      }

      return ApiResponse<AttendanceStatusModel>(
        success: false,
        message: _getErrorMessage(e),
        data: null,
        statusCode: null,
      );
    }
  }

  /// Get recent activities with enhanced error handling
  Future<ApiResponse<List<ActivityModel>>> getRecentActivities({
    String period = 'month',
    String? type,
    int limit = 5,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🏠 HomeService: Fetching recent activities (period: $period, limit: $limit)...',
        );
      }

      final queryParams = <String, dynamic>{
        'period': period,
        'limit': limit.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      if (kDebugMode) {
        print('🏠 HomeService: Query params: $queryParams');
      }

      final response = await _apiProvider.get<List<dynamic>>(
        Endpoints.attendanceActivities,
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print(
          '🏠 HomeService: Activities API response: ${response.statusCode}',
        );
        print(
          '🏠 HomeService: Activities data length: ${response.data?.length ?? 0}',
        );
      }

      if (response.success && response.data != null) {
        try {
          final activities = (response.data as List)
              .map((json) {
                try {
                  return ActivityModel.fromJson(json as Map<String, dynamic>);
                } catch (itemError) {
                  if (kDebugMode) {
                    print(
                      '❌ HomeService: Failed to parse activity item: $itemError',
                    );
                    print('   Item data: $json');
                  }
                  return null;
                }
              })
              .where((activity) => activity != null)
              .cast<ActivityModel>()
              .toList();

          if (kDebugMode) {
            print(
              '✅ HomeService: Activities parsed successfully (${activities.length} items)',
            );
            for (var activity in activities.take(3)) {
              print(
                '   - ${activity.activityType} at ${activity.formattedDate}',
              );
            }
          }

          return ApiResponse<List<ActivityModel>>(
            success: true,
            message: response.message,
            data: activities,
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          if (kDebugMode) {
            print('❌ HomeService: Failed to parse activities: $parseError');
          }

          return ApiResponse<List<ActivityModel>>(
            success: false,
            message: 'Failed to parse activities data: $parseError',
            data: [],
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse<List<ActivityModel>>(
        success: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to get recent activities',
        data: [],
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ HomeService: Exception getting recent activities: $e');
        print('Stack trace: $stackTrace');
      }

      return ApiResponse<List<ActivityModel>>(
        success: false,
        message: _getErrorMessage(e),
        data: [],
        statusCode: null,
      );
    }
  }

  /// Refresh all home data with concurrent fetching and error isolation
  Future<Map<String, dynamic>> refreshHomeData() async {
    try {
      if (kDebugMode) {
        print('🏠 HomeService: Starting refresh home data...');
      }

      // Run both API calls concurrently but handle errors independently
      final attendanceStatusFuture = getAttendanceStatus().catchError((error) {
        if (kDebugMode) {
          print(
            '❌ HomeService: Attendance status error in concurrent call: $error',
          );
        }
        return ApiResponse<AttendanceStatusModel>(
          success: false,
          message: _getErrorMessage(error),
          data: null,
          statusCode: null,
        );
      });

      final recentActivitiesFuture = getRecentActivities(limit: 5).catchError((
        error,
      ) {
        if (kDebugMode) {
          print(
            '❌ HomeService: Recent activities error in concurrent call: $error',
          );
        }
        return ApiResponse<List<ActivityModel>>(
          success: false,
          message: _getErrorMessage(error),
          data: [],
          statusCode: null,
        );
      });

      final results = await Future.wait([
        attendanceStatusFuture,
        recentActivitiesFuture,
      ]);

      if (kDebugMode) {
        print('✅ HomeService: Refresh home data completed');
        print('   - Attendance status success: ${results[0].success}');
        print('   - Activities success: ${results[1].success}');
      }

      return {'attendanceStatus': results[0], 'recentActivities': results[1]};
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ HomeService: Critical error in refreshHomeData: $e');
        print('Stack trace: $stackTrace');
      }

      // Return error responses for both
      return {
        'attendanceStatus': ApiResponse<AttendanceStatusModel>(
          success: false,
          message: _getErrorMessage(e),
          data: null,
          statusCode: null,
        ),
        'recentActivities': ApiResponse<List<ActivityModel>>(
          success: false,
          message: _getErrorMessage(e),
          data: [],
          statusCode: null,
        ),
      };
    }
  }

  /// Get activities with date filtering
  Future<ApiResponse<List<ActivityModel>>> getActivitiesForDate(
    DateTime date,
  ) async {
    try {
      final response = await getRecentActivities(period: 'month', limit: 50);

      if (response.success && response.data != null) {
        final targetDate = DateTime(date.year, date.month, date.day);

        final filteredActivities = response.data!.where((activity) {
          final activityDate = DateTime(
            activity.activityTime.year,
            activity.activityTime.month,
            activity.activityTime.day,
          );
          return activityDate == targetDate;
        }).toList();

        return ApiResponse<List<ActivityModel>>(
          success: true,
          message: 'Activities filtered for ${date.toString().split(' ')[0]}',
          data: filteredActivities,
          statusCode: response.statusCode,
        );
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeService: Error filtering activities by date: $e');
      }

      return ApiResponse<List<ActivityModel>>(
        success: false,
        message: _getErrorMessage(e),
        data: [],
        statusCode: null,
      );
    }
  }

  /// Helper method to convert exceptions to user-friendly messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return 'Request timeout. Please check your internet connection.';
    } else if (errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Network connection failed. Please try again.';
    } else if (errorString.contains('format') ||
        errorString.contains('parse')) {
      return 'Data format error. Please contact support.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('403') ||
        errorString.contains('forbidden')) {
      return 'Access denied. Please contact administrator.';
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'Service not available. Please try again later.';
    } else if (errorString.contains('500') ||
        errorString.contains('server error')) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
