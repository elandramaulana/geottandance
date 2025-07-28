// lib/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat(
        'HH:mm:ss - dd MMMM yyyy',
      ).format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController = Get.put(
      AttendanceController(),
    );
    final AttendanceMapController mapController = Get.put(
      AttendanceMapController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (attendanceController.isLoading &&
            attendanceController.currentPosition == null) {
          return _buildLoadingScreen();
        }

        return Stack(
          children: [
            _buildMap(attendanceController, mapController),
            _buildTopAppBar(),
            _buildBottomSheet(attendanceController),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C5B41), Color(0xFF2E7D5F), Color(0xFF3A8B6A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60.w,
              height: 60.h,
              child: CircularProgressIndicator(
                strokeWidth: 3.w,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Getting your location...',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please make sure location permission is enabled',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(
    AttendanceController attendanceController,
    AttendanceMapController mapController,
  ) {
    return Obx(
      () => FlutterMap(
        mapController: mapController.mapController,
        options: MapOptions(
          initialCenter: attendanceController.currentPosition != null
              ? LatLng(
                  attendanceController.currentPosition!.latitude,
                  attendanceController.currentPosition!.longitude,
                )
              : const LatLng(0, 0),
          initialZoom: 16.0,
          onTap: (tapPosition, point) {
            mapController.onMapTap(attendanceController.currentPosition);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.attendance_app',
          ),
          // Current location marker
          if (attendanceController.currentPosition != null)
            MarkerLayer(
              markers: [
                mapController.buildCurrentLocationMarker(
                  attendanceController.currentPosition!,
                ),
              ],
            ),
          // Attendance history markers
          MarkerLayer(
            markers: mapController.buildAttendanceMarkers(
              attendanceController.attendanceRecords,
              _showAttendanceDetail,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    final AttendanceController attendanceController = Get.put(
      AttendanceController(),
    );
    final AttendanceMapController mapController = Get.put(
      AttendanceMapController(),
    );
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                _buildAppBarButton(
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFF667EEA),
                  onTap: () =>
                      Get.find<AttendanceController>().refreshLocation(),
                ),
                const Spacer(),
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    SizedBox(width: 12.w),
                    _buildAppBarButton(
                      icon: Icons.my_location_rounded,
                      color: const Color(0xFF667EEA),
                      onTap: () => mapController.centerOnCurrentLocation(
                        attendanceController.currentPosition,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20.r),
      ),
    );
  }

  Widget _buildBottomSheet(AttendanceController controller) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.38,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 30.r,
                offset: Offset(0, -8.h),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _buildModernHandle(),
                _buildStatusCard(controller),
                _buildCurrentTimeDisplay(),
                _buildLastActivityCard(controller),
                SizedBox(height: 24.h),
                _buildModernActionButtons(controller),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHandle() {
    return Container(
      margin: EdgeInsets.only(top: 16.h, bottom: 24.h),
      width: 50.w,
      height: 5.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }

  Widget _buildStatusCard(AttendanceController controller) {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: controller.isClockedIn
                ? [
                    const Color(0xFF10B981),
                    const Color(0xFF059669),
                    const Color(0xFF047857),
                  ]
                : [
                    const Color(0xFF667EEA),
                    const Color(0xFF764BA2),
                    const Color(0xFF5B21B6),
                  ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: controller.isClockedIn
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Icon(
                controller.isClockedIn
                    ? Icons.work_rounded
                    : Icons.access_time_rounded,
                size: 32.r,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isClockedIn
                        ? 'Work Session Active'
                        : 'Ready to Clock In',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    controller.isClockedIn
                        ? 'You are currently working'
                        : 'Start your productive day',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Text(
                controller.isClockedIn ? 'ACTIVE' : 'READY',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeDisplay() {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: Colors.white,
              size: 24.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Time',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _currentTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(4.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 4.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastActivityCard(AttendanceController controller) {
    return Obx(() {
      if (controller.lastAttendance == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color:
                        (controller.lastAttendance!.type == 'clock_in'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    controller.lastAttendance!.type == 'clock_in'
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                    size: 18.r,
                    color: controller.lastAttendance!.type == 'clock_in'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last ${controller.lastAttendance!.type == 'clock_in' ? 'Clock In' : 'Clock Out'}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        DateFormat(
                          'HH:mm:ss - dd MMMM yyyy',
                        ).format(controller.lastAttendance!.timestamp),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:
                        (controller.lastAttendance!.type == 'clock_in'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    controller.lastAttendance!.type == 'clock_in'
                        ? 'IN'
                        : 'OUT',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: controller.lastAttendance!.type == 'clock_in'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (controller.lastAttendance!.address != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16.r,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        controller.lastAttendance!.address!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildModernActionButtons(AttendanceController controller) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            // Clock In Button
            SizedBox(
              width: double.infinity,
              height: 58.h,
              child: ElevatedButton(
                onPressed: controller.isLoading || controller.isClockedIn
                    ? null
                    : () => controller.clockIn(),
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF1F5F9),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        Colors.white.withOpacity(0.1),
                      ),
                    ),
                child: Container(
                  decoration: controller.isLoading || controller.isClockedIn
                      ? null
                      : BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 12.r,
                              offset: Offset(0, 6.h),
                            ),
                          ],
                        ),
                  child: Center(
                    child: controller.isLoading
                        ? SizedBox(
                            width: 22.w,
                            height: 22.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5.w,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, size: 22.r),
                              SizedBox(width: 8.w),
                              Text(
                                'Clock In',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Clock Out Button
            SizedBox(
              width: double.infinity,
              height: 58.h,
              child: OutlinedButton(
                onPressed: controller.isLoading || !controller.isClockedIn
                    ? null
                    : () => controller.clockOut(),
                style:
                    OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      backgroundColor:
                          controller.isLoading || !controller.isClockedIn
                          ? Colors.transparent
                          : const Color(0xFFEF4444).withOpacity(0.05),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      side: BorderSide(
                        color: controller.isLoading || !controller.isClockedIn
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFFEF4444),
                        width: 2.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        const Color(0xFFEF4444).withOpacity(0.1),
                      ),
                    ),
                child: controller.isLoading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.h,
                        child: CircularProgressIndicator(
                          color: Color(0xFFEF4444),
                          strokeWidth: 2.5.w,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 22.r),
                          SizedBox(width: 8.w),
                          Text(
                            'Clock Out',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceDetail(dynamic record) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color:
                          (record.type == 'clock_in'
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      record.type == 'clock_in'
                          ? Icons.login_rounded
                          : Icons.logout_rounded,
                      color: record.type == 'clock_in'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 28.r,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.type == 'clock_in' ? 'Clock In' : 'Clock Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22.sp,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Attendance Detail',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              // Details
              _buildDetailItem(
                Icons.schedule_rounded,
                'Time',
                DateFormat('dd/MM/yyyy HH:mm').format(record.timestamp),
              ),
              SizedBox(height: 16.h),
              _buildDetailItem(
                Icons.location_on_rounded,
                'Location',
                record.address ?? 'Unknown Location',
              ),
              SizedBox(height: 16.h),
              _buildDetailItem(
                Icons.gps_fixed_rounded,
                'Coordinates',
                '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}',
              ),
              SizedBox(height: 28.h),
              // Action
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 20.r, color: const Color(0xFF667EEA)),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
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
