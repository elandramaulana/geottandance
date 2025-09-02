import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geottandance/controllers/history_detail_controller.dart';
import 'package:flutter/foundation.dart';

class HistoryDetailScreen extends GetView<AttendanceDetailController> {
  const HistoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the attendance ID from arguments
    final int attendanceId = Get.arguments as int;

    // Load the attendance detail when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentAttendanceId != attendanceId) {
        controller.loadAttendanceDetail(attendanceId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Detail Attendance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5C),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<AttendanceDetailController>(
        builder: (controller) {
          // Debug logging
          if (kDebugMode) {
            print(
              '🔄 UI Builder called - isLoading: ${controller.isLoading}, hasError: ${controller.hasError}, hasData: ${controller.hasData}',
            );
          }

          if (controller.isLoading) {
            return _buildLoadingState();
          }

          if (controller.hasError) {
            return _buildErrorState(controller.errorMessage);
          }

          if (!controller.hasData) {
            return _buildNoDataState();
          }

          final attendance = controller.attendanceDetail!;
          return _buildDetailContent(attendance);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D5C)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading attendance detail...',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: const Color(0xFFF44336),
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Detail',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: Icon(Icons.refresh, size: 20.sp),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64.sp, color: const Color(0xFF666666)),
            SizedBox(height: 16.h),
            Text(
              'No Data Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Attendance detail not found',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: Icon(Icons.refresh, size: 20.sp),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(attendance) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Status Card
          _buildDateStatusCard(attendance),

          SizedBox(height: 16.h),

          // Attendance Timeline Section
          _buildAttendanceTimeline(attendance),

          SizedBox(height: 24.h),

          // Location Sections
          if (attendance.clockInLocation.hasCoordinates) ...[
            _buildLocationSection(
              'Check In Location',
              attendance.clockInLocation,
              Colors.green,
              Icons.login_rounded,
            ),
            SizedBox(height: 16.h),
          ],

          if (attendance.clockOutLocation.hasCoordinates) ...[
            _buildLocationSection(
              'Check Out Location',
              attendance.clockOutLocation,
              Colors.red,
              Icons.logout_rounded,
            ),
            SizedBox(height: 16.h),
          ],

          // Additional Info Card
          if (attendance.notes.isNotEmpty) _buildNotesCard(attendance.notes),
        ],
      ),
    );
  }

  Widget _buildDateStatusCard(attendance) {
    final formattedDate = _formatDate(attendance.date);
    final statusColor = _getStatusColor(attendance.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Calendar Icon with Date
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D5C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: const Color(0xFF2E7D5C),
                  size: 20.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  _getDateNumber(attendance.date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D5C),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Date Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _translateDayToEnglish(attendance.dayName),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _translateStatusToEnglish(attendance.statusLabel),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTimeline(attendance) {
    // Safely get working hours (default to 8 hours if not available)
    final workingHours = attendance.workDurationMinutes > 0
        ? attendance.formattedWorkDuration
        : attendance.hasClockIn && !attendance.hasClockOut
        ? 'In Progress'
        : '0h 0m';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: const Color(0xFF2E7D5C),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Attendance Timeline',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Timeline Items
          Row(
            children: [
              // Check In
              Expanded(
                child: _buildTimelineItem(
                  'IN',
                  attendance.displayClockIn,
                  '', // Remove static time
                  Colors.green,
                  Icons.login_rounded,
                  isActive: attendance.hasClockIn,
                ),
              ),

              // Duration
              Expanded(
                child: _buildTimelineItem(
                  'DURATION',
                  workingHours,
                  '',
                  Colors.blue,
                  Icons.access_time_filled_rounded,
                  isActive:
                      attendance.workDurationMinutes > 0 ||
                      attendance.hasClockIn,
                ),
              ),

              // Check Out
              Expanded(
                child: _buildTimelineItem(
                  'OUT',
                  attendance.displayClockOut,
                  '', // Remove static time
                  Colors.red,
                  Icons.logout_rounded,
                  isActive: attendance.hasClockOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    String time,
    String duration,
    Color color,
    IconData icon, {
    bool isActive = true,
  }) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: isActive
                ? color.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? color : Colors.grey, width: 2),
          ),
          child: Icon(icon, color: isActive ? color : Colors.grey, size: 24.sp),
        ),

        SizedBox(height: 8.h),

        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? color : Colors.grey,
            letterSpacing: 0.5,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          time,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),

        if (duration.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            duration,
            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF666666)),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection(
    String title,
    location,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (location.hasAddress) ...[
                        SizedBox(height: 4.h),
                        Text(
                          location.displayAddress,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF666666),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map
          if (location.hasCoordinates) ...[
            Container(
              height: 200.h,
              margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _MapWidget(
                  lat: location.latitude!,
                  lng: location.longitude!,
                  markerColor: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: const Color(0xFF2E7D5C),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            notes,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getDateNumber(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return date.day.toString();
    } catch (e) {
      return '1';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF4CAF50);
      case 'late':
        return const Color(0xFFFF9800);
      case 'absent':
        return const Color(0xFFF44336);
      case 'sick':
        return const Color(0xFF9C27B0);
      case 'holiday':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF666666);
    }
  }

  String _translateStatusToEnglish(String indonesianStatus) {
    switch (indonesianStatus.toLowerCase()) {
      case 'hadir':
        return 'Present';
      case 'terlambat':
        return 'Late';
      case 'tidak hadir':
      case 'absent':
      case 'alfa':
        return 'Absent';
      case 'sakit':
      case 'izin':
      case 'cuti':
        return 'Sick/Leave';
      case 'libur':
      case 'hari libur':
        return 'Holiday';
      case 'wfh':
      case 'work from home':
        return 'Work From Home';
      case 'dinas luar':
      case 'perjalanan dinas':
        return 'Business Trip';
      default:
        return indonesianStatus;
    }
  }

  String _translateDayToEnglish(String indonesianDay) {
    switch (indonesianDay.toLowerCase()) {
      case 'senin':
        return 'Monday';
      case 'selasa':
        return 'Tuesday';
      case 'rabu':
        return 'Wednesday';
      case 'kamis':
        return 'Thursday';
      case 'jumat':
        return 'Friday';
      case 'sabtu':
        return 'Saturday';
      case 'minggu':
        return 'Sunday';
      default:
        return indonesianDay;
    }
  }
}

// Map Widget Component
class _MapWidget extends StatelessWidget {
  final double lat;
  final double lng;
  final Color markerColor;

  const _MapWidget({
    required this.lat,
    required this.lng,
    this.markerColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 16.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.geottandance',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(lat, lng),
              child: Container(
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: markerColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
