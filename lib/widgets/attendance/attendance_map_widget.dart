// lib/screens/widgets/attendance_map_widget.dart
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
    Key? key,
    required this.attendanceController,
    required this.mapController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(); // HAPUS INI GANTI SAMA OBX YG DI BAWAH!
    // Obx(
    //   () => FlutterMap(
    //     mapController: mapController.mapController,
    //     options: MapOptions(
    //       initialCenter: attendanceController.currentPosition != null
    //           ? LatLng(
    //               attendanceController.currentPosition!.latitude,
    //               attendanceController.currentPosition!.longitude,
    //             )
    //           : const LatLng(0, 0),
    //       initialZoom: 16.0,
    //       onTap: (tapPosition, point) {
    //         mapController.onMapTap(attendanceController.currentPosition);
    //       },
    //     ),
    //     children: [
    //       TileLayer(
    //         urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    //         userAgentPackageName: 'com.example.attendance_app',
    //       ),
    //       // Current location marker
    //       if (attendanceController.currentPosition != null)
    //         MarkerLayer(
    //           markers: [
    //             mapController.buildCurrentLocationMarker(
    //               attendanceController.currentPosition!,
    //             ),
    //           ],
    //         ),
    //       // Attendance history markers
    //       MarkerLayer(
    //         markers: mapController.buildAttendanceMarkers(
    //           attendanceController.attendanceRecords,
    //           _showAttendanceDetail,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _showAttendanceDetail(dynamic record) {
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
  final dynamic record;

  const AttendanceDetailDialog({Key? key, required this.record})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
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
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.type == 'clock_in' ? 'Clock In' : 'Clock Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
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
          SizedBox(height: 28),
          // Details
          _buildDetailItem(
            Icons.schedule_rounded,
            'Time',
            DateFormat('dd/MM/yyyy HH:mm').format(record.timestamp),
          ),
          SizedBox(height: 16),
          _buildDetailItem(
            Icons.location_on_rounded,
            'Location',
            record.address ?? 'Unknown Location',
          ),
          SizedBox(height: 16),
          _buildDetailItem(
            Icons.gps_fixed_rounded,
            'Coordinates',
            '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}',
          ),
          SizedBox(height: 28),
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
              child: Text(
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
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF667EEA)),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
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
