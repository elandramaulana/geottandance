// lib/utils/location_utils.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationUtils {
  /// Get formatted address from coordinates
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts =
            [
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                ]
                .where((element) => element != null && element.isNotEmpty)
                .map((e) => e!)
                .toList();

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Address not available';
      } else {
        return 'Address not available';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get address from coordinates error: $e');
      }
      return 'Address not available';
    }
  }

  /// Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(2)}km';
    }
  }

  /// Get location accuracy description
  static String getAccuracyDescription(double accuracy) {
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

  /// Check if position accuracy is valid for attendance
  static bool isAccuracyValid(
    Position position, {
    double requiredAccuracy = 20.0,
  }) {
    return position.accuracy <= requiredAccuracy;
  }

  /// Get compass direction from bearing
  static String getCompassDirection(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) {
      return 'N';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      return 'NE';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      return 'E';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      return 'SE';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      return 'S';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      return 'SW';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      return 'W';
    } else {
      return 'NW';
    }
  }

  /// Check if location is within Indonesia bounds (rough check)
  static bool isWithinIndonesia(double latitude, double longitude) {
    // Indonesia rough bounds
    const double minLat = -11.0;
    const double maxLat = 6.0;
    const double minLng = 95.0;
    const double maxLng = 141.0;

    return latitude >= minLat &&
        latitude <= maxLat &&
        longitude >= minLng &&
        longitude <= maxLng;
  }
}
