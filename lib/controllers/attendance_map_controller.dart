// lib/controllers/map_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class AttendanceMapController extends GetxController {
  late MapController _mapController;

  // Observable variables
  final _mapZoom = 16.0.obs;
  final _isMapReady = false.obs;

  // Getters
  MapController get mapController => _mapController;
  double get mapZoom => _mapZoom.value;
  bool get isMapReady => _isMapReady.value;

  @override
  void onInit() {
    super.onInit();
    _mapController = MapController();
    _isMapReady.value = true;
  }

  @override
  void onClose() {
    // Clean up map controller if needed
    super.onClose();
  }

  /// Center map on current location
  void centerOnCurrentLocation(Position? currentPosition) {
    if (currentPosition != null && _isMapReady.value) {
      _mapController.move(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        _mapZoom.value,
      );

      Get.snackbar(
        'Map Centered',
        'Centered on your current location',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF667EEA),
        colorText: Colors.white,
      );
    }
  }

  /// Handle map tap events
  void onMapTap(Position? currentPosition) {
    if (currentPosition != null) {
      centerOnCurrentLocation(currentPosition);
    }
  }

  /// Zoom in on the map
  void zoomIn() {
    if (_mapZoom.value < 18.0) {
      _mapZoom.value += 1.0;
      _mapController.move(_mapController.camera.center, _mapZoom.value);
    }
  }

  /// Zoom out on the map
  void zoomOut() {
    if (_mapZoom.value > 10.0) {
      _mapZoom.value -= 1.0;
      _mapController.move(_mapController.camera.center, _mapZoom.value);
    }
  }

  /// Set custom zoom level
  void setZoom(double zoom) {
    if (zoom >= 10.0 && zoom <= 18.0) {
      _mapZoom.value = zoom;
      _mapController.move(_mapController.camera.center, zoom);
    }
  }

  /// Move map to specific coordinates
  void moveToLocation(double latitude, double longitude, {double? zoom}) {
    if (_isMapReady.value) {
      _mapController.move(LatLng(latitude, longitude), zoom ?? _mapZoom.value);
    }
  }

  /// Build current location marker
  Marker buildCurrentLocationMarker(Position currentPosition) {
    return Marker(
      point: LatLng(currentPosition.latitude, currentPosition.longitude),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// Build attendance history markers
  List<Marker> buildAttendanceMarkers(
    List<dynamic> attendanceRecords,
    Function(dynamic) onMarkerTap,
  ) {
    return attendanceRecords.map((record) {
      return Marker(
        point: LatLng(record.latitude, record.longitude),
        child: GestureDetector(
          onTap: () => onMarkerTap(record),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: record.type == 'clock_in'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color:
                      (record.type == 'clock_in'
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              record.type == 'clock_in'
                  ? Icons.login_rounded
                  : Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build custom marker with animation
  Widget buildAnimatedMarker({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.8, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: size * 0.45),
            ),
          );
        },
      ),
    );
  }

  /// Get map bounds for all markers
  LatLngBounds? getMarkersBounds(
    List<dynamic> attendanceRecords,
    Position? currentPosition,
  ) {
    if (attendanceRecords.isEmpty && currentPosition == null) return null;

    List<LatLng> points = [];

    // Add current position if available
    if (currentPosition != null) {
      points.add(LatLng(currentPosition.latitude, currentPosition.longitude));
    }

    // Add attendance record positions
    for (var record in attendanceRecords) {
      points.add(LatLng(record.latitude, record.longitude));
    }

    if (points.isEmpty) return null;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  /// Fit map to show all markers
  void fitBounds(List<dynamic> attendanceRecords, Position? currentPosition) {
    final bounds = getMarkersBounds(attendanceRecords, currentPosition);
    if (bounds != null && _isMapReady.value) {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  /// Handle map events
  void onMapEvent(MapEvent event) {
    if (event is MapEventMove) {
      // Update zoom level when map is moved
      _mapZoom.value = event.camera.zoom;
    }
  }

  /// Reset map to initial state
  void resetMap(Position? currentPosition) {
    if (currentPosition != null && _isMapReady.value) {
      _mapZoom.value = 16.0;
      _mapController.move(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        16.0,
      );
    }
  }

  /// Get distance between two points in meters
  double getDistanceBetween(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Check if location is within allowed radius (for geofencing)
  bool isWithinAllowedRadius(
    Position currentPosition,
    LatLng targetLocation, {
    double radiusInMeters = 100.0,
  }) {
    final distance = getDistanceBetween(
      LatLng(currentPosition.latitude, currentPosition.longitude),
      targetLocation,
    );
    return distance <= radiusInMeters;
  }

  /// Add circle overlay for geofencing visualization
  Widget buildGeofenceCircle(LatLng center, double radiusInMeters) {
    return CircleLayer(
      circles: [
        CircleMarker(
          point: center,
          radius: radiusInMeters,
          useRadiusInMeter: true,
          color: const Color(0xFF667EEA).withOpacity(0.3),
          borderColor: const Color(0xFF667EEA),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}
