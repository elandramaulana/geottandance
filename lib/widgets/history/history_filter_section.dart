// lib/screens/history/widgets/history_filter_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/widgets/history/hitory_filter_bottomsheet.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geottandance/controllers/history_controller.dart';

class HistoryFilterSection extends StatelessWidget {
  final AttendanceHistoryController controller;
  final VoidCallback onFilterApplied;

  const HistoryFilterSection({
    super.key,
    required this.controller,
    required this.onFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Obx(() {
        bool hasActiveFilters =
            controller.selectedStatus.value != null ||
            controller.startDate.value != null ||
            controller.endDate.value != null ||
            (controller.selectedMonth.value != null &&
                controller.selectedYear.value != null);

        return Column(
          children: [
            Row(
              children: [
                Expanded(flex: 1, child: _buildFilterButton(hasActiveFilters)),
                SizedBox(width: 8.w),
                Expanded(flex: 2, child: _buildDateRangeButton()),
              ],
            ),
            if (hasActiveFilters) ...[
              SizedBox(height: 12.h),
              _buildClearFiltersButton(),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildFilterButton(bool hasActiveFilters) {
    return InkWell(
      onTap: () => _showFilterBottomSheet(),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: hasActiveFilters
                  ? const Color(0xFF2E7D5C)
                  : const Color(0xFF666666),
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                _getFilterText(),
                style: TextStyle(
                  color: hasActiveFilters
                      ? const Color(0xFF2E7D5C)
                      : const Color(0xFF666666),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasActiveFilters)
              Container(
                width: 6.w,
                height: 6.h,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D5C),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    return InkWell(
      onTap: _showCustomDateRangePicker,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: const Color(0xFF666666),
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                _getDateRangeText(),
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF666666),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          controller.clearFilters();
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.loadAllHistory();
          });
        },
        icon: Icon(Icons.clear_rounded, size: 16.sp),
        label: Text(
          'Clear All Filters',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF44336).withOpacity(0.1),
          foregroundColor: const Color(0xFFF44336),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: const Color(0xFFF44336).withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  String _getFilterText() {
    if (controller.selectedStatus.value != null) {
      return controller.selectedStatus.value ?? 'Filter Category';
    }
    return 'Filter Category';
  }

  String _getDateRangeText() {
    if (controller.startDate.value != null &&
        controller.endDate.value != null) {
      final startMonth = DateFormat(
        'MMM yyyy',
      ).format(controller.startDate.value!);
      final endMonth = DateFormat('MMM yyyy').format(controller.endDate.value!);

      if (startMonth == endMonth) {
        return startMonth;
      } else {
        return '$startMonth - $endMonth';
      }
    }

    if (controller.selectedMonth.value != null &&
        controller.selectedYear.value != null) {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${monthNames[controller.selectedMonth.value! - 1]} ${controller.selectedYear.value}';
    }

    return 'Select Date Range';
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      HistoryFilterBottomSheet(
        controller: controller,
        onFilterSelected: onFilterApplied,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          controller.startDate.value != null && controller.endDate.value != null
          ? DateTimeRange(
              start: controller.startDate.value!,
              end: controller.endDate.value!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D5C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRangeFilter(picked.start, picked.end);
      onFilterApplied();
    }
  }
}
