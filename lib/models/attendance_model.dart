// lib/models/attendance_models.dart
import 'package:flutter/material.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'office_latitude': latitude,
      'office_longitude': longitude,
      'allowed_radius': allowedRadius,
    };
  }

  // Default office location
  static OfficeLocation get defaultLocation => OfficeLocation(
    latitude: -6.2,
    longitude: 106.816666,
    allowedRadius: 100.0,
  );
}

// Enhanced Model untuk Today's Attendance
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

  // Factory for API status response
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

// Model untuk Attendance Record
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
      id: json['attendance_id'] ?? json['id'] ?? 0,
      type: json['action'] ?? json['type'] ?? 'clock_in',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address:
          json['location'] ?? json['address'] ?? json['location_address'] ?? '',
      isLate: json['is_late'] ?? false,
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': id,
      'action': type,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': address,
      'is_late': isLate,
      'status': status,
    };
  }

  // Helper getters untuk UI
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  bool get isClockIn => type.toLowerCase() == 'clock_in';
  bool get isClockOut => type.toLowerCase() == 'clock_out';

  String get displayType => isClockIn ? 'Clock In' : 'Clock Out';

  String get statusText {
    if (isLate) return 'Late';
    return status.replaceAll('_', ' ').toUpperCase();
  }
}

// Response model for attendance status
class AttendanceStatusResponse {
  final bool canClockIn;
  final bool canClockOut;
  final bool isWorkingDay;
  final String message;
  final TodayAttendance? todayAttendance;

  AttendanceStatusResponse({
    required this.canClockIn,
    required this.canClockOut,
    required this.isWorkingDay,
    required this.message,
    this.todayAttendance,
  });

  factory AttendanceStatusResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? '';
    final isWorkingDay = !message.contains('not a working day');

    return AttendanceStatusResponse(
      canClockIn: json['can_clock_in'] ?? true,
      canClockOut: json['can_clock_out'] ?? false,
      isWorkingDay: isWorkingDay,
      message: message,
      todayAttendance: json['today_attendance'] != null
          ? TodayAttendance.fromStatusResponse(json)
          : null,
    );
  }
}
