// lib/controllers/history_controller.dart
import 'package:geottandance/core/database_helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../models/attendance_model.dart';

class HistoryController extends GetxController {
  // final histories = <HistoryModel>[].obs;
  // RxString selectedCategory = 'All'.obs;
  // Rx<DateTimeRange?> selectedRange = Rx(null);
  // final _isLoading = false.obs;
  // final _errorMessage = ''.obs;

  // // Getters
  // bool get isLoading => _isLoading.value;
  // String get errorMessage => _errorMessage.value;

  // List<String> get categories => [
  //   'All',
  //   'On Time',
  //   'Late',
  //   'Absent',
  //   'Sick/Leave',
  //   'Holiday',
  // ];

  // @override
  // void onInit() {
  //   super.onInit();
  //   loadHistoryFromDatabase();
  // }

  // List<HistoryModel> get filteredHistories {
  //   List<HistoryModel> filtered = histories.where((h) {
  //     final matchCategory =
  //         selectedCategory.value == 'All' ||
  //         h.category == selectedCategory.value;

  //     bool matchDateRange = true;
  //     if (selectedRange.value != null) {
  //       final start = DateTime(
  //         selectedRange.value!.start.year,
  //         selectedRange.value!.start.month,
  //         selectedRange.value!.start.day,
  //       );
  //       final end = DateTime(
  //         selectedRange.value!.end.year,
  //         selectedRange.value!.end.month,
  //         selectedRange.value!.end.day,
  //       );
  //       final current = DateTime(h.date.year, h.date.month, h.date.day);
  //       matchDateRange =
  //           current.isAtSameMomentAs(start) ||
  //           current.isAtSameMomentAs(end) ||
  //           (current.isAfter(start) && current.isBefore(end));
  //     }

  //     return matchCategory && matchDateRange;
  //   }).toList();

  //   filtered.sort((a, b) => b.date.compareTo(a.date));
  //   return filtered;
  // }

  // void clearDateRange() {
  //   selectedRange.value = null;
  // }

  // /// Load history from database and convert to HistoryModel
  // Future<void> loadHistoryFromDatabase() async {
  //   _setLoading(true);
  //   try {
  //     final attendanceRecords = await _databaseHelper.getAllAttendance();
  //     final historyList = await _convertAttendanceToHistory(attendanceRecords);
  //     histories.assignAll(historyList);
  //     _clearError();
  //   } catch (e) {
  //     _setError('Failed to load history: $e');
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // /// Convert attendance records to history models grouped by date
  // Future<List<HistoryModel>> _convertAttendanceToHistory(
  //   List<AttendanceRecord> records,
  // ) async {
  //   final Map<String, List<AttendanceRecord>> groupedByDate = {};

  //   // Group records by date
  //   for (final record in records) {
  //     final dateKey = _getDateKey(record.timestamp);
  //     if (!groupedByDate.containsKey(dateKey)) {
  //       groupedByDate[dateKey] = [];
  //     }
  //     groupedByDate[dateKey]!.add(record);
  //   }

  //   final List<HistoryModel> historyList = [];

  //   // Convert each date group to HistoryModel
  //   for (final entry in groupedByDate.entries) {
  //     final dateKey = entry.key;
  //     final dayRecords = entry.value;

  //     // Sort records by timestamp
  //     dayRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  //     final date = DateTime.parse(dateKey);
  //     final historyModel = await _createHistoryModel(date, dayRecords);
  //     historyList.add(historyModel);
  //   }

  //   return historyList;
  // }

  // /// Create HistoryModel from date and attendance records
  // Future<HistoryModel> _createHistoryModel(
  //   DateTime date,
  //   List<AttendanceRecord> dayRecords,
  // ) async {
  //   AttendanceRecord? clockInRecord;
  //   AttendanceRecord? clockOutRecord;

  //   // Find clock in and clock out records
  //   for (final record in dayRecords) {
  //     if (record.type == 'clock_in' && clockInRecord == null) {
  //       clockInRecord = record;
  //     } else if (record.type == 'clock_out') {
  //       clockOutRecord = record; // Get the last clock out
  //     }
  //   }

  //   // Determine category and format times
  //   String category;
  //   String checkIn;
  //   String checkOut;
  //   String locationIn;
  //   String locationOut;
  //   double? latitudeIn;
  //   double? longitudeIn;
  //   double? latitudeOut;
  //   double? longitudeOut;

  //   if (clockInRecord == null) {
  //     // No attendance record for this date
  //     category = 'Absent';
  //     checkIn = '-';
  //     checkOut = '-';
  //     locationIn = '-';
  //     locationOut = '-';
  //     latitudeIn = null;
  //     longitudeIn = null;
  //     latitudeOut = null;
  //     longitudeOut = null;
  //   } else {
  //     // Has clock in record
  //     checkIn = _formatTime(clockInRecord.timestamp);
  //     locationIn = clockInRecord.address ?? 'Unknown Location';
  //     latitudeIn = clockInRecord.latitude;
  //     longitudeIn = clockInRecord.longitude;

  //     if (clockOutRecord == null) {
  //       // Clock in but no clock out
  //       category = 'Incomplete';
  //       checkOut = '-';
  //       locationOut = '-';
  //       latitudeOut = null;
  //       longitudeOut = null;
  //     } else {
  //       // Has both clock in and clock out
  //       category = 'Complete';
  //       checkOut = _formatTime(clockOutRecord.timestamp);
  //       locationOut = clockOutRecord.address ?? 'Unknown Location';
  //       latitudeOut = clockOutRecord.latitude;
  //       longitudeOut = clockOutRecord.longitude;

  //       // Check if late (assuming work starts at 09:00)
  //       if (clockInRecord.timestamp.hour > 9 ||
  //           (clockInRecord.timestamp.hour == 9 &&
  //               clockInRecord.timestamp.minute > 0)) {
  //         category = 'Late';
  //       } else {
  //         category = 'On Time';
  //       }
  //     }
  //   }

  //   return HistoryModel(
  //     date: date,
  //     checkIn: checkIn,
  //     checkOut: checkOut,
  //     category: category,
  //     locationIn: locationIn,
  //     locationOut: locationOut,
  //     latitudeIn: latitudeIn,
  //     longitudeIn: longitudeIn,
  //     latitudeOut: latitudeOut,
  //     longitudeOut: longitudeOut,
  //   );
  // }

  // /// Get date key for grouping (YYYY-MM-DD format)
  // String _getDateKey(DateTime dateTime) {
  //   return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  // }

  // /// Format time to readable string (HH:MM AM/PM)
  // String _formatTime(DateTime dateTime) {
  //   final hour = dateTime.hour;
  //   final minute = dateTime.minute;
  //   final period = hour >= 12 ? 'PM' : 'AM';
  //   final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

  //   return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  // }

  // /// Refresh history data
  // Future<void> refreshHistory() async {
  //   await loadHistoryFromDatabase();
  // }

  // /// Get history for specific date range
  // Future<List<HistoryModel>> getHistoryByDateRange(
  //   DateTime startDate,
  //   DateTime endDate,
  // ) async {
  //   try {
  //     final allRecords = await _databaseHelper.getAllAttendance();
  //     final filteredRecords = allRecords.where((record) {
  //       final recordDate = DateTime(
  //         record.timestamp.year,
  //         record.timestamp.month,
  //         record.timestamp.day,
  //       );
  //       final start = DateTime(startDate.year, startDate.month, startDate.day);
  //       final end = DateTime(endDate.year, endDate.month, endDate.day);

  //       return (recordDate.isAtSameMomentAs(start) ||
  //           recordDate.isAtSameMomentAs(end) ||
  //           (recordDate.isAfter(start) && recordDate.isBefore(end)));
  //     }).toList();

  //     return await _convertAttendanceToHistory(filteredRecords);
  //   } catch (e) {
  //     _setError('Failed to get history by date range: $e');
  //     return [];
  //   }
  // }

  // /// Get work statistics
  // Map<String, dynamic> getWorkStatistics() {
  //   final currentMonth = DateTime.now().month;
  //   final currentYear = DateTime.now().year;

  //   final monthlyRecords = histories.where(
  //     (history) =>
  //         history.date.month == currentMonth &&
  //         history.date.year == currentYear,
  //   );

  //   int totalDays = monthlyRecords.length;
  //   int onTimeDays = monthlyRecords
  //       .where((h) => h.category == 'On Time')
  //       .length;
  //   int lateDays = monthlyRecords.where((h) => h.category == 'Late').length;
  //   int absentDays = monthlyRecords.where((h) => h.category == 'Absent').length;
  //   int incompleteDays = monthlyRecords
  //       .where((h) => h.category == 'Incomplete')
  //       .length;

  //   return {
  //     'totalDays': totalDays,
  //     'onTimeDays': onTimeDays,
  //     'lateDays': lateDays,
  //     'absentDays': absentDays,
  //     'incompleteDays': incompleteDays,
  //     'attendanceRate': totalDays > 0
  //         ? ((totalDays - absentDays) / totalDays * 100)
  //         : 0.0,
  //   };
  // }

  // /// Set loading state
  // void _setLoading(bool loading) {
  //   _isLoading.value = loading;
  // }

  // /// Set error message
  // void _setError(String error) {
  //   _errorMessage.value = error;
  //   if (error.isNotEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       error,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: const Color(0xFFEF4444),
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 4),
  //       icon: const Icon(Icons.error_outline, color: Colors.white),
  //       margin: const EdgeInsets.all(16),
  //       borderRadius: 12,
  //     );
  //   }
  // }

  // /// Clear error message
  // void _clearError() {
  //   _errorMessage.value = '';
  // }

  // /// Public method to clear error (for UI)
  // void clearError() {
  //   _clearError();
  // }
}
