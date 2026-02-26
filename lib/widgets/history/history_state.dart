// lib/screens/history/widgets/history_state_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
              errorMessage,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
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
}

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
}
