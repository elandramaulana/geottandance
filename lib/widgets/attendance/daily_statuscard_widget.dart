// lib/widgets/attendance/daily_statuscard_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';

class DailyStatusCard extends StatelessWidget {
  final AttendanceController controller;

  const DailyStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.attendanceStatus;
      final isWithinRadius = controller.isWithinRadius;
      final distance = controller.distance;
      final isWorkingDay = controller.isWorkingDay;

      Color cardColor;
      IconData cardIcon;
      String statusText;
      String subtitleText;

      // Priority: Working day status first
      if (!isWorkingDay) {
        cardColor = Colors.blue;
        cardIcon = Icons.weekend_rounded;
        statusText = 'Not a Working Day';
        subtitleText = 'Attendance is not available today';
      } else {
        // Working day logic
        switch (status) {
          case AttendanceStatus.notStarted:
            if (isWithinRadius) {
              cardColor = const Color(0xFF10B981);
              cardIcon = Icons.play_arrow_rounded;
              statusText = 'Ready to Start';
              subtitleText = 'You can begin your workday';
            } else {
              cardColor = const Color(0xFFEF4444);
              cardIcon = Icons.location_off_rounded;
              statusText = 'Outside Office Area';
              subtitleText =
                  'Move closer to office (${distance.toStringAsFixed(0)}m away)';
            }
            break;
          case AttendanceStatus.clockedIn:
            cardColor = const Color(0xFF667EEA);
            cardIcon = Icons.work_rounded;
            statusText = 'Working';
            subtitleText = 'You are currently clocked in';
            break;
          case AttendanceStatus.completed:
            cardColor = const Color(0xFF10B981);
            cardIcon = Icons.check_circle_rounded;
            statusText = 'Work Complete';
            subtitleText = 'Great job today!';
            break;
        }
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor, cardColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(cardIcon, color: Colors.white, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitleText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isWorkingDay &&
                status == AttendanceStatus.notStarted &&
                isWithinRadius)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'READY',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
