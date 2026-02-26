// lib/screens/history/widgets/history_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/history_controller.dart';

class HistoryFilterBottomSheet extends StatelessWidget {
  final AttendanceHistoryController controller;
  final VoidCallback onFilterSelected;

  const HistoryFilterBottomSheet({
    super.key,
    required this.controller,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Obx(
                () => Column(
                  children: [
                    _buildFilterOption(
                      icon: Icons.apps_rounded,
                      title: 'All Records',
                      isSelected: controller.selectedStatus.value == null,
                      onTap: () => _selectFilter(null),
                    ),
                    _buildFilterOption(
                      icon: Icons.check_circle_rounded,
                      title: 'Present',
                      color: const Color(0xFF4CAF50),
                      isSelected: controller.selectedStatus.value == 'present',
                      onTap: () => _selectFilter('present'),
                    ),
                    _buildFilterOption(
                      icon: Icons.access_time_rounded,
                      title: 'Late',
                      color: const Color(0xFFFF9800),
                      isSelected: controller.selectedStatus.value == 'late',
                      onTap: () => _selectFilter('late'),
                    ),
                    _buildFilterOption(
                      icon: Icons.cancel_rounded,
                      title: 'Absent',
                      color: const Color(0xFFF44336),
                      isSelected: controller.selectedStatus.value == 'absent',
                      onTap: () => _selectFilter('absent'),
                    ),
                    _buildFilterOption(
                      icon: Icons.medical_services_rounded,
                      title: 'Sick/Leave',
                      color: const Color(0xFF9C27B0),
                      isSelected: controller.selectedStatus.value == 'sick',
                      onTap: () => _selectFilter('sick'),
                    ),
                    _buildFilterOption(
                      icon: Icons.celebration_rounded,
                      title: 'Holiday',
                      color: const Color(0xFFE91E63),
                      isSelected: controller.selectedStatus.value == 'holiday',
                      onTap: () => _selectFilter('holiday'),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close_rounded,
              size: 24.sp,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? const Color(0xFF666666);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? optionColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: optionColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: optionColor, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? optionColor : const Color(0xFF333333),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: optionColor, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _selectFilter(String? status) {
    controller.setStatusFilter(status);
    Get.back();
    onFilterSelected();
  }
}
