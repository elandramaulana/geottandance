// lib/screens/widgets/attendance_top_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';
import 'package:get/get.dart';

class AttendanceTopAppBar extends StatelessWidget {
  const AttendanceTopAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController = Get.put(
      AttendanceController(),
    );
    final AttendanceMapController mapController = Get.put(
      AttendanceMapController(),
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                _buildAppBarButton(
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFF667EEA),
                  onTap: () =>
                      Get.find<AttendanceController>().refreshLocation(),
                ),
                const Spacer(),
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    SizedBox(width: 12.w),
                    _buildAppBarButton(
                      icon: Icons.my_location_rounded,
                      color: const Color(0xFF667EEA),
                      onTap: () => mapController.centerOnCurrentLocation(
                        attendanceController.currentPosition,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20.r),
      ),
    );
  }
}