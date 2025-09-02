// lib/core/app_config.dart
import 'package:package_info_plus/package_info_plus.dart';

enum Environment { development, staging, production }

/// Application configuration for different environments
class AppConfig {
  /// Current environment
  static Environment env = Environment.staging;
  static String version = '';
  static String buildNumber = '';

  /// Base URLs for each environment
  // static const _baseUrls = {
  //   Environment.staging: 'http://127.0.0.1:8000/api',
  //   Environment.production: 'https://api.example.com',
  // };

  // /// Get current base URL
  // static String get baseUrl => _baseUrls[env]!;

  /// Other global configs
  static const int requestTimeoutSeconds = 30;
  static const bool enableLogging = true;

  static Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version; // contohnya "1.2.3"
    buildNumber = info.buildNumber; // contohnya "45"
  }
}

/// Endpoint paths
class Endpoints {
  static const String login = '/auth/login';
  static const String profile = '/user/profile';
  static const String getOfficeInfo = '/office/location';
  static const String store_attendance = '/attendance/clock';
  static const String attendanceStatus = '/attendance/status';
  static const String attendanceActivities = '/attendance/activities';
  static const String correction = '/attendance/user/correction';
  static const String submission = '/submissions';
  static const String approval = '/approval_list';
  static const String approvalAction = '/approval_action';
  static const String overtime = '/user/store_overtime';
  static const String updateProfile = '/change_photo';
  static const String cuti = '/user/leave_history';
  static const String sickPermit = '/user/sick_history';
  static const String overtimeList = '/user/overtime_history';
  static const String historyCorrection = '/user/attendance_corrections';
  static const String logout = '/auth/logout';
  static const String attendanceSummary = '/attendance/history/summary';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceDetail = '/attendance/history/:id';

  // Helper method to get summary URL with month parameter
  static String getAttendanceSummaryUrl({int? month}) {
    final currentMonth = month ?? DateTime.now().month;
    return '$attendanceSummary?month=$currentMonth';
  }

  /// Get attendance detail URL with ID
  static String getAttendanceDetailUrl(int id) {
    return attendanceDetail.replaceAll(':id', id.toString());
  }

  /// Get attendance history URL with optional filters
  static String getAttendanceHistoryUrl({
    int? month,
    int? year,
    int? page,
    int? limit,
  }) {
    final params = <String>[];

    if (month != null) params.add('month=$month');
    if (year != null) params.add('year=$year');
    if (page != null) params.add('page=$page');
    if (limit != null) params.add('limit=$limit');

    return params.isEmpty
        ? attendanceHistory
        : '$attendanceHistory?${params.join('&')}';
  }

  /// Get attendance activities URL with optional filters
  static String getAttendanceActivitiesUrl({
    String? period,
    String? type,
    int? limit,
  }) {
    final params = <String>[];

    if (period != null) params.add('period=$period');
    if (type != null) params.add('type=$type');
    if (limit != null) params.add('limit=$limit');

    return params.isEmpty
        ? attendanceActivities
        : '$attendanceActivities?${params.join('&')}';
  }
}
