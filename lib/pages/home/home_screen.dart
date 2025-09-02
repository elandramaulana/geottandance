// lib/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/home_controller.dart';
import 'package:geottandance/widgets/home/activity_widget.dart';
import 'package:geottandance/widgets/home/clock_cards_widget.dart';
import 'package:geottandance/widgets/home/home_header_widget.dart';
import 'package:geottandance/widgets/home/summary_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  String _getCurrentDate() {
    return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshHomeData,
          color: Color(0xFF1C5B41),
          child: Stack(
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

              // Error Banner (if any)
              if (controller.errorMessage.isNotEmpty) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      margin: EdgeInsets.all(16.w),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.errorMessage,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.clearError(),
                            icon: Icon(
                              Icons.close,
                              color: Colors.red[700],
                              size: 16.sp,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Main Content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header with real user name
                      HomeHeaderWidget(
                        currentDate: _getCurrentDate(),
                        userName: controller.currentUserName,
                        officeName: controller.currentOfficeName,
                      ),

                      SizedBox(height: 20.h),

                      // Loading indicator for clock cards
                      if (controller.isLoading)
                        SizedBox(
                          height: 120.h,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.w,
                            ),
                          ),
                        )
                      else
                        // Clock In/Out Cards with real data
                        ClockCardsWidget(),

                      SizedBox(height: 20.h),
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
                          // Summary Section (unchanged as requested)
                          EnhancedSummarySectionWidget(),

                          SizedBox(height: 10.h),

                          // Recent Activity Section with real data
                          RecentActivityWidget(),

                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Non-working day overlay
              if (!controller.isWorkingDay && !controller.isLoading) ...[
                Positioned(
                  top: 200.h,
                  left: 20.w,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            controller.attendanceMessage,
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
