// models/attendance_history_model.dart
class AttendanceHistoryResponse {
  final bool success;
  final String message;
  final AttendanceHistoryData? data;

  AttendanceHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AttendanceHistoryData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class AttendanceHistoryData {
  final List<AttendanceHistory> attendances;
  final PaginationInfo pagination;

  AttendanceHistoryData({required this.attendances, required this.pagination});

  factory AttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryData(
      attendances:
          (json['attendances'] as List<dynamic>?)
              ?.map((item) => AttendanceHistory.fromJson(item))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendances': attendances.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class AttendanceHistory {
  final int id;
  final String date;
  final String dayName;
  final String? clockIn;
  final String? clockOut;
  final String status;
  final String statusLabel;
  final int workDurationMinutes;
  final double workDurationHours;
  final int overtimeDurationMinutes;
  final double overtimeDurationHours;
  final Office office;
  final String? notes;

  AttendanceHistory({
    required this.id,
    required this.date,
    required this.dayName,
    this.clockIn,
    this.clockOut,
    required this.status,
    required this.statusLabel,
    required this.workDurationMinutes,
    required this.workDurationHours,
    required this.overtimeDurationMinutes,
    required this.overtimeDurationHours,
    required this.office,
    this.notes,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      workDurationMinutes: json['work_duration_minutes'] ?? 0,
      workDurationHours: (json['work_duration_hours'] ?? 0).toDouble(),
      overtimeDurationMinutes: json['overtime_duration_minutes'] ?? 0,
      overtimeDurationHours: (json['overtime_duration_hours'] ?? 0).toDouble(),
      office: Office.fromJson(json['office'] ?? {}),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'day_name': dayName,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'status': status,
      'status_label': statusLabel,
      'work_duration_minutes': workDurationMinutes,
      'work_duration_hours': workDurationHours,
      'overtime_duration_minutes': overtimeDurationMinutes,
      'overtime_duration_hours': overtimeDurationHours,
      'office': office.toJson(),
      'notes': notes,
    };
  }

  // Helper methods
  bool get isPresent => status == 'present';
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';

  bool get hasClockedIn => clockIn != null && clockIn!.isNotEmpty;
  bool get hasClockedOut => clockOut != null && clockOut!.isNotEmpty;

  bool get hasOvertime => overtimeDurationMinutes > 0;

  String get formattedWorkDuration {
    final hours = workDurationMinutes ~/ 60;
    final minutes = workDurationMinutes % 60;
    return '${hours}j ${minutes}m';
  }

  String get formattedOvertimeDuration {
    if (overtimeDurationMinutes == 0) return '0j 0m';
    final hours = overtimeDurationMinutes ~/ 60;
    final minutes = overtimeDurationMinutes % 60;
    return '${hours}j ${minutes}m';
  }

  @override
  String toString() {
    return 'AttendanceHistory{id: $id, date: $date, status: $status, clockIn: $clockIn, clockOut: $clockOut}';
  }
}

class Office {
  final int id;
  final String name;

  Office({required this.id, required this.name});

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return 'Office{id: $id, name: $name}';
  }
}

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
    };
  }

  // Helper methods
  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage == lastPage;

  @override
  String toString() {
    return 'PaginationInfo{currentPage: $currentPage, total: $total, perPage: $perPage}';
  }
}
