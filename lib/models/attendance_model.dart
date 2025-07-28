// lib/models/attendance_model.dart
class AttendanceRecord {
  final int? id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String type; // 'clock_in' or 'clock_out'
  final String? address;

  AttendanceRecord({
    this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'address': address,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      type: map['type'],
      address: map['address'],
    );
  }

  AttendanceRecord copyWith({
    int? id,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? type,
    String? address,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      address: address ?? this.address,
    );
  }
}
