// lib/screens/widgets/modern_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';

class ActionButtons extends StatelessWidget {
  final AttendanceController controller;

  const ActionButtons({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                onPressed: controller.canClockInToday() && !controller.isLoading
                    ? () => controller.clockIn()
                    : null,
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
                  decoration:
                      controller.canClockInToday() && !controller.isLoading
                      ? BoxDecoration(
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
                        )
                      : null,
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
                                controller.hasClickedInToday
                                    ? 'Already Clocked In Today'
                                    : 'Clock In',
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
                onPressed:
                    controller.canClockOutToday() && !controller.isLoading
                    ? () => controller.clockOut()
                    : null,
                style:
                    OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      backgroundColor:
                          controller.canClockOutToday() && !controller.isLoading
                          ? const Color(0xFFEF4444).withOpacity(0.05)
                          : Colors.transparent,
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      side: BorderSide(
                        color:
                            controller.canClockOutToday() &&
                                !controller.isLoading
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
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
                            _getClockOutButtonText(controller),
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

            // Status text
            if (controller.hasClockedOutToday) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      size: 18.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Attendance completed for today',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getClockOutButtonText(AttendanceController controller) {
    if (controller.hasClockedOutToday) {
      return 'Already Clocked Out Today';
    } else if (!controller.hasClickedInToday) {
      return 'Clock In First';
    } else {
      return 'Clock Out';
    }
  }
}
