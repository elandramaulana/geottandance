import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:geottandance/controllers/navbar_controller.dart';
import 'package:get/get.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();

    final List iconList = [
      Icons.home_rounded,
      Icons.history_rounded,
      Icons.description_rounded,
      Icons.person_rounded,
    ];

    return Obx(
      () => AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 30.sp,
                color: isActive ? const Color(0xFFCCAC6B) : Colors.white,
              ),
            ],
          );
        },
        backgroundColor: const Color(0xFF2E7D5F),
        // Perbaikan mapping activeIndex
        activeIndex: _getActiveIndex(controller.selectedIndex.value),
        splashColor: const Color(0xFFCCAC6B).withOpacity(0.3),
        notchSmoothness: NotchSmoothness.softEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32.r,
        rightCornerRadius: 32.r,
        onTap: (index) {
          int actualIndex = _getActualIndex(index);
          controller.changeTabIndex(actualIndex);
        },
        height: 50.h,
        elevation: 8,
        shadow: BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ),
    );
  }

  int _getActiveIndex(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return -1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  int _getActualIndex(int bottomNavIndex) {
    switch (bottomNavIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  // Floating Action Button untuk Absence (center button)
  Widget buildCenterFAB(NavigationController controller) {
    return Obx(
      () => FloatingActionButton(
        onPressed: () => controller.changeTabIndex(2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: controller.selectedIndex.value == 2
                ? LinearGradient(
                    colors: [
                      const Color(0xFFCCAC6B),
                      const Color(0xFFCCAC6B).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF2E7D5F),
                      const Color(0xFF2E7D5F).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color:
                    controller.selectedIndex.value ==
                        2 // Check index 2 untuk FAB
                    ? const Color(0xFFCCAC6B).withOpacity(0.4)
                    : const Color(0xFF2E7D5F).withOpacity(0.4),
                blurRadius: controller.selectedIndex.value == 2 ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.fingerprint_rounded,
            color: Colors.white,
            size: controller.selectedIndex.value == 2 ? 30.sp : 28.sp,
          ),
        ),
      ),
    );
  }
}
