// widgets/summary_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/summary_history_controller.dart';

class EnhancedSummarySectionWidget extends GetView<SummaryHistoryController> {
  const EnhancedSummarySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with period and refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C5B41),
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(
                  () => controller.summaryData != null
                      ? Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 14.sp,
                              color: Color(0xFF2E7D5F),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              controller.summaryData!.period,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D5F),
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
            Row(
              children: [
                // Month navigation
                Obx(
                  () => controller.hasSummaryData
                      ? Row(
                          children: [
                            IconButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : () => controller.previousMonth(),
                              icon: Icon(
                                Icons.chevron_left,
                                color: Color(0xFF2E7D5F),
                                size: 20.sp,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF2E7D5F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                controller.currentMonthName.substring(0, 3),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D5F),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : () => controller.nextMonth(),
                              icon: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF2E7D5F),
                                size: 20.sp,
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),

                // Debug button (only show in debug mode)
                if (controller.hasSummaryData)
                  IconButton(
                    onPressed: () => _showDebugDialog(context),
                    icon: Icon(
                      Icons.info_outline,
                      color: Color(0xFF2E7D5F).withOpacity(0.5),
                      size: 16.sp,
                    ),
                  ),

                // Refresh button
                Obx(
                  () => IconButton(
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.refreshSummary(),
                    icon: AnimatedRotation(
                      turns: controller.isLoading ? 1.0 : 0.0,
                      duration: Duration(seconds: 1),
                      child: Icon(
                        Icons.refresh,
                        color: Color(0xFF2E7D5F),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Summary Cards with enhanced features
        Obx(() {
          if (controller.isLoading && !controller.hasSummaryData) {
            return _buildLoadingState();
          }

          if (controller.hasError && !controller.hasSummaryData) {
            return _buildErrorState();
          }

          return _buildEnhancedSummaryCards();
        }),

        // Quick stats bar
        Obx(() {
          if (controller.hasSummaryData) {
            return _buildQuickStatsBar();
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  // NEW: Debug dialog to show calculation details
  void _showDebugDialog(BuildContext context) {
    final summary = controller.summaryData!.summary;

    Get.dialog(
      AlertDialog(
        title: Text('Attendance Calculation Debug'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.attendanceDebugInfo,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Close')),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 150.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return Container(
            width: 120.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 60.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 40.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 150.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red[50]!, Colors.red[25]!]),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red[700],
              size: 28.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Failed to load summary',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.errorMessage,
            style: TextStyle(fontSize: 11.sp, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => controller.retry(),
            icon: Icon(Icons.refresh, size: 16.sp),
            label: Text('Retry', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              minimumSize: Size(100.w, 36.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCards() {
    final summaryData = controller.summaryData!.summary;

    final cardData = [
      {
        'title': 'Total Days',
        'value': summaryData.totalDays.toString(),
        'subtitle': 'Working Days',
        'icon': Icons.calendar_month,
        'color': Color(0xFF3B82F6),
        'gradient': [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        'trend': null,
      },
      {
        'title': 'Present',
        'value': summaryData.presentDays,
        'subtitle': 'Days',
        'icon': Icons.check_circle_outline,
        'color': Color(0xFF10B981),
        'gradient': [Color(0xFF10B981), Color(0xFF059669)],
        'trend': '+${summaryData.presentDaysAsInt}',
      },
      {
        'title': 'Late Arrivals',
        'value': summaryData.lateDays,
        'subtitle': 'Days',
        'icon': Icons.access_time,
        'color': Color(0xFFF59E0B),
        'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
        'trend': summaryData.lateDaysAsInt > 0
            ? '-${summaryData.lateDaysAsInt}'
            : null,
      },
      {
        'title': 'Absent',
        'value': summaryData.absentDays,
        'subtitle': 'Days',
        'icon': Icons.cancel_outlined,
        'color': Color(0xFFEF4444),
        'gradient': [Color(0xFFEF4444), Color(0xFFDC2626)],
        'trend': summaryData.absentDaysAsInt > 0
            ? '-${summaryData.absentDaysAsInt}'
            : null,
      },
      {
        'title': 'Leave Days',
        'value': summaryData.leaveDays,
        'subtitle': 'Approved',
        'icon': Icons.event_busy,
        'color': Color(0xFF8B5CF6),
        'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        'trend': null,
      },
      {
        'title': 'Holidays',
        'value': summaryData.holidayDays,
        'subtitle': 'Days',
        'icon': Icons.celebration,
        'color': Color(0xFFEC4899),
        'gradient': [Color(0xFFEC4899), Color(0xFFDB2777)],
        'trend': null,
      },
      {
        'title': 'Attendance',
        // FIXED: Use corrected attendance rate instead of API rate
        'value': '${summaryData.correctedAttendanceRate}%',
        'subtitle': 'Rate',
        'icon': Icons.trending_up,
        'color': summaryData.correctedAttendanceRate >= 80
            ? Color(0xFF10B981)
            : Color(0xFFEF4444),
        'gradient': summaryData.correctedAttendanceRate >= 80
            ? [Color(0xFF10B981), Color(0xFF059669)]
            : [Color(0xFFEF4444), Color(0xFFDC2626)],
        'trend': summaryData.attendanceGrade,
      },
      {
        'title': 'Work Hours',
        'value': summaryData.totalWorkHours.toString(),
        'subtitle': 'Total Hours',
        'icon': Icons.schedule,
        'color': Color(0xFF06B6D4),
        'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
        'trend': '${summaryData.formattedWorkHours}d',
      },
      {
        'title': 'Overtime',
        'value': summaryData.formattedOvertimeHours,
        'subtitle': 'Hours',
        'icon': Icons.access_alarm,
        'color': Color(0xFFEA580C),
        'gradient': [Color(0xFFEA580C), Color(0xFFDC2626)],
        'trend': summaryData.totalOvertimeHours > 0
            ? '+${summaryData.totalOvertimeHours}h'
            : null,
      },
    ];

    return SizedBox(
      height: 160.h,
      child: RefreshIndicator(
        onRefresh: controller.refreshSummary,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: cardData.length,
          separatorBuilder: (context, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final card = cardData[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: EnhancedSummaryCard(
                title: card['title'] as String,
                value: card['value'] as String,
                subtitle: card['subtitle'] as String,
                icon: card['icon'] as IconData,
                color: card['color'] as Color,
                gradient: card['gradient'] as List<Color>,
                trend: card['trend'] as String?,
                index: index,
                // ADDED: Show if this is corrected data
                isCalculated: card['title'] == 'Attendance',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStatsBar() {
    final summary = controller.summaryData!.summary;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1C5B41).withOpacity(0.05),
            Color(0xFF2E7D5F).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFF1C5B41).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStat(
            'Worked Days',
            '${summary.totalWorkedDays}',
            Icons.work_outline,
            Color(0xFF10B981),
          ),
          Container(width: 1.w, height: 30.h, color: Colors.grey[300]),
          _buildQuickStat(
            'Avg. Attendance',
            // FIXED: Use corrected rate
            '${summary.correctedAttendanceRate}%',
            Icons.trending_up,
            summary.correctedAttendanceRate >= 80
                ? Color(0xFF10B981)
                : Color(0xFFEF4444),
          ),
          Container(width: 1.w, height: 30.h, color: Colors.grey[300]),
          _buildQuickStat(
            'Performance',
            summary.attendanceGrade,
            Icons.star_outline,
            _getGradeColor(summary.attendanceGrade),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Color(0xFF10B981);
      case 'B+':
      case 'B':
        return Color(0xFF3B82F6);
      case 'C+':
      case 'C':
        return Color(0xFFF59E0B);
      default:
        return Color(0xFFEF4444);
    }
  }
}

class EnhancedSummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String? trend;
  final int index;
  final bool isCalculated; // NEW: Flag to show if this is calculated data

  const EnhancedSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    this.trend,
    required this.index,
    this.isCalculated = false,
  });

  @override
  State<EnhancedSummaryCard> createState() => _EnhancedSummaryCardState();
}

class _EnhancedSummaryCardState extends State<EnhancedSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 130.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, widget.color.withOpacity(0.03)],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: widget.color.withOpacity(0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: widget.gradient),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),

                      Column(
                        children: [
                          if (widget.trend != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                widget.trend!,
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                ),
                              ),
                            ),
                          // NEW: Show calculated indicator
                          if (widget.isCalculated)
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'CALC',
                                  style: TextStyle(
                                    fontSize: 6.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8.h),

                  // Value
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Subtitle
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12.h),

                  // Decorative bottom accent
                  Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      gradient: LinearGradient(colors: widget.gradient),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
