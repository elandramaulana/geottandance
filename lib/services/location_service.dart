// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission
  Future<LocationPermission> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current position with error handling
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location services.',
      );
    }

    // Check permissions
    LocationPermission permission = await checkLocationPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    try {
      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (kDebugMode) {
        print(
          '📍 Current location: ${position.latitude}, ${position.longitude}',
        );
        print('📍 Accuracy: ${position.accuracy}m');
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting current position: $e');
      }

      // Fallback to last known position if available
      try {
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          if (kDebugMode) {
            print(
              '📍 Using last known position: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}',
            );
          }
          return lastKnownPosition;
        }
      } catch (lastKnownError) {
        if (kDebugMode) {
          print('❌ Error getting last known position: $lastKnownError');
        }
      }

      rethrow;
    }
  }

  /// Get position stream for real-time updates
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update when moved 5 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if position is within radius of target location
  bool isWithinRadius(
    Position currentPosition,
    double targetLatitude,
    double targetLongitude,
    double radiusInMeters,
  ) {
    double distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distance <= radiusInMeters;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for location permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get location accuracy description
  String getAccuracyDescription(double accuracy) {
    if (accuracy <= 5) {
      return 'Excellent';
    } else if (accuracy <= 10) {
      return 'Good';
    } else if (accuracy <= 20) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  /// Validate position accuracy for attendance
  bool isAccuracyValid(Position position, {double requiredAccuracy = 20.0}) {
    return position.accuracy <= requiredAccuracy;
  }
}
