// services/attendance_history_service.dart
import 'package:flutter/foundation.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/models/history_model.dart';
import 'package:geottandance/core/app_config.dart';

class AttendanceHistoryService {
  static final AttendanceHistoryService _instance =
      AttendanceHistoryService._internal();
  factory AttendanceHistoryService() => _instance;
  AttendanceHistoryService._internal();

  final BaseApiProvider _apiProvider = BaseApiProvider();

  // Get attendance history
  Future<AttendanceHistoryResponse> getAttendanceHistory({
    int? page,
    int? perPage,
    String? startDate,
    String? endDate,
    String? status,
    String? month,
    String? year,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      if (kDebugMode) {
        print('📅 Fetching attendance history with params: $queryParams');
      }

      final response = await _apiProvider.get<Map<String, dynamic>>(
        Endpoints.attendanceHistory,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.success && response.data != null) {
        final historyResponse = AttendanceHistoryResponse.fromJson({
          'success': response.success,
          'message': response.message,
          'data': response.data,
        });

        if (kDebugMode) {
          print(
            '✅ Attendance history loaded: ${historyResponse.data?.attendances.length} records',
          );
          print(
            '📊 Pagination: Page ${historyResponse.data?.pagination.currentPage} of ${historyResponse.data?.pagination.lastPage}',
          );
        }

        return historyResponse;
      } else {
        return AttendanceHistoryResponse(
          success: false,
          message: response.message,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getAttendanceHistory: $e');
      }

      return AttendanceHistoryResponse(
        success: false,
        message: 'Failed to load attendance history: ${e.toString()}',
        data: null,
      );
    }
  }

  // Get attendance history for current month
  Future<AttendanceHistoryResponse> getCurrentMonthHistory() async {
    final now = DateTime.now();
    return getAttendanceHistory(
      month: now.month.toString().padLeft(2, '0'),
      year: now.year.toString(),
    );
  }

  // Get attendance history for specific month and year
  Future<AttendanceHistoryResponse> getMonthlyHistory(
    int year,
    int month,
  ) async {
    return getAttendanceHistory(
      month: month.toString().padLeft(2, '0'),
      year: year.toString(),
    );
  }

  // Get attendance history with date range
  Future<AttendanceHistoryResponse> getHistoryByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? page,
    int? perPage,
  }) async {
    return getAttendanceHistory(
      startDate: _formatDate(startDate),
      endDate: _formatDate(endDate),
      page: page,
      perPage: perPage,
    );
  }

  // Get attendance history filtered by status
  Future<AttendanceHistoryResponse> getHistoryByStatus(
    String status, {
    int? page,
    int? perPage,
    String? month,
    String? year,
  }) async {
    return getAttendanceHistory(
      status: status,
      page: page,
      perPage: perPage,
      month: month,
      year: year,
    );
  }

  // Get attendance statistics
  Future<AttendanceStatistics> getAttendanceStatistics({
    String? month,
    String? year,
  }) async {
    try {
      final response = await getAttendanceHistory(
        month: month,
        year: year,
        perPage: 1000, // Get all records for statistics
      );

      if (response.success && response.data != null) {
        return _calculateStatistics(response.data!.attendances);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating statistics: $e');
      }
      rethrow;
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Calculate attendance statistics
  AttendanceStatistics _calculateStatistics(
    List<AttendanceHistory> attendances,
  ) {
    int presentCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int totalWorkMinutes = 0;
    int totalOvertimeMinutes = 0;

    for (final attendance in attendances) {
      switch (attendance.status) {
        case 'present':
          presentCount++;
          break;
        case 'late':
          lateCount++;
          break;
        case 'absent':
          absentCount++;
          break;
      }

      totalWorkMinutes += attendance.workDurationMinutes;
      totalOvertimeMinutes += attendance.overtimeDurationMinutes;
    }

    return AttendanceStatistics(
      totalDays: attendances.length,
      presentDays: presentCount,
      lateDays: lateCount,
      absentDays: absentCount,
      totalWorkHours: totalWorkMinutes / 60,
      totalOvertimeHours: totalOvertimeMinutes / 60,
      attendanceRate: attendances.isNotEmpty
          ? (presentCount + lateCount) / attendances.length * 100
          : 0,
    );
  }
}

// Model for attendance statistics
class AttendanceStatistics {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final double totalWorkHours;
  final double totalOvertimeHours;
  final double attendanceRate;

  AttendanceStatistics({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.totalWorkHours,
    required this.totalOvertimeHours,
    required this.attendanceRate,
  });

  String get formattedTotalWorkHours {
    final hours = totalWorkHours.floor();
    final minutes = ((totalWorkHours - hours) * 60).round();
    return '${hours}j ${minutes}m';
  }

  String get formattedTotalOvertimeHours {
    final hours = totalOvertimeHours.floor();
    final minutes = ((totalOvertimeHours - hours) * 60).round();
    return '${hours}j ${minutes}m';
  }

  String get formattedAttendanceRate {
    return '${attendanceRate.toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'AttendanceStatistics{totalDays: $totalDays, presentDays: $presentDays, lateDays: $lateDays, absentDays: $absentDays, attendanceRate: $formattedAttendanceRate}';
  }
}
