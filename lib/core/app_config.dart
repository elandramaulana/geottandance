// lib/core/app_config.dart
import 'package:package_info_plus/package_info_plus.dart';

enum Environment { development, staging, production }

/// Application configuration for different environments
class AppConfig {
  /// Current environment
  static Environment env = Environment.development;
  static String version = '';
  static String buildNumber = '';

  /// Base URLs for each environment
  static const _baseUrls = {
    Environment.development:
        'http://192.168.70.98:8000/api', // untuk Android emulator
    Environment.staging: 'http://127.0.0.1:8000/api', // untuk testing lokal
    Environment.production: 'https://api.example.com/api', // URL production
  };

  /// Get current base URL
  static String get baseUrl => _baseUrls[env]!;

  /// Other global configs
  static const int requestTimeoutSeconds = 30;
  static const bool enableLogging = true;

  /// Initialize app configuration
  static Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version; // contohnya "1.2.3"
    buildNumber = info.buildNumber; // contohnya "45"
  }

  /// Set environment (useful for switching environments)
  static void setEnvironment(Environment environment) {
    env = environment;
  }
}

/// Endpoint paths
class Endpoints {
  static const String login = '/auth/login';
  static const String profile = '/user/profile';
  static const String getOfficeInfo = '/office/location';
  static const String storeAttendance = '/attendance/clock';
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
}
