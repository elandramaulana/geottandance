import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummarySectionWidget extends StatelessWidget {
  const SummarySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C5B41),
          ),
        ),
        SizedBox(height: 20.h),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'This Month',
                value: '22',
                subtitle: 'Working Days',
                icon: Icons.calendar_month,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SummaryCard(
                title: 'Present',
                value: '20',
                subtitle: 'Days',
                icon: Icons.check_circle,
                color: Color(0xFF10B981),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SummaryCard(
                title: 'Absent',
                value: '2',
                subtitle: 'Days',
                icon: Icons.cancel,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),

          SizedBox(height: 14.h),

          // Title
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 6.h),

          // Value
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 2.h),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12.h),

          // Decorative bottom accent
          Container(
            height: 3.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
