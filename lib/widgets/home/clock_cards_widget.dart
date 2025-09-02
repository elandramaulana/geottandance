// lib/widgets/home/clock_cards_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/home_controller.dart';

class ClockCardsWidget extends GetView<HomeController> {
  const ClockCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final todayAttendance = controller.todayAttendance;
      final canClockIn = controller.canClockIn;
      final canClockOut = controller.canClockOut;
      final isWorkingDay = controller.isWorkingDay;

      return Row(
        children: [
          Expanded(
            child: ClockCard(
              icon: Icons.login,
              title: 'Clock In',
              // FIXED: Only show time if actually clocked in
              time: todayAttendance?.displayClockInTime ?? '--:--',
              status: todayAttendance?.clockInStatusText ?? 'Pending',
              color: const Color(0xFF10B981),
              statusColor:
                  todayAttendance?.clockInStatusColor ?? Colors.grey[400]!,
              isClockIn: true,
              // FIXED: Only active if there's actual clock in data
              isActive:
                  todayAttendance?.clockIn != null &&
                  todayAttendance!.clockIn!.isNotEmpty,
              isEnabled: canClockIn && isWorkingDay,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ClockCard(
              icon: Icons.logout,
              title: 'Clock Out',
              // FIXED: Only show time if actually clocked out
              time: todayAttendance?.displayClockOutTime ?? '--:--',
              status: todayAttendance?.clockOutStatusText ?? 'Pending',
              color: const Color(0xFFEF4444),
              statusColor:
                  todayAttendance?.clockOutStatusColor ?? Colors.grey[400]!,
              isClockIn: false,
              // FIXED: Only active if there's actual clock out data
              isActive:
                  todayAttendance?.clockOut != null &&
                  todayAttendance!.clockOut!.isNotEmpty,
              isEnabled: canClockOut && isWorkingDay,
            ),
          ),
        ],
      );
    });
  }
}

class ClockCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String status;
  final Color color;
  final Color statusColor;
  final bool isClockIn;
  final bool isActive;
  final bool isEnabled;

  const ClockCard({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.status,
    required this.color,
    required this.statusColor,
    required this.isClockIn,
    required this.isActive,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED: Check if actually completed (not just showing placeholder time)
    final bool isCompleted = time != '--:--' && time != 'Not yet' && isActive;
    final double opacity = isEnabled ? 1.0 : 0.6;

    return Container(
      height: 120.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12 * opacity),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.15 * opacity),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08 * opacity),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row - Icon and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? statusColor.withOpacity(0.2 * opacity)
                      : color.withOpacity(0.15 * opacity),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(opacity),
                  size: 16.sp,
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2 * opacity),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9 * opacity),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          // Content - Title and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8 * opacity),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4.h),

              // FIXED: Time Display with proper checking
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(opacity),
                  fontSize: isCompleted ? 14.sp : 12.sp,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: isCompleted ? -0.2 : 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Bottom indicator - FIXED
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : isEnabled
                          ? Icons.schedule_rounded
                          : Icons.block_rounded,
                      color: isCompleted
                          ? statusColor.withOpacity(opacity)
                          : Colors.white.withOpacity(0.4 * opacity),
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        isCompleted
                            ? 'Done'
                            : isEnabled
                            ? 'Ready'
                            : 'Disabled',
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.white.withOpacity(0.6 * opacity)
                              : Colors.white.withOpacity(0.4 * opacity),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? statusColor.withOpacity(opacity)
                      : Colors.white.withOpacity(0.3 * opacity),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
