// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/widgets/history/history_attendance_card.dart';
import 'package:geottandance/widgets/history/history_filter_section.dart';
import 'package:geottandance/widgets/history/history_state.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/history_controller.dart';
import 'package:geottandance/models/history_model.dart';
import 'package:geottandance/core/app_routes.dart';

class HistoryScreen extends GetView<AttendanceHistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          HistoryFilterSection(
            controller: controller,
            onFilterApplied: _applyFiltersWithDelay,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildBody() {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value && !controller.hasData) {
        return const LoadingState();
      }

      // Error state - only show for server errors
      if (controller.shouldShowErrorState) {
        return ErrorState(
          errorMessage: controller.errorMessage.value,
          onRetry: controller.refreshData,
        );
      }

      // Empty state
      if (!controller.hasData) {
        return const HistoryEmptyState();
      }

      // Success state - show list
      return _buildAttendanceList();
    });
  }

  Widget _buildAttendanceList() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
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
          return HistoryAttendanceCard(
            attendance: attendance,
            onTap: () => _navigateToHistoryDetail(attendance),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: controller.isLoadingMore.value
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D5C)),
                  strokeWidth: 3,
                )
              : ElevatedButton.icon(
                  onPressed: controller.loadMoreData,
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
    });
  }

  void _applyFiltersWithDelay() {
    Future.delayed(const Duration(milliseconds: 200), () {
      controller.applyFilters();
    });
  }

  void _navigateToHistoryDetail(AttendanceHistory attendance) {
    try {
      print('🔍 Navigating to detail for attendance ID: ${attendance.id}');
      print('📅 Date: ${attendance.date}');
      print('⏰ Clock In: ${attendance.clockIn}');
      print('⏰ Clock Out: ${attendance.clockOut}');

      Get.toNamed(AppRoutes.historyDetail, arguments: attendance.id);

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
