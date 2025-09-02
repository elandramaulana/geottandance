// lib/widgets/attendance/today_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';

class TodaysSummaryCard extends StatelessWidget {
  final AttendanceController controller;

  const TodaysSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final todayData = controller.todayAttendance;
      final status = controller.attendanceStatus;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withOpacity(0.05),
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
                Icon(
                  Icons.calendar_today_rounded,
                  color: const Color(0xFF667EEA),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Today's Summary",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    Icons.login_rounded,
                    'Clock In',
                    todayData?.clockInTime ?? 'Not yet',
                    status != AttendanceStatus.notStarted,
                    const Color(0xFF10B981),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryItem(
                    Icons.logout_rounded,
                    'Clock Out',
                    todayData?.clockOutTime ?? 'Not yet',
                    status == AttendanceStatus.completed,
                    const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildSummaryItem(
              Icons.schedule_rounded,
              'Work Duration',
              todayData?.workDuration ?? '0m',
              status == AttendanceStatus.completed,
              const Color(0xFF6B7280),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(
    IconData icon,
    String label,
    String value,
    bool isActive,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive ? color.withOpacity(0.1) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isActive ? color : const Color(0xFF9CA3AF),
                size: 18.r,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? color : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
