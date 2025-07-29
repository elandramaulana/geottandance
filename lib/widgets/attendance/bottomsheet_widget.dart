// lib/screens/widgets/attendance_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/widgets/attendance/action_button_widget.dart';
import 'package:geottandance/widgets/attendance/currenttime_display_widget.dart';
import 'package:geottandance/widgets/attendance/daily_statuscard_widget.dart';
import 'package:geottandance/widgets/attendance/today_summary_widget.dart';

class AttendanceBottomSheet extends StatelessWidget {
  final AttendanceController controller;
  final String currentTime;

  const AttendanceBottomSheet({
    Key? key,
    required this.controller,
    required this.currentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 30.r,
                offset: Offset(0, -8.h),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _buildModernHandle(),
                DailyStatusCard(controller: controller),
                CurrentTimeDisplay(currentTime: currentTime),
                TodaysSummaryCard(controller: controller),
                SizedBox(height: 20.h),
                ActionButtons(controller: controller),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHandle() {
    return Container(
      margin: EdgeInsets.only(top: 16.h, bottom: 24.h),
      width: 50.w,
      height: 5.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}
