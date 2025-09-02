import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geottandance/controllers/history_controller.dart';
import 'package:geottandance/models/history_model.dart';
import 'package:geottandance/core/app_routes.dart';

class HistoryScreen extends GetView<AttendanceHistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5C),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Content Section
          Expanded(
            child: GetBuilder<AttendanceHistoryController>(
              builder: (controller) {
                // Show loading only when initially loading and no data
                if (controller.isLoading && !controller.hasData) {
                  return _buildLoadingState();
                }

                // Show error state only when there's an actual error (not just empty data)
                if (controller.hasError && controller.errorMessage.isNotEmpty) {
                  // Check if error is due to validation or actual server error
                  bool isValidationError = controller.errorMessage
                      .toLowerCase()
                      .contains('validation');
                  bool isServerError =
                      !isValidationError &&
                      (controller.errorMessage.toLowerCase().contains(
                            'failed',
                          ) ||
                          controller.errorMessage.toLowerCase().contains(
                            'error',
                          ) ||
                          controller.errorMessage.toLowerCase().contains(
                            'connection',
                          ));

                  // Only show error state for server errors, not validation errors
                  if (isServerError) {
                    return _buildErrorState();
                  }
                }

                // Show empty state when no data (either no filters or filters with no results)
                if (!controller.hasData) {
                  return _buildEmptyState();
                }

                return _buildAttendanceList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: GetBuilder<AttendanceHistoryController>(
        builder: (controller) {
          bool hasActiveFilters =
              controller.selectedStatus != null ||
              controller.startDate != null ||
              controller.endDate != null ||
              (controller.selectedMonth != null &&
                  controller.selectedYear != null);

          return Column(
            children: [
              // First row: Filter buttons
              Row(
                children: [
                  // Filter Category Button
                  Expanded(
                    flex: 1,
                    child: InkWell(
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
                            if (hasActiveFilters) ...[
                              Container(
                                width: 6.w,
                                height: 6.h,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D5C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Date Range Button
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => _showCustomDateRangePicker(),
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
                    ),
                  ),
                ],
              ),

              // Clear Filter Button (moved below)
              if (hasActiveFilters) ...[
                SizedBox(height: 12.h),
                SizedBox(
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336).withOpacity(0.1),
                      foregroundColor: const Color(0xFFF44336),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(
                          color: const Color(0xFFF44336).withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _getFilterText() {
    if (controller.selectedStatus != null) {
      return controller.selectedStatus ?? 'Filter Category';
    }
    return 'Filter Category';
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 420.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
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
            ),

            // Filter Options
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildFilterOption(
                      icon: Icons.apps_rounded,
                      title: 'All Records',
                      isSelected: controller.selectedStatus == null,
                      onTap: () {
                        controller.setStatusFilter(null);
                        Get.back();
                        _applyFiltersWithDelay();
                      },
                    ),
                    _buildFilterOption(
                      icon: Icons.check_circle_rounded,
                      title: 'Present',
                      color: const Color(0xFF4CAF50),
                      isSelected: controller.selectedStatus == 'present',
                      onTap: () {
                        controller.setStatusFilter('present');
                        Get.back();
                        _applyFiltersWithDelay();
                      },
                    ),
                    _buildFilterOption(
                      icon: Icons.access_time_rounded,
                      title: 'Late',
                      color: const Color(0xFFFF9800),
                      isSelected: controller.selectedStatus == 'late',
                      onTap: () {
                        controller.setStatusFilter('late');
                        Get.back();
                        _applyFiltersWithDelay();
                      },
                    ),
                    _buildFilterOption(
                      icon: Icons.cancel_rounded,
                      title: 'Absent',
                      color: const Color(0xFFF44336),
                      isSelected: controller.selectedStatus == 'absent',
                      onTap: () {
                        controller.setStatusFilter('absent');
                        Get.back();
                        _applyFiltersWithDelay();
                      },
                    ),
                    _buildFilterOption(
                      icon: Icons.medical_services_rounded,
                      title: 'Sick/Leave',
                      color: const Color(0xFF9C27B0),
                      isSelected: controller.selectedStatus == 'sick',
                      onTap: () {
                        controller.setStatusFilter('sick');
                        Get.back();
                        _applyFiltersWithDelay();
                      },
                    ),
                    _buildFilterOption(
                      icon: Icons.celebration_rounded,
                      title: 'Holiday',
                      color: const Color(0xFFE91E63),
                      isSelected: controller.selectedStatus == 'holiday',
                      onTap: () {
                        controller.setStatusFilter('holiday');
                        Get.back();
                        _applyFiltersWithDelay();
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  String _getDateRangeText() {
    if (controller.startDate != null && controller.endDate != null) {
      // Show only month and year instead of full date range
      final startMonth = DateFormat('MMM yyyy').format(controller.startDate!);
      final endMonth = DateFormat('MMM yyyy').format(controller.endDate!);

      if (startMonth == endMonth) {
        return startMonth;
      } else {
        return '$startMonth - $endMonth';
      }
    }

    if (controller.selectedMonth != null && controller.selectedYear != null) {
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
      return '${monthNames[controller.selectedMonth! - 1]} ${controller.selectedYear}';
    }

    return 'Select Date Range';
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          controller.startDate != null && controller.endDate != null
          ? DateTimeRange(
              start: controller.startDate!,
              end: controller.endDate!,
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
      _applyFiltersWithDelay();
    }
  }

  void _applyFiltersWithDelay() {
    Future.delayed(const Duration(milliseconds: 200), () {
      controller.applyFilters();
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D5C)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading attendance data...',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40.sp,
                color: const Color(0xFFF44336),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                'Try Again',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFF666666).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 40.sp,
                color: const Color(0xFF666666),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Records Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No attendance records match your current filter settings',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: const Color(0xFF2E7D5C),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount:
            controller.attendances.length + (controller.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.attendances.length) {
            return _buildLoadMoreIndicator();
          }

          final attendance = controller.attendances[index];
          return _buildAttendanceCard(attendance);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: controller.isLoadingMore
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D5C)),
                strokeWidth: 3,
              )
            : ElevatedButton.icon(
                onPressed: () => controller.loadMoreData(),
                icon: Icon(Icons.expand_more_rounded, size: 20.sp),
                label: Text(
                  'Load More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D5C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceHistory attendance) {
    return InkWell(
      onTap: () => _navigateToHistoryDetail(attendance),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Status Row - FIXED LAYOUT
              Row(
                children: [
                  // Date Section - Fixed width to prevent overflow
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D5C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDateNumber(attendance.date),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D5C),
                          ),
                        ),
                        Text(
                          _getMonthText(attendance.date),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2E7D5C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Date Text Section - Flexible with proper constraints
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDisplayDate(attendance.date),
                          style: TextStyle(
                            fontSize: 15.sp, // Slightly reduced from 16.sp
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          attendance.dayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w), // Add spacing before status badge
                  // Status Badge - Fixed width to prevent overflow
                  _buildStatusBadge(attendance.status, attendance.statusLabel),
                ],
              ),

              SizedBox(height: 16.h),

              // Time Cards Row
              Row(
                children: [
                  // Clock In
                  Expanded(
                    child: _buildTimeCard(
                      'IN',
                      attendance.clockIn ?? '--:--',
                      const Color(0xFF4CAF50),
                      Icons.login_rounded,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Duration
                  Expanded(
                    child: _buildTimeCard(
                      'DURATION',
                      attendance.formattedWorkDuration,
                      const Color(0xFF2196F3),
                      Icons.access_time_filled_rounded,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Clock Out
                  Expanded(
                    child: _buildTimeCard(
                      'OUT',
                      attendance.clockOut ?? '--:--',
                      const Color(0xFFF44336),
                      Icons.logout_rounded,
                    ),
                  ),
                ],
              ),

              // Office Location and Tap indicator
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Office Location - Flexible with overflow handling
                  if (attendance.office.name.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: const Color(0xFFFF9800),
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                attendance.office.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFFFF9800),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(width: 8.w),

                  // Tap to view detail indicator - Fixed width
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D5C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tap for details',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF2E7D5C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: const Color(0xFF2E7D5C),
                          size: 10.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String statusLabel) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'present':
        backgroundColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case 'late':
        backgroundColor = const Color(0xFFFF9800);
        textColor = Colors.white;
        icon = Icons.access_time_rounded;
        break;
      case 'absent':
        backgroundColor = const Color(0xFFF44336);
        textColor = Colors.white;
        icon = Icons.cancel_rounded;
        break;
      case 'sick':
        backgroundColor = const Color(0xFF9C27B0);
        textColor = Colors.white;
        icon = Icons.medical_services_rounded;
        break;
      case 'holiday':
        backgroundColor = const Color(0xFFE91E63);
        textColor = Colors.white;
        icon = Icons.celebration_rounded;
        break;
      default:
        backgroundColor = const Color(0xFF666666);
        textColor = Colors.white;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: 100.w, // Limit maximum width to prevent overflow
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              statusLabel,
              style: TextStyle(
                color: textColor,
                fontSize: 11.sp, // Slightly reduced from 12.sp
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateNumber(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return date.day.toString();
    } catch (e) {
      return '1';
    }
  }

  String _getMonthText(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
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
      return months[date.month - 1];
    } catch (e) {
      return 'Jan';
    }
  }

  String _formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Navigation to History Detail
  void _navigateToHistoryDetail(AttendanceHistory attendance) {
    try {
      // Debug print untuk memastikan data benar
      print('🔍 Navigating to detail for attendance ID: ${attendance.id}');
      print('📅 Date: ${attendance.date}');
      print('⏰ Clock In: ${attendance.clockIn}');
      print('⏰ Clock Out: ${attendance.clockOut}');

      // Navigate langsung ke detail screen dengan attendance ID
      Get.toNamed(
        AppRoutes.historyDetail,
        arguments: attendance.id, // Pass attendance ID sebagai argument
      );

      print('✅ Navigation command sent successfully');
    } catch (e) {
      print('❌ Navigation error: $e');

      Get.snackbar(
        'Error',
        'Cannot open attendance detail. Please try again.',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        icon: Icon(Icons.error_outline, color: Colors.white, size: 24.sp),
      );
    }
  }
}
