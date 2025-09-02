// lib/models/attendance_model.dart
class AttendanceModel {
  final int? id;
  final String? clockInTime;
  final String? clockOutTime;
  final String? workDuration;
  final String? status;
  final bool isLate;
  final double? clockInLatitude;
  final double? clockInLongitude;
  final double? clockOutLatitude;
  final double? clockOutLongitude;
  final String? clockInAddress;
  final String? clockOutAddress;
  final DateTime? date;

  AttendanceModel({
    this.id,
    this.clockInTime,
    this.clockOutTime,
    this.workDuration,
    this.status,
    this.isLate = false,
    this.clockInLatitude,
    this.clockInLongitude,
    this.clockOutLatitude,
    this.clockOutLongitude,
    this.clockInAddress,
    this.clockOutAddress,
    this.date,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      clockInTime: json['clock_in_time'],
      clockOutTime: json['clock_out_time'],
      workDuration: json['work_duration'],
      status: json['status'],
      isLate: json['is_late'] ?? false,
      clockInLatitude: json['clock_in_latitude']?.toDouble(),
      clockInLongitude: json['clock_in_longitude']?.toDouble(),
      clockOutLatitude: json['clock_out_latitude']?.toDouble(),
      clockOutLongitude: json['clock_out_longitude']?.toDouble(),
      clockInAddress: json['clock_in_address'],
      clockOutAddress: json['clock_out_address'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clock_in_time': clockInTime,
      'clock_out_time': clockOutTime,
      'work_duration': workDuration,
      'status': status,
      'is_late': isLate,
      'clock_in_latitude': clockInLatitude,
      'clock_in_longitude': clockInLongitude,
      'clock_out_latitude': clockOutLatitude,
      'clock_out_longitude': clockOutLongitude,
      'clock_in_address': clockInAddress,
      'clock_out_address': clockOutAddress,
      'date': date?.toIso8601String(),
    };
  }

  AttendanceModel copyWith({
    int? id,
    String? clockInTime,
    String? clockOutTime,
    String? workDuration,
    String? status,
    bool? isLate,
    double? clockInLatitude,
    double? clockInLongitude,
    double? clockOutLatitude,
    double? clockOutLongitude,
    String? clockInAddress,
    String? clockOutAddress,
    DateTime? date,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      workDuration: workDuration ?? this.workDuration,
      status: status ?? this.status,
      isLate: isLate ?? this.isLate,
      clockInLatitude: clockInLatitude ?? this.clockInLatitude,
      clockInLongitude: clockInLongitude ?? this.clockInLongitude,
      clockOutLatitude: clockOutLatitude ?? this.clockOutLatitude,
      clockOutLongitude: clockOutLongitude ?? this.clockOutLongitude,
      clockInAddress: clockInAddress ?? this.clockInAddress,
      clockOutAddress: clockOutAddress ?? this.clockOutAddress,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel{id: $id, clockInTime: $clockInTime, clockOutTime: $clockOutTime, status: $status, isLate: $isLate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
