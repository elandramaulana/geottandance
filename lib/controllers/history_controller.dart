import 'package:get/get.dart';
import '../models/history_model.dart';
import 'package:flutter/material.dart';

class HistoryController extends GetxController {
  final histories = <HistoryModel>[].obs;
  RxString selectedCategory = 'All'.obs;
  Rx<DateTimeRange?> selectedRange = Rx<DateTimeRange?>(null);

  List<String> get categories => [
    'All',
    'On Time',
    'Late',
    'Absent',
    'Sick/Leave',
    'Holiday',
  ];

  @override
  void onInit() {
    super.onInit();
    _generateDummyHistories();
  }

  List<HistoryModel> get filteredHistories {
    List<HistoryModel> filtered = histories.where((h) {
      final matchCategory =
          selectedCategory.value == 'All' ||
          h.category == selectedCategory.value;

      bool matchDateRange = true;
      if (selectedRange.value != null) {
        final start = DateTime(
          selectedRange.value!.start.year,
          selectedRange.value!.start.month,
          selectedRange.value!.start.day,
        );
        final end = DateTime(
          selectedRange.value!.end.year,
          selectedRange.value!.end.month,
          selectedRange.value!.end.day,
        );
        final current = DateTime(h.date.year, h.date.month, h.date.day);
        matchDateRange =
            current.isAtSameMomentAs(start) ||
            current.isAtSameMomentAs(end) ||
            (current.isAfter(start) && current.isBefore(end));
      }

      return matchCategory && matchDateRange;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void clearDateRange() {
    selectedRange.value = null;
  }

  void _generateDummyHistories() {
    final now = DateTime.now();
    final dates = List.generate(10, (i) => now.subtract(Duration(days: i)));
    final categories = ['On Time', 'Late', 'Absent', 'Sick/Leave', 'Holiday'];

    final dummy = dates.map((date) {
      final i = dates.indexOf(date);
      final category = categories[i % categories.length];

      bool isLate = category == 'Late';
      bool isHoliday = category == 'Holiday';
      bool isAbsent = category == 'Absent';

      return HistoryModel(
        date: date,
        checkIn: isAbsent || isHoliday
            ? '-'
            : (isLate ? '09:1$i AM' : '08:0$i AM'),
        checkOut: isAbsent || isHoliday ? '-' : '05:0$i PM',
        category: category,
        locationIn: isAbsent || isHoliday
            ? '-'
            : (isLate
                  ? 'Stasiun Tanah Abang, Jakarta'
                  : 'Jl. Sudirman, Jakarta'),
        locationOut: isAbsent || isHoliday
            ? '-'
            : (isLate
                  ? 'Jl. K.H. Wahid Hasyim, Jakarta'
                  : 'Jl. MH Thamrin, Jakarta'),
        latitudeIn: isAbsent || isHoliday
            ? null
            : (isLate ? -6.186486 : -6.21462 + (i * 0.001)),
        longitudeIn: isAbsent || isHoliday
            ? null
            : (isLate ? 106.816666 : 106.84513 + (i * 0.001)),
        latitudeOut: isAbsent || isHoliday
            ? null
            : (isLate ? -6.189 : -6.22000 + (i * 0.001)),
        longitudeOut: isAbsent || isHoliday
            ? null
            : (isLate ? 106.826 : 106.85000 + (i * 0.001)),
      );
    }).toList();

    histories.assignAll(dummy);
  }
}
