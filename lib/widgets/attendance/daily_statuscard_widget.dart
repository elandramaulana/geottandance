// lib/screens/widgets/daily_status_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';

class DailyStatusCard extends StatelessWidget {
  final AttendanceController controller;

  const DailyStatusCard({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color gradientStartColor;
      Color gradientEndColor;
      String mainText;
      String subText;
      IconData iconData;
      String badgeText;

      // if (!controller.hasClickedInToday) {
      //   // Ready to clock in
      //   gradientStartColor = const Color(0xFF10B981);
      //   gradientEndColor = const Color(0xFF059669);
      //   mainText = 'Ready to Start';
      //   subText = 'Begin your productive day';
      //   iconData = Icons.login_rounded;
      //   badgeText = 'READY';
      // } else if (controller.hasClickedInToday &&
      //     !controller.hasClockedOutToday) {
      //   // Currently working
      //   gradientStartColor = const Color(0xFF667EEA);
      //   gradientEndColor = const Color(0xFF764BA2);
      //   mainText = 'Work Session Active';
      //   subText = controller.isClockedIn
      //       ? 'You are currently working'
      //       : 'Ready to clock out';
      //   iconData = Icons.work_rounded;
      //   badgeText = 'ACTIVE';
      // } else {
      //   // Work completed for today
      //   gradientStartColor = const Color(0xFF6B7280);
      //   gradientEndColor = const Color(0xFF4B5563);
      //   mainText = 'Work Completed';
      //   subText = 'Great job today! See you tomorrow';
      //   iconData = Icons.check_circle_rounded;
      //   badgeText = 'DONE';
      // }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // gradientStartColor,
              // gradientEndColor,
              // gradientEndColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            // BoxShadow(
            //   color: gradientStartColor.withOpacity(0.3),
            //   blurRadius: 20.r,
            //   offset: Offset(0, 8.h),
            //   spreadRadius: 0,
            // ),
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
              // child: Icon(iconData, size: 32.r, color: Colors.white),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "mainText",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "subText",
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
                "badgeText",
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
      );
    });
  }
}
