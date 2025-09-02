// lib/widgets/attendance/attendance_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceMapWidget extends StatelessWidget {
  final AttendanceController attendanceController;
  final AttendanceMapController mapController;

  const AttendanceMapWidget({
    super.key,
    required this.attendanceController,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FlutterMap(
        mapController: mapController.mapController,
        options: MapOptions(
          initialCenter: attendanceController.currentPosition != null
              ? LatLng(
                  attendanceController.currentPosition!.latitude,
                  attendanceController.currentPosition!.longitude,
                )
              : const LatLng(-6.2, 106.816666), // Default to Jakarta
          initialZoom: 16.0,
          minZoom: 10.0,
          maxZoom: 18.0,
          // FIXED: Enable zoom controls
          interactionOptions: const InteractionOptions(
            flags:
                InteractiveFlag.all, // Enable all interactions including zoom
            scrollWheelVelocity: 0.005, // Adjust scroll sensitivity
          ),
          onTap: (tapPosition, point) {
            mapController.onMapTap(attendanceController.currentPosition);
          },
        ),
        children: [
          // Base map layer
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.geottandance',
          ),

          // Office radius circle (geofence)
          if (attendanceController.officeLocation != null)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(
                    attendanceController.officeLocation!.latitude,
                    attendanceController.officeLocation!.longitude,
                  ),
                  radius: attendanceController.officeLocation!.allowedRadius,
                  useRadiusInMeter: true,
                  color: attendanceController.isWithinRadius
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : const Color(0xFFEF4444).withOpacity(0.2),
                  borderColor: attendanceController.isWithinRadius
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  borderStrokeWidth: 2,
                ),
              ],
            ),

          // Office location marker
          if (attendanceController.officeLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    attendanceController.officeLocation!.latitude,
                    attendanceController.officeLocation!.longitude,
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

          // Current location marker
          if (attendanceController.currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    attendanceController.currentPosition!.latitude,
                    attendanceController.currentPosition!.longitude,
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: attendanceController.isWithinRadius
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (attendanceController.isWithinRadius
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444))
                                  .withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      attendanceController.isWithinRadius
                          ? Icons.my_location_rounded
                          : Icons.location_off_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

          // Attendance history markers
          MarkerLayer(
            markers: attendanceController.attendanceRecords
                .map(
                  (record) => Marker(
                    point: LatLng(record.latitude, record.longitude),
                    child: GestureDetector(
                      onTap: () => _showAttendanceDetail(record),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: record.type == 'clock_in'
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (record.type == 'clock_in'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444))
                                      .withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          record.type == 'clock_in'
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetail(AttendanceRecord record) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: AttendanceDetailDialog(record: record),
      ),
    );
  }
}

class AttendanceDetailDialog extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceDetailDialog({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      (record.type == 'clock_in'
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  record.type == 'clock_in'
                      ? Icons.login_rounded
                      : Icons.logout_rounded,
                  color: record.type == 'clock_in'
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.type == 'clock_in' ? 'Clock In' : 'Clock Out',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Attendance Detail',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Details
          _buildDetailItem(
            Icons.schedule_rounded,
            'Time',
            DateFormat('dd/MM/yyyy HH:mm').format(record.timestamp),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            Icons.location_on_rounded,
            'Location',
            record.address,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            Icons.gps_fixed_rounded,
            'Coordinates',
            '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}',
          ),
          const SizedBox(height: 28),
          // Action
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF667EEA)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
