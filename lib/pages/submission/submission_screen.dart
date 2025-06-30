import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// perlu implementasi get x
class SubmissionScreen extends StatelessWidget {
  const SubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission'),
        backgroundColor: const Color(0xFF2E7D5F),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Add new submission button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF2E7D5F)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48.sp,
                    color: const Color(0xFF2E7D5F),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Create New Submission',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D5F),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Submissions list
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildSubmissionItem(
                    title: 'Leave Request #${index + 1}',
                    date: 'Dec ${20 + index}, 2024',
                    status: index % 2 == 0 ? 'Approved' : 'Pending',
                    type: index % 3 == 0 ? 'Sick Leave' : 'Annual Leave',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionItem({
    required String title,
    required String date,
    required String status,
    required String type,
  }) {
    Color statusColor = status == 'Approved' ? Colors.green : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            type,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF2E7D5F),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
