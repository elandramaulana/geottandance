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
}
