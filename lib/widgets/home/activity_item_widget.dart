// lib/widgets/home/activity_item_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/widgets/home/activity_helper_widget.dart';

class ActivityItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final String status;
  final String activityType;
  final String? description;
  final String? fullAddress;

  const ActivityItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.status,
    required this.activityType,
    this.description,
    this.fullAddress,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            // Show activity details in bottom sheet
            _showActivityDetails(context);
          },
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
                          color: ActivityHelpers.getActivityTypeColor(
                            activityType,
                          ),
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
                          ActivityHelpers.getActivityTypeIcon(activityType),
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
                                  ActivityHelpers.getActivityTypeLabel(
                                    activityType,
                                  ),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: ActivityHelpers.getActivityTypeColor(
                                      activityType,
                                    ),
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
                                  ActivityHelpers.getStatusColor(
                                    status,
                                  ).withValues(alpha: 0.15),
                                  ActivityHelpers.getStatusColor(
                                    status,
                                  ).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: ActivityHelpers.getStatusColor(
                                  status,
                                ).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  ActivityHelpers.getStatusIcon(status),
                                  size: 9.sp,
                                  color: ActivityHelpers.getStatusColor(status),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ActivityHelpers.getStatusColor(
                                      status,
                                    ),
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
                                if (subtitle.isNotEmpty &&
                                    subtitle != 'No location') ...[
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
                                ],
                                if (ActivityHelpers.shouldShowLocationInfo(
                                      activityType,
                                    ) &&
                                    subtitle.isNotEmpty &&
                                    subtitle != 'No location') ...[
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
                                          subtitle,
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
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 0.6.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: color, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        Text(
                          ActivityHelpers.getActivityTypeLabel(activityType),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and Status
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: ActivityHelpers.getStatusColor(
                              status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: ActivityHelpers.getStatusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Description
                    if (description != null && description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Location
                    if (fullAddress != null && fullAddress!.isNotEmpty) ...[
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              fullAddress!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Close button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1C5B41),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
