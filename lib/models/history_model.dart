// lib/models/history_model.dart
class HistoryModel {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String category;
  final String locationIn;
  final String locationOut;
  final double? latitudeIn;
  final double? longitudeIn;
  final double? latitudeOut;
  final double? longitudeOut;

  HistoryModel({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.category,
    required this.locationIn,
    required this.locationOut,
    this.latitudeIn,
    this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut,
  });

  /// Get work duration if both check in and check out are available
  Duration? get workDuration {
    if (checkIn == '-' || checkOut == '-') return null;

    try {
      final checkInTime = _parseTimeString(checkIn);
      final checkOutTime = _parseTimeString(checkOut);

      if (checkInTime != null && checkOutTime != null) {
        final checkInDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          checkInTime.hour,
          checkInTime.minute,
        );
        final checkOutDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          checkOutTime.hour,
          checkOutTime.minute,
        );

        return checkOutDateTime.difference(checkInDateTime);
      }
    } catch (e) {
      // Handle parsing errors
      return null;
    }

    return null;
  }

  /// Get formatted work duration string
  String get workDurationFormatted {
    final duration = workDuration;
    if (duration == null) return '-';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Check if the attendance is complete (has both check in and check out)
  bool get isComplete => checkIn != '-' && checkOut != '-';

  /// Check if the person was late
  bool get isLate => category == 'Late';

  /// Check if the person was absent
  bool get isAbsent => category == 'Absent';

  /// Check if the attendance is incomplete (has check in but no check out)
  bool get isIncomplete => category == 'Incomplete';

  /// Parse time string (HH:MM AM/PM) to DateTime
  DateTime? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(' ');
      if (parts.length != 2) return null;

      final timePart = parts[0];
      final period = parts[1];

      final timeParts = timePart.split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (period.toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (period.toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(
        2000,
        1,
        1,
        hour,
        minute,
      ); // Use dummy date for time calculation
    } catch (e) {
      return null;
    }
  }

  /// Create copy with modified fields
  HistoryModel copyWith({
    DateTime? date,
    String? checkIn,
    String? checkOut,
    String? category,
    String? locationIn,
    String? locationOut,
    double? latitudeIn,
    double? longitudeIn,
    double? latitudeOut,
    double? longitudeOut,
  }) {
    return HistoryModel(
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      category: category ?? this.category,
      locationIn: locationIn ?? this.locationIn,
      locationOut: locationOut ?? this.locationOut,
      latitudeIn: latitudeIn ?? this.latitudeIn,
      longitudeIn: longitudeIn ?? this.longitudeIn,
      latitudeOut: latitudeOut ?? this.latitudeOut,
      longitudeOut: longitudeOut ?? this.longitudeOut,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'category': category,
      'locationIn': locationIn,
      'locationOut': locationOut,
      'latitudeIn': latitudeIn,
      'longitudeIn': longitudeIn,
      'latitudeOut': latitudeOut,
      'longitudeOut': longitudeOut,
    };
  }

  /// Create from map for deserialization
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      checkIn: map['checkIn'] ?? '-',
      checkOut: map['checkOut'] ?? '-',
      category: map['category'] ?? 'Unknown',
      locationIn: map['locationIn'] ?? '-',
      locationOut: map['locationOut'] ?? '-',
      latitudeIn: map['latitudeIn']?.toDouble(),
      longitudeIn: map['longitudeIn']?.toDouble(),
      latitudeOut: map['latitudeOut']?.toDouble(),
      longitudeOut: map['longitudeOut']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'HistoryModel(date: $date, checkIn: $checkIn, checkOut: $checkOut, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryModel &&
        other.date == date &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.category == category &&
        other.locationIn == locationIn &&
        other.locationOut == locationOut &&
        other.latitudeIn == latitudeIn &&
        other.longitudeIn == longitudeIn &&
        other.latitudeOut == latitudeOut &&
        other.longitudeOut == longitudeOut;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        category.hashCode ^
        locationIn.hashCode ^
        locationOut.hashCode ^
        latitudeIn.hashCode ^
        longitudeIn.hashCode ^
        latitudeOut.hashCode ^
        longitudeOut.hashCode;
  }
}
