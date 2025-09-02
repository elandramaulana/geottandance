// lib/widgets/home/activity_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/home_controller.dart';
import 'package:geottandance/widgets/home/activity_item_widget.dart';
import 'package:geottandance/core/app_routes.dart';

class RecentActivityWidget extends GetView<HomeController> {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                onPressed: () {
                  // Navigate to history page
                  Get.toNamed(AppRoutes.history);
                },
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

          // Loading state
          if (controller.isLoading) ...[
            _buildLoadingState(),
          ]
          // Error state
          else if (controller.errorMessage.isNotEmpty &&
              controller.recentActivities.isEmpty) ...[
            _buildErrorState(),
          ]
          // Empty state
          else if (controller.recentActivities.isEmpty) ...[
            _buildEmptyState(),
          ]
          // Activity list with filtered data
          else ...[
            _buildActivityList(),
          ],

          // Show working day message if applicable
          if (!controller.isWorkingDay &&
              !controller.isLoading &&
              controller.attendanceMessage.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildWorkingDayInfo(),
          ],
        ],
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: Color(0xFF1C5B41),
              strokeWidth: 2.w,
            ),
            SizedBox(height: 12.h),
            Text(
              'Loading activities...',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40.sp, color: Colors.red[400]),
          SizedBox(height: 12.h),
          Text(
            'Failed to load activities',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            controller.errorMessage,
            style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: () => controller.loadRecentActivities(),
            icon: Icon(Icons.refresh, size: 16.sp),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 40.sp, color: Colors.grey[400]),
          SizedBox(height: 12.h),
          Text(
            'No recent activities',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your attendance activities will appear here',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    // FIXED: Get only the 5 most recent activities (already sorted by API)
    final displayActivities = controller.recentActivities.take(5).toList();

    return Column(
      children: [
        // Show today's summary if any today activities exist
        ...displayActivities.map((activity) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: ActivityItemWidget(
              icon: activity.activityIcon,
              title: activity.title,
              subtitle: activity.shortLocationAddress,
              time: activity.formattedDate,
              color: activity.activityColor,
              status: activity.statusFromActivityType,
              activityType: activity.activityType,
              description: activity.description,
              fullAddress: activity.locationAddress,
            ),
          );
        }).toList(),

        // Show activity summary
        if (displayActivities.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildActivitySummary(displayActivities),
        ],
      ],
    );
  }

  Widget _buildActivitySummary(List<dynamic> activities) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final todayActivities = activities.where((activity) {
      final activityDate = DateTime(
        activity.activityTime.year,
        activity.activityTime.month,
        activity.activityTime.day,
      );
      return activityDate == todayDate;
    }).length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1C5B41).withOpacity(0.05),
            Color(0xFF2E7D5F).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFF1C5B41).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today: $todayActivities activities',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C5B41),
            ),
          ),
          Text(
            'Total: ${activities.length} this month',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDayInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.orange[600],
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Non-Working Day',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  controller.attendanceMessage,
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
