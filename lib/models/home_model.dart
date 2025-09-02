// lib/models/home_model.dart
import 'package:flutter/material.dart';

class AttendanceStatusModel {
  final bool canClockIn;
  final bool canClockOut;
  final String message;
  final String? employeeName;
  final String? officeName;
  final TodayAttendanceModel? todayAttendance;
  final OvertimeInfoModel? overtimeInfo;

  AttendanceStatusModel({
    required this.canClockIn,
    required this.canClockOut,
    required this.message,
    this.employeeName,
    this.officeName,
    this.todayAttendance,
    this.overtimeInfo,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceStatusModel(
        canClockIn: json['can_clock_in'] ?? false,
        canClockOut: json['can_clock_out'] ?? false,
        message: json['message'] ?? '',
        employeeName: json['employee_name'],
        officeName: json['office_name'],
        todayAttendance: json['today_attendance'] != null
            ? TodayAttendanceModel.fromJson(json['today_attendance'])
            : null,
        overtimeInfo: json['overtime_info'] != null
            ? OvertimeInfoModel.fromJson(json['overtime_info'])
            : null,
      );
    } catch (e) {
      throw Exception('Failed to parse AttendanceStatusModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'can_clock_in': canClockIn,
      'can_clock_out': canClockOut,
      'message': message,
      'employee_name': employeeName,
      'office_name': officeName,
      'today_attendance': todayAttendance?.toJson(),
      'overtime_info': overtimeInfo?.toJson(),
    };
  }

  // Fixed logic: working day check should be based on message content
  bool get isWorkingDay => !message.toLowerCase().contains('not a working day');

  // Fixed logic: check if both clock in and out are done for today
  bool get hasCompletedAttendance =>
      todayAttendance != null &&
      todayAttendance!.clockIn != null &&
      todayAttendance!.clockOut != null;
}

class TodayAttendanceModel {
  final String? clockIn;
  final String? clockOut;
  final String? status;

  TodayAttendanceModel({this.clockIn, this.clockOut, this.status});

  factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    try {
      return TodayAttendanceModel(
        clockIn: json['clock_in']?.toString(),
        clockOut: json['clock_out']?.toString(),
        status: json['status']?.toString(),
      );
    } catch (e) {
      throw Exception('Failed to parse TodayAttendanceModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {'clock_in': clockIn, 'clock_out': clockOut, 'status': status};
  }

  // Only show time if actually clocked in
  String get displayClockInTime {
    if (clockIn == null || clockIn!.isEmpty) return '--:--';
    return clockIn!;
  }

  // Only show time if actually clocked out
  String get displayClockOutTime {
    if (clockOut == null || clockOut!.isEmpty) return '--:--';
    return clockOut!;
  }

  String get clockInStatusText {
    if (clockIn == null || clockIn!.isEmpty) return 'Pending';
    return status?.toUpperCase() ?? 'COMPLETED';
  }

  String get clockOutStatusText {
    if (clockOut == null || clockOut!.isEmpty) return 'Pending';
    return 'COMPLETED';
  }

  Color get clockInStatusColor {
    if (clockIn == null || clockIn!.isEmpty) return Colors.grey[400]!;
    switch (status?.toLowerCase()) {
      case 'late':
        return Color(0xFFEA580C);
      case 'on time':
        return Color(0xFF10B981);
      case 'early':
        return Color(0xFF7C3AED);
      default:
        return Color(0xFF10B981);
    }
  }

  Color get clockOutStatusColor {
    if (clockOut == null || clockOut!.isEmpty) return Colors.grey[400]!;
    return Color(0xFFEF4444);
  }
}

class OvertimeInfoModel {
  final bool hasApprovedOvertime;
  final dynamic approvedOvertime;
  final bool hasPendingOvertime;
  final dynamic pendingOvertime;
  final bool canRequestOvertime;

  OvertimeInfoModel({
    required this.hasApprovedOvertime,
    this.approvedOvertime,
    required this.hasPendingOvertime,
    this.pendingOvertime,
    required this.canRequestOvertime,
  });

  factory OvertimeInfoModel.fromJson(Map<String, dynamic> json) {
    try {
      return OvertimeInfoModel(
        hasApprovedOvertime: json['has_approved_overtime'] ?? false,
        approvedOvertime: json['approved_overtime'],
        hasPendingOvertime: json['has_pending_overtime'] ?? false,
        pendingOvertime: json['pending_overtime'],
        canRequestOvertime: json['can_request_overtime'] ?? false,
      );
    } catch (e) {
      throw Exception('Failed to parse OvertimeInfoModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'has_approved_overtime': hasApprovedOvertime,
      'approved_overtime': approvedOvertime,
      'has_pending_overtime': hasPendingOvertime,
      'pending_overtime': pendingOvertime,
      'can_request_overtime': canRequestOvertime,
    };
  }
}

// Model for Recent Activities
class ActivityModel {
  final int id;
  final int employeeId;
  final String activityType;
  final String title;
  final String description;
  final String? latitude;
  final String? longitude;
  final String? locationAddress;
  final DateTime activityTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.employeeId,
    required this.activityType,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    this.locationAddress,
    required this.activityTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    try {
      return ActivityModel(
        id: json['id'] ?? 0,
        employeeId: json['employee_id'] ?? 0,
        activityType: json['activity_type'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        latitude: json['latitude']?.toString(),
        longitude: json['longitude']?.toString(),
        locationAddress: json['location_address']?.toString(),
        activityTime: DateTime.parse(
          json['activity_time'] ?? DateTime.now().toIso8601String(),
        ),
        createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      throw Exception('Failed to parse ActivityModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'activity_type': activityType,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'activity_time': activityTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedTime {
    return "${activityTime.hour.toString().padLeft(2, '0')}:${activityTime.minute.toString().padLeft(2, '0')}";
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = DateTime(
      activityTime.year,
      activityTime.month,
      activityTime.day,
    );

    if (activityDate == today) {
      return formattedTime;
    } else if (activityDate == today.subtract(Duration(days: 1))) {
      return '1d ago';
    } else {
      final difference = today.difference(activityDate).inDays;
      if (difference < 7) {
        return '${difference}d ago';
      } else {
        return '${difference ~/ 7}w ago';
      }
    }
  }

  String get statusFromActivityType {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return 'completed';
      case 'clock_out':
        return 'completed';
      case 'visit_requested':
        return 'pending';
      default:
        return 'completed';
    }
  }

  Color get activityColor {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return Color(0xFF059669);
      case 'clock_out':
        return Color(0xFFEF4444);
      case 'visit_requested':
        return Color(0xFF2563EB);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData get activityIcon {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return Icons.login;
      case 'clock_out':
        return Icons.logout;
      case 'visit_requested':
        return Icons.location_on;
      default:
        return Icons.work;
    }
  }

  String get shortLocationAddress {
    if (locationAddress == null || locationAddress!.isEmpty) {
      return 'No location';
    }
    // Extract the first part before comma for shorter display
    final parts = locationAddress!.split(',');
    final firstPart = parts.isNotEmpty ? parts.first.trim() : locationAddress!;
    return firstPart.length > 30
        ? '${firstPart.substring(0, 30)}...'
        : firstPart;
  }

  // Check if this activity is for today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = DateTime(
      activityTime.year,
      activityTime.month,
      activityTime.day,
    );
    return activityDate == today;
  }
}
