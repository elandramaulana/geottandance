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
