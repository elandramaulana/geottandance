import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'activity_item_widget.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C5B41),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF2E7D5F),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),

        // Activity List
        ActivityItemWidget(
          icon: Icons.login,
          title: "Morning Check-in",
          subtitle: "Regular attendance",
          time: "08:00 AM",
          color: Color(0xFF059669),
          status: "on time",
          activityType: "clockin",
        ),
        SizedBox(height: 2.h),
        ActivityItemWidget(
          icon: Icons.logout,
          title: 'Clock Out',
          subtitle: 'Yesterday at 05:00 PM',
          time: '1d ago',
          color: Color(0xFFEF4444),
          status: 'Completed',
          activityType: "visit",
        ),
        SizedBox(height: 2.h),
        ActivityItemWidget(
          icon: Icons.medical_services,
          title: 'Sick Leave',
          subtitle: 'Leave request approved',
          time: '3d ago',
          color: Color(0xFF8B5CF6),
          status: 'Approved',
          activityType: "onleave",
        ),
        SizedBox(height: 2.h),
        ActivityItemWidget(
          icon: Icons.event_available,
          title: 'Annual Leave',
          subtitle: 'Vacation request submitted',
          time: '5d ago',
          color: Color(0xFFF59E0B),
          status: 'Pending',
          activityType: "break",
        ),
        SizedBox(height: 2.h),
        ActivityItemWidget(
          icon: Icons.event_available,
          title: 'Annual Leave',
          subtitle: 'Vacation request submitted',
          time: '5d ago',
          color: Color(0xFFF59E0B),
          status: 'Pending',
          activityType: "overtime",
        ),
      ],
    );
  }
}
