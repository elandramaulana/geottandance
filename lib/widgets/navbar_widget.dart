import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/controllers/navbar_controller.dart';
import 'package:get/get.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();

    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 40.h,
        ), // Increased vertical margin from 15.h to 25.h
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D5F), // Dark green color
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              index: 0,
              isActive: controller.selectedIndex.value == 0,
              onTap: () => controller.changeTabIndex(0),
            ),
            _buildNavItem(
              icon: Icons.calendar_today,
              label: 'Check Out',
              index: 1,
              isActive: controller.selectedIndex.value == 1,
              onTap: () => controller.changeTabIndex(1),
            ),
            _buildNavItem(
              icon: Icons.receipt_long,
              label: 'Total Hrs',
              index: 2,
              isActive: controller.selectedIndex.value == 2,
              onTap: () => controller.changeTabIndex(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20.w : 30.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFCCAC6B) : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            if (isActive) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
