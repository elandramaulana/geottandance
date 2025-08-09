import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
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
                  HomeHeaderWidget(currentDate: _getCurrentDate()),

                  SizedBox(height: 20.h),

                  // Clock In/Out Cards
                  ClockCardsWidget(controller: controller),

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
                      // Summary Section
                      SummarySectionWidget(),

                      SizedBox(height: 10.h),

                      // Recent Activity Section
                      RecentActivityWidget(),

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
}
