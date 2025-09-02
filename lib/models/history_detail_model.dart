class AttendanceDetailHistory {
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
  final AttendanceOffice office;
  final String notes;
  final AttendanceLocation clockInLocation;
  final AttendanceLocation clockOutLocation;
  final String createdAt;
  final String updatedAt;

  AttendanceDetailHistory({
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
    required this.notes,
    required this.clockInLocation,
    required this.clockOutLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceDetailHistory.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceDetailHistory(
        id: _parseInt(json['id']) ?? 0,
        date: _parseString(json['date']) ?? '',
        dayName: _parseString(json['day_name']) ?? '',
        clockIn: _parseString(json['clock_in']),
        clockOut: _parseString(json['clock_out']),
        status: _parseString(json['status']) ?? '',
        statusLabel: _parseString(json['status_label']) ?? '',
        workDurationMinutes: _parseInt(json['work_duration_minutes']) ?? 0,
        workDurationHours: _parseDouble(json['work_duration_hours']) ?? 0.0,
        overtimeDurationMinutes:
            _parseInt(json['overtime_duration_minutes']) ?? 0,
        overtimeDurationHours:
            _parseDouble(json['overtime_duration_hours']) ?? 0.0,
        office: AttendanceOffice.fromJson(_parseMap(json['office']) ?? {}),
        notes: _parseString(json['notes']) ?? '',
        clockInLocation: AttendanceLocation.fromJson(
          _parseMap(json['clock_in_location']) ?? {},
        ),
        clockOutLocation: AttendanceLocation.fromJson(
          _parseMap(json['clock_out_location']) ?? {},
        ),
        createdAt: _parseString(json['created_at']) ?? '',
        updatedAt: _parseString(json['updated_at']) ?? '',
      );
    } catch (e) {
      print('❌ Error parsing AttendanceDetailHistory: $e');
      print('📨 JSON data: $json');
      rethrow;
    }
  }

  // Helper parsing methods
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  static Map<String, dynamic>? _parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
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
      'clock_in_location': clockInLocation.toJson(),
      'clock_out_location': clockOutLocation.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Format duration untuk display
  String get formattedWorkDuration {
    if (workDurationMinutes == 0) return '0h 0m';

    final hours = workDurationMinutes ~/ 60;
    final minutes = workDurationMinutes % 60;

    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String get formattedOvertimeDuration {
    if (overtimeDurationMinutes == 0) return '0h 0m';

    final hours = overtimeDurationMinutes ~/ 60;
    final minutes = overtimeDurationMinutes % 60;

    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  // Format waktu yang lebih user-friendly
  String get workDurationDisplay {
    if (workDurationMinutes == 0) return 'No work time recorded';

    final hours = workDurationMinutes ~/ 60;
    final minutes = workDurationMinutes % 60;

    if (hours == 0) {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    } else if (minutes == 0) {
      return '$hours hour${hours != 1 ? 's' : ''}';
    } else {
      return '$hours hour${hours != 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}';
    }
  }

  String get overtimeDurationDisplay {
    if (overtimeDurationMinutes == 0) return 'No overtime';

    final hours = overtimeDurationMinutes ~/ 60;
    final minutes = overtimeDurationMinutes % 60;

    if (hours == 0) {
      return '$minutes minute${minutes != 1 ? 's' : ''} overtime';
    } else if (minutes == 0) {
      return '$hours hour${hours != 1 ? 's' : ''} overtime';
    } else {
      return '$hours hour${hours != 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''} overtime';
    }
  }

  // Boolean helpers
  bool get hasClockIn => clockIn != null && clockIn!.isNotEmpty;
  bool get hasClockOut => clockOut != null && clockOut!.isNotEmpty;
  bool get hasLocation =>
      clockInLocation.hasCoordinates || clockOutLocation.hasCoordinates;
  bool get isComplete => hasClockIn && hasClockOut;

  // Display helpers
  String get displayClockIn => clockIn ?? '--:--';
  String get displayClockOut => clockOut ?? '--:--';

  // Status helpers
  bool get isPresent => status.toLowerCase() == 'present';
  bool get isLate => status.toLowerCase() == 'late';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isSick => status.toLowerCase() == 'sick';
  bool get isHoliday => status.toLowerCase() == 'holiday';

  // Overtime check
  bool get hasOvertime => overtimeDurationMinutes > 0;

  @override
  String toString() {
    return 'AttendanceDetailHistory{id: $id, date: $date, status: $status, clockIn: $clockIn, clockOut: $clockOut}';
  }
}

class AttendanceLocation {
  final double? latitude;
  final double? longitude;
  final String? address;

  AttendanceLocation({this.latitude, this.longitude, this.address});

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceLocation(
        latitude: _parseDouble(json['latitude']),
        longitude: _parseDouble(json['longitude']),
        address: _parseString(json['address']),
      );
    } catch (e) {
      print('❌ Error parsing AttendanceLocation: $e');
      print('📨 JSON data: $json');
      // Return empty location instead of throwing
      return AttendanceLocation();
    }
  }

  // Helper parsing methods
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasAddress => address != null && address!.isNotEmpty;

  String get displayAddress => hasAddress ? address! : 'Location not available';

  // Helper untuk mendapatkan koordinat sebagai string
  String get coordinatesString {
    if (!hasCoordinates) return 'No coordinates';
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  @override
  String toString() {
    return 'AttendanceLocation{latitude: $latitude, longitude: $longitude, address: $address}';
  }
}

class AttendanceOffice {
  final int id;
  final String name;

  AttendanceOffice({required this.id, required this.name});

  factory AttendanceOffice.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceOffice(
        id: _parseInt(json['id']) ?? 0,
        name: _parseString(json['name']) ?? '',
      );
    } catch (e) {
      print('❌ Error parsing AttendanceOffice: $e');
      print('📨 JSON data: $json');
      // Return default office instead of throwing
      return AttendanceOffice(id: 0, name: 'Unknown Office');
    }
  }

  // Helper parsing methods
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  // Helper untuk check apakah office data valid
  bool get isValid => id > 0 && name.isNotEmpty;

  // Helper untuk mendapatkan nama office yang sudah di-translate
  String get displayName {
    return name
        .replaceAll('Kantor Pusat', 'Head Office')
        .replaceAll('Kantor Cabang', 'Branch Office')
        .replaceAll('Kantor', 'Office')
        .replaceAll('Gedung', 'Building')
        .replaceAll('Lantai', 'Floor')
        .replaceAll('Jakarta Pusat', 'Central Jakarta')
        .replaceAll('Jakarta Selatan', 'South Jakarta')
        .replaceAll('Jakarta Utara', 'North Jakarta')
        .replaceAll('Jakarta Barat', 'West Jakarta')
        .replaceAll('Jakarta Timur', 'East Jakarta');
  }

  @override
  String toString() {
    return 'AttendanceOffice{id: $id, name: $name}';
  }
}

// Extension untuk AttendanceDetailHistory untuk tambahan functionality
extension AttendanceDetailHistoryExtension on AttendanceDetailHistory {
  // Get formatted date untuk display
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      final dayName = days[dateTime.weekday - 1];
      final monthName = months[dateTime.month - 1];

      return '$dayName, ${dateTime.day} $monthName ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  // Get status color untuk UI
  int get statusColorValue {
    switch (status.toLowerCase()) {
      case 'present':
        return 0xFF4CAF50;
      case 'late':
        return 0xFFFF9800;
      case 'absent':
        return 0xFFF44336;
      case 'sick':
        return 0xFF9C27B0;
      case 'holiday':
        return 0xFFE91E63;
      default:
        return 0xFF666666;
    }
  }

  // Get translated status
  String get translatedStatus {
    switch (statusLabel.toLowerCase()) {
      case 'hadir':
        return 'Present';
      case 'terlambat':
        return 'Late';
      case 'tidak hadir':
      case 'absent':
      case 'alfa':
        return 'Absent';
      case 'sakit':
      case 'izin':
      case 'cuti':
        return 'Sick/Leave';
      case 'libur':
      case 'hari libur':
        return 'Holiday';
      case 'wfh':
      case 'work from home':
        return 'Work From Home';
      case 'dinas luar':
      case 'perjalanan dinas':
        return 'Business Trip';
      default:
        return statusLabel;
    }
  }

  // Get translated day name
  String get translatedDayName {
    switch (dayName.toLowerCase()) {
      case 'senin':
        return 'Monday';
      case 'selasa':
        return 'Tuesday';
      case 'rabu':
        return 'Wednesday';
      case 'kamis':
        return 'Thursday';
      case 'jumat':
        return 'Friday';
      case 'sabtu':
        return 'Saturday';
      case 'minggu':
        return 'Sunday';
      default:
        return dayName;
    }
  }

  // Helper untuk mendapatkan durasi kerja dalam jam
  double get workDurationInHours => workDurationMinutes / 60.0;

  // Helper untuk mendapatkan durasi lembur dalam jam
  double get overtimeDurationInHours => overtimeDurationMinutes / 60.0;

  // Check apakah ini hari kerja normal
  bool get isWorkingDay => !isHoliday && !isAbsent;

  // Check apakah perlu perbaikan data
  bool get needsCorrection =>
      isLate || isAbsent || (hasClockIn && !hasClockOut);
}
