import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/history_controller.dart';
import '../../models/history_model.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Attendance History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFF2E7D5F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter kategori
            _buildDropdownCategory(),
            SizedBox(height: 12.h),

            // Filter rentang tanggal
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D5F),
                    ),
                    onPressed: () async {
                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                        initialDateRange: controller.selectedRange.value,
                      );
                      if (picked != null) {
                        controller.selectedRange.value = picked;
                      }
                    },
                    child: const Text(
                      "Select Date Range",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(
                  () => controller.selectedRange.value != null
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          onPressed: controller.clearDateRange,
                          child: const Text(
                            "Clear Filter",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // List history
            Obx(
              () => Expanded(
                child: controller.filteredHistories.isEmpty
                    ? const Center(child: Text('No history available'))
                    : ListView.builder(
                        itemCount: controller.filteredHistories.length,
                        itemBuilder: (context, index) {
                          final history = controller.filteredHistories[index];
                          return _buildHistoryCard(history);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCategory() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedCategory.value,
        items: controller.categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (val) => controller.selectedCategory.value = val!,
        decoration: const InputDecoration(labelText: 'Category'),
      ),
    );
  }

  Widget _buildHistoryCard(HistoryModel model) {
    return GestureDetector(
      onTap: () => Get.toNamed('/history-detail', arguments: model),
      child: Container(
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
            // Tanggal dan kategori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(model.date),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(model.category),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    model.category,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            Row(
              children: [
                const Icon(Icons.login, color: Colors.green),
                SizedBox(width: 6.w),
                Text('Check In: ${model.checkIn}'),
              ],
            ),
            SizedBox(height: 4.h),

            Row(
              children: [
                const Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 6.w),
                Text('Check Out: ${model.checkOut}'),
              ],
            ),

            if (model.locationIn != '-' || model.locationOut != '-')
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        model.locationIn != '-'
                            ? model.locationIn
                            : model.locationOut,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'On Time':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      case 'Holiday':
        return Colors.redAccent;
      case 'Sick/Leave':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
