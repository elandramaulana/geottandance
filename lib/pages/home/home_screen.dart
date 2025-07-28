import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1C5B41),
                  Color(0xFF2E7D5F),
                  Color(0xFF3A8B6A),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Top Header Section
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Text(
                            'John Doe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _getCurrentDate(),
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Clock In/Out Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildClockCard(
                          icon: Icons.login,
                          title: 'Clock In',
                          time: '08:00 AM',
                          status: 'On Time',
                          color: Color(0xFF10B981),
                          isClockIn: true,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildClockCard(
                          icon: Icons.logout,
                          title: 'Clock Out',
                          time: '--:--',
                          status: 'Not Yet',
                          color: Color(0xFFEF4444),
                          isClockIn: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom White Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.51.sh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 30.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Section
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
                            child: _buildSummaryCard(
                              title: 'This Month',
                              value: '22',
                              subtitle: 'Working Days',
                              icon: Icons.calendar_month,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Present',
                              value: '20',
                              subtitle: 'Days',
                              icon: Icons.check_circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Absent',
                              value: '2',
                              subtitle: 'Days',
                              icon: Icons.cancel,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // Recent Activity Section
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
                      _buildActivityItem(
                        icon: Icons.login,
                        title: "Morning Check-in",
                        subtitle: "Regular attendance",
                        time: "08:00 AM",
                        color: Color(0xFF059669),
                        status: "on time",
                        activityType: "clockin", // Parameter baru
                      ),
                      SizedBox(height: 2.h),
                      _buildActivityItem(
                        icon: Icons.logout,
                        title: 'Clock Out',
                        subtitle: 'Yesterday at 05:00 PM',
                        time: '1d ago',
                        color: Color(0xFFEF4444),
                        status: 'Completed',
                        activityType: "visit",
                      ),
                      SizedBox(height: 2.h),
                      _buildActivityItem(
                        icon: Icons.medical_services,
                        title: 'Sick Leave',
                        subtitle: 'Leave request approved',
                        time: '3d ago',
                        color: Color(0xFF8B5CF6),
                        status: 'Approved',
                        activityType: "onleave",
                      ),
                      SizedBox(height: 2.h),
                      _buildActivityItem(
                        icon: Icons.event_available,
                        title: 'Annual Leave',
                        subtitle: 'Vacation request submitted',
                        time: '5d ago',
                        color: Color(0xFFF59E0B),
                        status: 'Pending',
                        activityType: "break",
                      ),
                      SizedBox(height: 2.h),
                      _buildActivityItem(
                        icon: Icons.event_available,
                        title: 'Annual Leave',
                        subtitle: 'Vacation request submitted',
                        time: '5d ago',
                        color: Color(0xFFF59E0B),
                        status: 'Pending',
                        activityType: "overtime",
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM dd, yyyy').format(now);
  }

  Widget _buildClockCard({
    required IconData icon,
    required String title,
    required String time,
    required String status,
    required Color color,
    required bool isClockIn,
  }) {
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
                  color: isClockIn
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isClockIn ? Colors.green[300] : Colors.orange[300],
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required String status,
    required String activityType, // Added activity type parameter
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!.withValues(alpha: 0.3)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Row(
          children: [
            // Enhanced Icon Container with Activity Type Indicator
            Stack(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 22.sp),
                ),

                // Activity Type Badge
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: _getActivityTypeColor(activityType),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getActivityTypeIcon(activityType),
                      color: Colors.white,
                      size: 8.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 14.w),

            // Enhanced Content Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row with Activity Type
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                                height: 1.2,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              _getActivityTypeLabel(activityType),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _getActivityTypeColor(activityType),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Enhanced Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(status).withValues(alpha: 0.15),
                              _getStatusColor(status).withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: _getStatusColor(
                              status,
                            ).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              size: 9.sp,
                              color: _getStatusColor(status),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: _getStatusColor(status),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Subtitle and Time Row with Location Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_shouldShowLocationInfo(activityType)) ...[
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 10.sp,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      _getLocationText(activityType),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Enhanced Time Display
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[100]!, Colors.grey[50]!],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 10.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for activity types
  Color _getActivityTypeColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
        return Color(0xFF059669); // Green
      case 'clockout':
        return Color(0xFFDC2626); // Red
      case 'visit':
        return Color(0xFF2563EB); // Blue
      case 'onleave':
        return Color(0xFFD97706); // Orange
      case 'break':
        return Color(0xFF7C3AED); // Purple
      case 'overtime':
        return Color(0xFFEA580C); // Orange-red
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  IconData _getActivityTypeIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
        return Icons.login;
      case 'clockout':
        return Icons.logout;
      case 'visit':
        return Icons.location_on;
      case 'onleave':
        return Icons.event_busy;
      case 'break':
        return Icons.coffee;
      case 'overtime':
        return Icons.schedule;
      default:
        return Icons.work;
    }
  }

  String _getActivityTypeLabel(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
        return 'CLOCK IN';
      case 'clockout':
        return 'CLOCK OUT';
      case 'visit':
        return 'SITE VISIT';
      case 'onleave':
        return 'ON LEAVE';
      case 'break':
        return 'BREAK TIME';
      case 'overtime':
        return 'OVERTIME';
      default:
        return activityType.toUpperCase();
    }
  }

  bool _shouldShowLocationInfo(String activityType) {
    return [
      'clockin',
      'clockout',
      'visit',
    ].contains(activityType.toLowerCase());
  }

  String _getLocationText(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
      case 'clockout':
        return 'Office Building A';
      case 'visit':
        return 'Client Site - PT. Example';
      default:
        return 'Unknown Location';
    }
  }

  // Enhanced status color method
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'on time':
      case 'completed':
      case 'success':
        return Color(0xFF059669); // Emerald
      case 'pending':
      case 'waiting':
        return Color(0xFFD97706); // Amber
      case 'rejected':
      case 'failed':
        return Color(0xFFDC2626); // Red
      case 'late':
        return Color(0xFFEA580C); // Orange
      case 'in progress':
      case 'active':
        return Color(0xFF2563EB); // Blue
      case 'early':
        return Color(0xFF7C3AED); // Purple
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  // Status icon method
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'on time':
      case 'completed':
      case 'success':
        return Icons.check_circle;
      case 'pending':
      case 'waiting':
        return Icons.access_time;
      case 'rejected':
      case 'failed':
        return Icons.cancel;
      case 'late':
        return Icons.warning;
      case 'in progress':
      case 'active':
        return Icons.play_circle;
      case 'early':
        return Icons.fast_forward;
      default:
        return Icons.help;
    }
  }
}
