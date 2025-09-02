// controllers/summary_history_controller.dart
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geottandance/services/summary_history_service.dart';
import 'package:geottandance/models/summary_history_model.dart';

class SummaryHistoryController extends GetxController {
  final SummaryHistoryService _summaryService = SummaryHistoryService();

  // Observable variables
  final Rx<SummaryHistoryModel?> _summaryData = Rx<SummaryHistoryModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentMonth = DateTime.now().month.obs;

  // Getters
  SummaryHistoryModel? get summaryData => _summaryData.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  int get currentMonth => _currentMonth.value;

  // Enhanced summary data getters for UI
  String get workingDays => summaryData?.summary.totalDays.toString() ?? '0';

  String get presentDays => summaryData?.summary.presentDays ?? '0';

  String get absentDays => summaryData?.summary.absentDays ?? '0';

  String get lateDays => summaryData?.summary.lateDays ?? '0';

  String get leaveDays => summaryData?.summary.leaveDays ?? '0';

  String get holidayDays => summaryData?.summary.holidayDays ?? '0';

  int get attendanceRate => summaryData?.summary.attendanceRate ?? 0;

  String get totalWorkHours =>
      summaryData?.summary.totalWorkHours.toString() ?? '0';

  String get totalOvertimeHours =>
      summaryData?.summary.totalOvertimeHours.toString() ?? '0';

  String get period => summaryData?.period ?? 'Current Month';

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  @override
  void onReady() {
    super.onReady();
    // Auto refresh every 5 minutes when screen is active
    _setupAutoRefresh();
  }

  // Setup auto refresh
  void _setupAutoRefresh() {
    // Auto refresh every 5 minutes
    Stream.periodic(Duration(minutes: 5)).listen((_) {
      if (!_isLoading.value) {
        loadSummary(showLoading: false);
      }
    });
  }

  // Load summary data for current or specific month
  Future<void> loadSummary({bool showLoading = true, int? month}) async {
    try {
      final targetMonth = month ?? _currentMonth.value;

      if (showLoading) {
        _isLoading.value = true;
      }
      _hasError.value = false;
      _errorMessage.value = '';

      if (kDebugMode) {
        print('🔄 Loading attendance summary for month $targetMonth...');
      }

      final summary = await _summaryService.getAttendanceSummary(
        month: targetMonth,
      );

      if (summary != null) {
        _summaryData.value = summary;
        _currentMonth.value = targetMonth;

        if (kDebugMode) {
          print('✅ Summary loaded successfully for month $targetMonth');
          print('📊 Period: ${summary.period}');
          print('📊 Total Days: ${summary.summary.totalDays}');
          print('📊 Present Days: ${summary.summary.presentDays}');
          print('📊 Attendance Rate: ${summary.summary.attendanceRate}%');
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = 'Failed to load summary data';

        if (kDebugMode) {
          print('❌ Failed to load summary - No data received');
        }
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = _getErrorMessage(e);

      if (kDebugMode) {
        print('❌ Error loading summary: $e');
      }
    } finally {
      if (showLoading) {
        _isLoading.value = false;
      }
    }
  }

  // Load summary for specific month
  Future<void> loadSummaryForMonth(int month) async {
    await loadSummary(month: month);
  }

  // Switch to previous month
  Future<void> previousMonth() async {
    final prevMonth = _currentMonth.value == 1 ? 12 : _currentMonth.value - 1;
    await loadSummaryForMonth(prevMonth);
  }

  // Switch to next month
  Future<void> nextMonth() async {
    final nextMonth = _currentMonth.value == 12 ? 1 : _currentMonth.value + 1;
    await loadSummaryForMonth(nextMonth);
  }

  // Switch to current month
  Future<void> goToCurrentMonth() async {
    await loadSummaryForMonth(DateTime.now().month);
  }

  // Get month name
  String getMonthName(int month) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month];
  }

  // Get current month name
  String get currentMonthName => getMonthName(_currentMonth.value);

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data format';
    } else {
      return 'An error occurred while loading data';
    }
  }

  // Refresh data with pull-to-refresh
  Future<void> refreshSummary() async {
    await loadSummary();
  }

  // Force refresh (clear cache and reload)
  Future<void> forceRefresh() async {
    _summaryService.clearCache(month: _currentMonth.value);
    _summaryData.value = null;
    await loadSummary();
  }

  // Check if summary has data
  bool get hasSummaryData => summaryData != null;

  // Check if data is fresh (less than 5 minutes old)
  bool get isDataFresh {
    return _summaryService.hasCachedData(month: _currentMonth.value);
  }

  // Get attendance status based on rate
  String get attendanceStatus {
    if (attendanceRate >= 95) return 'Excellent';
    if (attendanceRate >= 85) return 'Good';
    if (attendanceRate >= 75) return 'Average';
    return 'Needs Improvement';
  }

  // Get attendance status color
  Color get attendanceStatusColor {
    if (attendanceRate >= 95) return Color(0xFF10B981); // Green
    if (attendanceRate >= 85) return Color(0xFF3B82F6); // Blue
    if (attendanceRate >= 75) return Color(0xFFF59E0B); // Orange
    return Color(0xFFEF4444); // Red
  }

  // Get available cached months
  List<int> get availableCachedMonths {
    return _summaryService.getAvailableCachedMonths();
  }

  // Preload data for current year months
  Future<void> preloadCurrentYearData() async {
    final currentYear = DateTime.now().year;
    final months = List.generate(12, (index) => index + 1);

    try {
      await _summaryService.preloadSummaryData(months);
      if (kDebugMode) {
        print('✅ Preloaded summary data for $currentYear');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to preload some data: $e');
      }
    }
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }

  // Retry loading data
  void retry() {
    loadSummary();
  }

  // Clear error state
  void clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  // Clear all cache
  void clearAllCache() {
    _summaryService.clearCache();
    if (kDebugMode) {
      print('🗑️ All summary cache cleared');
    }
  }
}
