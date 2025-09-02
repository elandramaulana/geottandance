// lib/widgets/home/home_header_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String currentDate;
  final String? userName;
  final String? officeName;

  const HomeHeaderWidget({
    super.key,
    required this.currentDate,
    this.userName,
    this.officeName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                userName ?? 'User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Text(
                currentDate,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (officeName != null && officeName!.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.business, color: Colors.white54, size: 12.sp),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        officeName!,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ],
    );
  }
}
