// lib/screens/widgets/todays_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TodaysSummaryCard extends StatelessWidget {
  final AttendanceController controller;

  const TodaysSummaryCard({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // final stats = controller.getTodayWorkStats();

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
                Icon(
                  Icons.today_rounded,
                  color: const Color(0xFF667EEA),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Today\'s Summary',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Clock In/Out Row
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildSummaryItem(
            //         Icons.login_rounded,
            //         'Clock In',
            //         controller.todayClockIn != null
            //             ? DateFormat(
            //                 'HH:mm',
            //               ).format(controller.todayClockIn!.timestamp)
            //             : 'Not yet',
            //         controller.hasClickedInToday,
            //         const Color(0xFF10B981),
            //       ),
            //     ),
            //     SizedBox(width: 12.w),
            //     Expanded(
            //       child: _buildSummaryItem(
            //         Icons.logout_rounded,
            //         'Clock Out',
            //         controller.todayClockOut != null
            //             ? DateFormat(
            //                 'HH:mm',
            //               ).format(controller.todayClockOut!.timestamp)
            //             : 'Not yet',
            //         controller.hasClockedOutToday,
            //         const Color(0xFFEF4444),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 12.h),

            // Work Duration
            // _buildSummaryItem(
            //   Icons.timer_rounded,
            //   'Work Duration',
            //   _formatDuration(stats['workDuration']),
            //   (stats['workDuration'] as Duration).inMinutes > 0,
            //   const Color(0xFF667EEA),
            // ),

            // Status indicator
            // if (controller.hasClickedInToday ||
            //     controller.hasClockedOutToday) ...[
            //   SizedBox(height: 12.h),
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            //     decoration: BoxDecoration(
            //       color: controller.hasClockedOutToday
            //           ? const Color(0xFF10B981).withOpacity(0.1)
            //           : const Color(0xFF667EEA).withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(12.r),
            //       border: Border.all(
            //         color: controller.hasClockedOutToday
            //             ? const Color(0xFF10B981).withOpacity(0.3)
            //             : const Color(0xFF667EEA).withOpacity(0.3),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         // Icon(
            //         //   controller.hasClockedOutToday
            //         //       ? Icons.check_circle_rounded
            //         //       : Icons.access_time_rounded,
            //         //   size: 16.r,
            //         //   color: controller.hasClockedOutToday
            //         //       ? const Color(0xFF10B981)
            //         //       : const Color(0xFF667EEA),
            //         // ),
            //         SizedBox(width: 6.w),
            //         Text(
            //           'Work session in progress',
            //           style: TextStyle(
            //             fontSize: 12.sp,
            //             fontWeight: FontWeight.w600,
            //             color: const Color(0xFF667EEA),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive
              ? color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: isActive ? color : Colors.grey),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w700,
              color: isActive ? color : Colors.grey[600],
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }
}
