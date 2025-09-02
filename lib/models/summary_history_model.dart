// models/summary_history_model.dart
class SummaryHistoryModel {
  final String period;
  final SummarySectionModel summary;

  SummaryHistoryModel({required this.period, required this.summary});

  factory SummaryHistoryModel.fromJson(Map<String, dynamic> json) {
    return SummaryHistoryModel(
      period: json['period']?.toString() ?? '',
      summary: SummarySectionModel.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'period': period, 'summary': summary.toJson()};
  }

  @override
  String toString() {
    return 'SummaryHistoryModel{period: $period, summary: $summary}';
  }

  // Copy with method for updating data
  SummaryHistoryModel copyWith({String? period, SummarySectionModel? summary}) {
    return SummaryHistoryModel(
      period: period ?? this.period,
      summary: summary ?? this.summary,
    );
  }
}

class SummarySectionModel {
  final int totalDays;
  final String presentDays;
  final String lateDays;
  final String absentDays;
  final String leaveDays;
  final String holidayDays;
  final int attendanceRate;
  final int totalWorkHours;
  final int totalOvertimeHours;

  SummarySectionModel({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.leaveDays,
    required this.holidayDays,
    required this.attendanceRate,
    required this.totalWorkHours,
    required this.totalOvertimeHours,
  });

  factory SummarySectionModel.fromJson(Map<String, dynamic> json) {
    return SummarySectionModel(
      totalDays: _parseToInt(json['total_days']),
      presentDays: _parseToString(json['present_days']),
      lateDays: _parseToString(json['late_days']),
      absentDays: _parseToString(json['absent_days']),
      leaveDays: _parseToString(json['leave_days']),
      holidayDays: _parseToString(json['holiday_days']),
      attendanceRate: _parseToInt(json['attendance_rate']),
      totalWorkHours: _parseToInt(json['total_work_hours']),
      totalOvertimeHours: _parseToInt(json['total_overtime_hours']),
    );
  }

  // Helper method to safely parse integer values
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method to safely parse string values
  static String _parseToString(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'absent_days': absentDays,
      'leave_days': leaveDays,
      'holiday_days': holidayDays,
      'attendance_rate': attendanceRate,
      'total_work_hours': totalWorkHours,
      'total_overtime_hours': totalOvertimeHours,
    };
  }

  @override
  String toString() {
    return 'SummarySectionModel{'
        'totalDays: $totalDays, '
        'presentDays: $presentDays, '
        'lateDays: $lateDays, '
        'absentDays: $absentDays, '
        'leaveDays: $leaveDays, '
        'holidayDays: $holidayDays, '
        'attendanceRate: $attendanceRate, '
        'totalWorkHours: $totalWorkHours, '
        'totalOvertimeHours: $totalOvertimeHours'
        '}';
  }

  // Copy with method for updating data
  SummarySectionModel copyWith({
    int? totalDays,
    String? presentDays,
    String? lateDays,
    String? absentDays,
    String? leaveDays,
    String? holidayDays,
    int? attendanceRate,
    int? totalWorkHours,
    int? totalOvertimeHours,
  }) {
    return SummarySectionModel(
      totalDays: totalDays ?? this.totalDays,
      presentDays: presentDays ?? this.presentDays,
      lateDays: lateDays ?? this.lateDays,
      absentDays: absentDays ?? this.absentDays,
      leaveDays: leaveDays ?? this.leaveDays,
      holidayDays: holidayDays ?? this.holidayDays,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      totalWorkHours: totalWorkHours ?? this.totalWorkHours,
      totalOvertimeHours: totalOvertimeHours ?? this.totalOvertimeHours,
    );
  }

  // Computed properties for easier UI usage
  int get presentDaysAsInt => int.tryParse(presentDays) ?? 0;
  int get lateDaysAsInt => int.tryParse(lateDays) ?? 0;
  int get absentDaysAsInt => int.tryParse(absentDays) ?? 0;
  int get leaveDaysAsInt => int.tryParse(leaveDays) ?? 0;
  int get holidayDaysAsInt => int.tryParse(holidayDays) ?? 0;

  // Get total worked days (present + late)
  int get totalWorkedDays => presentDaysAsInt + lateDaysAsInt;

  // Get total non-working days (absent + leave + holiday)
  int get totalNonWorkingDays =>
      absentDaysAsInt + leaveDaysAsInt + holidayDaysAsInt;

  // Check if attendance rate is good (>= 80%)
  bool get hasGoodAttendance => attendanceRate >= 80;

  // FIXED: Calculate attendance grade based on proper formula
  String get attendanceGrade {
    // Calculate actual attendance percentage based on worked days vs total days
    double actualAttendanceRate = _calculateActualAttendanceRate();

    if (actualAttendanceRate >= 95) return 'A+';
    if (actualAttendanceRate >= 90) return 'A';
    if (actualAttendanceRate >= 85) return 'B+';
    if (actualAttendanceRate >= 80) return 'B';
    if (actualAttendanceRate >= 75) return 'C+';
    if (actualAttendanceRate >= 70) return 'C';
    if (actualAttendanceRate >= 60) return 'D';
    return 'F';
  }

  // FIXED: Calculate proper attendance rate
  double _calculateActualAttendanceRate() {
    if (totalDays == 0) return 0.0;

    // Formula: (Present Days / (Total Days - Leave Days - Holiday Days)) * 100
    // But considering late days should reduce the percentage
    int workingDays = totalDays - leaveDaysAsInt - holidayDaysAsInt;
    if (workingDays <= 0) return 0.0;

    // Present days get full score, late days get partial score (e.g., 0.8)
    double effectivePresence = presentDaysAsInt + (lateDaysAsInt * 0.8);

    return (effectivePresence / workingDays) * 100;
  }

  // FIXED: Get corrected attendance rate
  int get correctedAttendanceRate {
    return _calculateActualAttendanceRate().round();
  }

  // Get formatted work hours (with decimal)
  String get formattedWorkHours {
    double hours = totalWorkHours / 8.0; // Assuming 8 hours per day
    return hours.toStringAsFixed(1);
  }

  // Get formatted overtime hours
  String get formattedOvertimeHours {
    if (totalOvertimeHours == 0) return '0';
    return totalOvertimeHours.toString();
  }

  // ADDED: Debug method to check calculation
  String get attendanceDebugInfo {
    return '''
    Total Days: $totalDays
    Present Days: $presentDaysAsInt
    Late Days: $lateDaysAsInt  
    Absent Days: $absentDaysAsInt
    Leave Days: $leaveDaysAsInt
    Holiday Days: $holidayDaysAsInt
    
    Working Days: ${totalDays - leaveDaysAsInt - holidayDaysAsInt}
    Effective Presence: ${presentDaysAsInt + (lateDaysAsInt * 0.8)}
    
    API Attendance Rate: $attendanceRate%
    Calculated Rate: $correctedAttendanceRate%
    Grade: $attendanceGrade
    ''';
  }
}
