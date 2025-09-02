// lib/controllers/attendance_map_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class AttendanceMapController extends GetxController {
  late MapController mapController;
  final RxDouble _currentZoom = 16.0.obs;

  double get currentZoom => _currentZoom.value;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }

  void centerOnCurrentLocation(Position? position) {
    if (position == null) {
      Get.snackbar(
        'Location Error',
        'Current location not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final LatLng center = LatLng(position.latitude, position.longitude);
      mapController.move(center, _currentZoom.value);

      Get.snackbar(
        'Location Centered',
        'Map centered on your current location',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Map Error',
        'Failed to center map on location',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void centerOnOfficeLocation(double latitude, double longitude) {
    try {
      final LatLng center = LatLng(latitude, longitude);
      mapController.move(center, _currentZoom.value);

      Get.snackbar(
        'Office Location',
        'Map centered on office location',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Map Error',
        'Failed to center map on office location',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onMapTap(Position? currentPosition) {
    // Handle map tap if needed
    // You can add functionality here like showing coordinates, etc.
  }

  void zoomIn() {
    if (_currentZoom.value < 18.0) {
      _currentZoom.value += 1.0;
      mapController.move(mapController.camera.center, _currentZoom.value);
    }
  }

  void zoomOut() {
    if (_currentZoom.value > 10.0) {
      _currentZoom.value -= 1.0;
      mapController.move(mapController.camera.center, _currentZoom.value);
    }
  }

  void fitBounds(
    Position currentPosition,
    double officeLatitude,
    double officeLongitude,
  ) {
    try {
      final LatLng currentLatLng = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      final LatLng officeLatLng = LatLng(officeLatitude, officeLongitude);

      final southWest = LatLng(
        currentLatLng.latitude < officeLatLng.latitude
            ? currentLatLng.latitude
            : officeLatLng.latitude,
        currentLatLng.longitude < officeLatLng.longitude
            ? currentLatLng.longitude
            : officeLatLng.longitude,
      );
      final northEast = LatLng(
        currentLatLng.latitude > officeLatLng.latitude
            ? currentLatLng.latitude
            : officeLatLng.latitude,
        currentLatLng.longitude > officeLatLng.longitude
            ? currentLatLng.longitude
            : officeLatLng.longitude,
      );

      final bounds = LatLngBounds(southWest, northEast);

      mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
      );
    } catch (e) {
      // Fallback to default center
      centerOnCurrentLocation(currentPosition);
    }
  }
}
