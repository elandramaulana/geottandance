import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// perlu implementasi get x
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xFF2E7D5F),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Filter buttons
            Row(
              children: [
                Expanded(child: _buildFilterButton('Today', true)),
                SizedBox(width: 10.w),
                Expanded(child: _buildFilterButton('Week', false)),
                SizedBox(width: 10.w),
                Expanded(child: _buildFilterButton('Month', false)),
              ],
            ),
            SizedBox(height: 20.h),
            // History list
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(
                    date: 'Dec ${25 - index}, 2024',
                    checkIn: '08:30 AM',
                    checkOut: '05:30 PM',
                    status: index % 3 == 0 ? 'Late' : 'On Time',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2E7D5F) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String checkIn,
    required String checkOut,
    required String status,
  }) {
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
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: const Color(0xFF2E7D5F),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$checkIn - $checkOut',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: status == 'On Time' ? Colors.green : Colors.red,
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
    );
  }
}
