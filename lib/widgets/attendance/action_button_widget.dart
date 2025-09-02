// lib/widgets/attendance/action_button_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';

class ActionButtons extends StatelessWidget {
  final AttendanceController controller;

  const ActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.attendanceStatus;
      final isLoading = controller.isLoading;
      final isWithinRadius = controller.isWithinRadius;
      final isWorkingDay = controller.isWorkingDay;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            // Clock In Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: controller.canClockIn ? controller.clockIn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.canClockIn
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                  foregroundColor: controller.canClockIn
                      ? Colors.white
                      : const Color(0xFF9CA3AF),
                  elevation: controller.canClockIn ? 8 : 0,
                  shadowColor: controller.canClockIn
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: isLoading && status == AttendanceStatus.notStarted
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, size: 20.r),
                          SizedBox(width: 8.w),
                          Text(
                            _getClockInButtonText(
                              status,
                              isWithinRadius,
                              isWorkingDay,
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            // Clock Out Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: controller.canClockOut ? controller.clockOut : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.canClockOut
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFE5E7EB),
                  foregroundColor: controller.canClockOut
                      ? Colors.white
                      : const Color(0xFF9CA3AF),
                  elevation: controller.canClockOut ? 8 : 0,
                  shadowColor: controller.canClockOut
                      ? const Color(0xFFEF4444).withOpacity(0.3)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: controller.canClockOut
                          ? Colors.transparent
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: isLoading && status == AttendanceStatus.clockedIn
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 20.r),
                          SizedBox(width: 8.w),
                          Text(
                            _getClockOutButtonText(
                              status,
                              isWithinRadius,
                              isWorkingDay,
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Status Information
            SizedBox(height: 16.h),
            _buildStatusInfo(isWithinRadius, isWorkingDay),
          ],
        ),
      );
    });
  }

  Widget _buildStatusInfo(bool isWithinRadius, bool isWorkingDay) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String message;

    if (!isWorkingDay) {
      backgroundColor = const Color(0xFF3B82F6).withOpacity(0.1); // Blue
      borderColor = const Color(0xFF3B82F6).withOpacity(0.3);
      textColor = const Color(0xFF3B82F6);
      icon = Icons.weekend_rounded;
      message = 'Today is not a working day';
    } else if (isWithinRadius) {
      backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
      borderColor = const Color(0xFF10B981).withOpacity(0.3);
      textColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      message =
          'Within office radius (${controller.distance.toStringAsFixed(0)}m)';
    } else {
      backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
      borderColor = const Color(0xFFEF4444).withOpacity(0.3);
      textColor = const Color(0xFFEF4444);
      icon = Icons.location_off_rounded;
      message =
          'Outside office radius (${controller.distance.toStringAsFixed(0)}m away)';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getClockInButtonText(
    AttendanceStatus status,
    bool isWithinRadius,
    bool isWorkingDay,
  ) {
    if (!isWorkingDay) {
      return 'Not Working Day';
    }

    switch (status) {
      case AttendanceStatus.notStarted:
        if (!isWithinRadius) {
          return 'Move Closer to Office';
        }
        return 'Clock In';
      case AttendanceStatus.clockedIn:
        return 'Already Clocked In';
      case AttendanceStatus.completed:
        return 'Work Completed';
    }
  }

  String _getClockOutButtonText(
    AttendanceStatus status,
    bool isWithinRadius,
    bool isWorkingDay,
  ) {
    if (!isWorkingDay) {
      return 'Not Working Day';
    }

    switch (status) {
      case AttendanceStatus.notStarted:
        return 'Clock In First';
      case AttendanceStatus.clockedIn:
        if (!isWithinRadius) {
          return 'Move Closer to Office';
        }
        return 'Clock Out';
      case AttendanceStatus.completed:
        return 'Already Clocked Out';
    }
  }
}
