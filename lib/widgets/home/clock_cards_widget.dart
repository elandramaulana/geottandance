import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/home_controller.dart';
import 'package:get/get.dart';

class ClockCardsWidget extends StatelessWidget {
  final HomeController controller;

  const ClockCardsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClockCard(
            icon: Icons.login,
            title: 'Clock In',
            time: '12:00 PM',
            status: 'On Time',
            color: Color(0xFF10B981),
            isClockIn: true,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ClockCard(
            icon: Icons.logout,
            title: 'Clock Out',
            time: '12:00 PM',
            status: 'On Time',
            color: Color(0xFFEF4444),
            isClockIn: false,
          ),
        ),
      ],
    );
  }
}

class ClockCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String status;
  final Color color;
  final bool isClockIn;

  const ClockCard({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.status,
    required this.color,
    required this.isClockIn,
  });

  Color _getStatusColor(String status, bool isClockIn) {
    if (isClockIn) {
      switch (status.toLowerCase()) {
        case 'early':
          return Colors.blue;
        case 'on time':
          return Colors.green;
        case 'late':
          return Colors.red;
        default:
          return Colors.grey;
      }
    } else {
      switch (status.toLowerCase()) {
        case 'completed':
          return Colors.green;
        case 'in progress':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status, isClockIn);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor.withValues(alpha: 0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
