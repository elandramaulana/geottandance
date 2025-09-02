// lib/widgets/attendance/attendance_appbar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:get/get.dart';

class AttendanceTopAppBar extends StatelessWidget {
  const AttendanceTopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.find<AttendanceController>();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 70.h,

        decoration: const BoxDecoration(
          color: Colors.transparent, // Fully transparent background
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Refresh Button (left side)
                Obx(
                  () => GestureDetector(
                    onTap: controller.isLoading
                        ? null
                        : () => controller.refreshLocation(),
                    child: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: controller.isLoading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF667EEA),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              color: const Color(0xFF667EEA),
                              size: 20.r,
                            ),
                    ),
                  ),
                ),

                // Title
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Location/GPS Button (right side)
                Obx(
                  () => GestureDetector(
                    onTap: controller.isLoading
                        ? null
                        : () => controller.refreshLocation(),
                    child: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: controller.isLoading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF667EEA),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.my_location_rounded,
                              color: const Color(0xFF667EEA),
                              size: 20.r,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
