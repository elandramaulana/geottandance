// lib/screens/history/widgets/history_attendance_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geottandance/models/history_model.dart';
import 'package:geottandance/utils/history/history_date_formatter.dart';

class HistoryAttendanceCard extends StatelessWidget {
  final AttendanceHistory attendance;
  final VoidCallback onTap;

  const HistoryAttendanceCard({
    super.key,
    required this.attendance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildTimeInfo(),
              SizedBox(height: 12.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildDateBox(),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatter.formatDisplayDate(attendance.date),
                style: TextStyle(
                  fontSize: 15.sp,
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
        SizedBox(width: 8.w),
        _StatusBadge(status: attendance.status, label: attendance.statusLabel),
      ],
    );
  }

  Widget _buildDateBox() {
    return Container(
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
            DateFormatter.getDateNumber(attendance.date),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D5C),
            ),
          ),
          Text(
            DateFormatter.getMonthText(attendance.date),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E7D5C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      children: [
        Expanded(
          child: _TimeCard(
            label: 'IN',
            value: attendance.clockIn ?? '--:--',
            color: const Color(0xFF4CAF50),
            icon: Icons.login_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _TimeCard(
            label: 'DURATION',
            value: attendance.formattedWorkDuration,
            color: const Color(0xFF2196F3),
            icon: Icons.access_time_filled_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _TimeCard(
            label: 'OUT',
            value: attendance.clockOut ?? '--:--',
            color: const Color(0xFFF44336),
            icon: Icons.logout_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (attendance.office.name.isNotEmpty)
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      constraints: BoxConstraints(maxWidth: 100.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14.sp, color: config.textColor),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: config.textColor,
                fontSize: 11.sp,
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

  _StatusConfig _getStatusConfig() {
    switch (status.toLowerCase()) {
      case 'present':
        return _StatusConfig(
          backgroundColor: const Color(0xFF4CAF50),
          textColor: Colors.white,
          icon: Icons.check_circle_rounded,
        );
      case 'late':
        return _StatusConfig(
          backgroundColor: const Color(0xFFFF9800),
          textColor: Colors.white,
          icon: Icons.access_time_rounded,
        );
      case 'absent':
        return _StatusConfig(
          backgroundColor: const Color(0xFFF44336),
          textColor: Colors.white,
          icon: Icons.cancel_rounded,
        );
      case 'sick':
        return _StatusConfig(
          backgroundColor: const Color(0xFF9C27B0),
          textColor: Colors.white,
          icon: Icons.medical_services_rounded,
        );
      case 'holiday':
        return _StatusConfig(
          backgroundColor: const Color(0xFFE91E63),
          textColor: Colors.white,
          icon: Icons.celebration_rounded,
        );
      default:
        return _StatusConfig(
          backgroundColor: const Color(0xFF666666),
          textColor: Colors.white,
          icon: Icons.help_outline_rounded,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

class _TimeCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _TimeCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
}
