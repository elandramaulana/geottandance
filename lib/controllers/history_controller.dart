// controllers/attendance_history_controller.dart
import 'package:flutter/foundation.dart';
import 'package:geottandance/models/history_statistic_model.dart';
import 'package:get/get.dart';
import 'package:geottandance/services/history_service.dart';
import 'package:geottandance/models/history_model.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceHistoryService _historyService = AttendanceHistoryService();

  // Reactive State management
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Reactive Data
  final attendances = <AttendanceHistory>[].obs;
  final pagination = Rxn<PaginationInfo>();
  final statistics = Rxn<AttendanceStatistics>();

  // Reactive Filter parameters
  final selectedStatus = Rxn<String>();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final selectedMonth = Rxn<int>();
  final selectedYear = Rxn<int>();

  // Computed properties
  bool get hasData => attendances.isNotEmpty;
  bool get canLoadMore =>
      pagination.value != null && pagination.value!.hasNextPage;
  bool get shouldShowEmptyState =>
      !hasData && !hasError.value && !isLoading.value;
  bool get isValidationError =>
      errorMessage.value.toLowerCase().contains('validation');
  bool get isServerError {
    if (!hasError.value || errorMessage.value.isEmpty) return false;
    if (isValidationError) return false;

    final message = errorMessage.value.toLowerCase();
    return message.contains('failed') ||
        message.contains('error') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('server');
  }

  bool get shouldShowErrorState => hasError.value && isServerError;

  @override
  void onInit() {
    super.onInit();
    // Initialize with all data (no filters applied)
    Future.delayed(Duration.zero, loadAllHistory);
  }

  // Load all attendance history without filters
  Future<void> loadAllHistory() async {
    try {
      isLoading.value = true;
      attendances.clear();
      _clearError();

      final response = await _historyService.getAttendanceHistory(
        page: 1,
        perPage: 100,
      );

      if (response.success && response.data != null) {
        pagination.value = response.data!.pagination;
        attendances.value = response.data!.attendances
          ..sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
          );

        if (kDebugMode) {
          print(
            '✅ Loaded ${response.data!.attendances.length} attendance records',
          );
        }
      } else {
        if (response.message.toLowerCase().contains('no data') ||
            response.message.toLowerCase().contains('tidak ada data') ||
            response.message.toLowerCase().contains('empty')) {
          attendances.clear();
          if (kDebugMode) {
            print('ℹ️ No attendance data available');
          }
        } else {
          _setError(response.message);
        }
      }
    } catch (e) {
      _setError('Failed to load attendance history: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load attendance history with current filters
  Future<void> loadAttendanceHistory({
    int page = 1,
    bool isLoadMore = false,
  }) async {
    try {
      if (isLoadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      if (!isLoadMore && page == 1) {
        attendances.clear();
      }

      _clearError();

      if (kDebugMode) {
        print('🔍 Loading attendance with filters:');
        print('   Status: ${selectedStatus.value}');
        print(
          '   Start Date: ${startDate.value != null ? _formatDate(startDate.value!) : null}',
        );
        print(
          '   End Date: ${endDate.value != null ? _formatDate(endDate.value!) : null}',
        );
        print('   Month: ${selectedMonth.value?.toString().padLeft(2, '0')}');
        print('   Year: ${selectedYear.value?.toString()}');
      }

      final response = await _historyService.getAttendanceHistory(
        page: page,
        status: selectedStatus.value,
        startDate: startDate.value != null
            ? _formatDate(startDate.value!)
            : null,
        endDate: endDate.value != null ? _formatDate(endDate.value!) : null,
        month: selectedMonth.value?.toString().padLeft(2, '0'),
        year: selectedYear.value?.toString(),
      );

      if (response.success && response.data != null) {
        pagination.value = response.data!.pagination;

        List<AttendanceHistory> newAttendances = response.data!.attendances
          ..sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
          );

        if (isLoadMore) {
          attendances.addAll(newAttendances);
        } else {
          attendances.value = newAttendances;
        }

        if (kDebugMode) {
          print(
            '✅ Loaded ${newAttendances.length} attendance records (Total: ${attendances.length})',
          );
          if (attendances.isNotEmpty) {
            print('   First record date: ${attendances.first.date}');
            print('   Last record date: ${attendances.last.date}');
          }
        }
      } else {
        if (response.message.toLowerCase().contains('no data') ||
            response.message.toLowerCase().contains('tidak ada data') ||
            response.message.toLowerCase().contains('empty') ||
            response.message.toLowerCase().contains('validation')) {
          if (!isLoadMore) {
            attendances.clear();
          }
          if (kDebugMode) {
            print('ℹ️ No attendance data matching current filters');
          }
        } else {
          _setError(response.message);
        }
      }
    } catch (e) {
      _setError('Failed to load attendance history: ${e.toString()}');
    } finally {
      if (isLoadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Load more data (pagination)
  Future<void> loadMoreData() async {
    if (!canLoadMore || isLoadingMore.value) return;

    final nextPage = (pagination.value?.currentPage ?? 0) + 1;
    await loadAttendanceHistory(page: nextPage, isLoadMore: true);
  }

  // Load current month history
  Future<void> loadCurrentMonthHistory() async {
    final now = DateTime.now();
    setMonthFilter(now.year, now.month);
    await loadAttendanceHistory();
  }

  // Load monthly history
  Future<void> loadMonthlyHistory(int year, int month) async {
    setMonthFilter(year, month);
    await loadAttendanceHistory();
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      statistics.value = await _historyService.getAttendanceStatistics(
        month: selectedMonth.value?.toString().padLeft(2, '0'),
        year: selectedYear.value?.toString(),
      );

      if (kDebugMode) {
        print('✅ Statistics loaded: ${statistics.value.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading statistics: $e');
      }
    }
  }

  // Set filters
  void setStatusFilter(String? status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      _clearError();
      if (kDebugMode) {
        print('📊 Status filter set to: $status');
      }
    }
  }

  void setDateRangeFilter(DateTime? start, DateTime? end) {
    if (startDate.value != start || endDate.value != end) {
      startDate.value = start;
      endDate.value = end;
      // Clear month/year filter when using date range
      selectedMonth.value = null;
      selectedYear.value = null;
      _clearError();

      if (kDebugMode) {
        print(
          '📅 Date range filter set to: ${start != null ? _formatDate(start) : null} - ${end != null ? _formatDate(end) : null}',
        );
      }
    }
  }

  void setMonthFilter(int year, int month) {
    if (selectedYear.value != year || selectedMonth.value != month) {
      selectedYear.value = year;
      selectedMonth.value = month;
      // Clear date range filter when using month filter
      startDate.value = null;
      endDate.value = null;
      _clearError();

      if (kDebugMode) {
        print(
          '🗓️ Month filter set to: $year-${month.toString().padLeft(2, '0')}',
        );
      }
    }
  }

  // Clear all filters and reload all data
  void clearFilters() {
    bool hasChanges = false;

    if (selectedStatus.value != null) {
      selectedStatus.value = null;
      hasChanges = true;
    }
    if (startDate.value != null) {
      startDate.value = null;
      hasChanges = true;
    }
    if (endDate.value != null) {
      endDate.value = null;
      hasChanges = true;
    }
    if (selectedMonth.value != null) {
      selectedMonth.value = null;
      hasChanges = true;
    }
    if (selectedYear.value != null) {
      selectedYear.value = null;
      hasChanges = true;
    }

    if (hasChanges) {
      _clearError();
      if (kDebugMode) {
        print('🧹 All filters cleared');
      }
    }
  }

  // Apply filters and reload data
  Future<void> applyFilters() async {
    if (kDebugMode) {
      print('🔄 Applying filters...');
    }

    _clearError();

    // If no filters are applied, load all history
    if (selectedStatus.value == null &&
        startDate.value == null &&
        endDate.value == null &&
        selectedMonth.value == null &&
        selectedYear.value == null) {
      await loadAllHistory();
    } else {
      await loadAttendanceHistory();
    }

    // Only load statistics if we have month/year filter or all data
    if (selectedMonth.value != null && selectedYear.value != null) {
      await loadStatistics();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    if (kDebugMode) {
      print('🔄 Refreshing data...');
    }

    _clearError();

    // Check if any filters are active
    bool hasActiveFilters =
        selectedStatus.value != null ||
        startDate.value != null ||
        endDate.value != null ||
        (selectedMonth.value != null && selectedYear.value != null);

    if (hasActiveFilters) {
      await loadAttendanceHistory();
      if (selectedMonth.value != null && selectedYear.value != null) {
        await loadStatistics();
      }
    } else {
      await loadAllHistory();
    }
  }

  // Search in current data
  List<AttendanceHistory> searchAttendances(String query) {
    if (query.isEmpty) return attendances;

    final lowercaseQuery = query.toLowerCase();
    return attendances.where((attendance) {
      return attendance.date.contains(query) ||
          attendance.dayName.toLowerCase().contains(lowercaseQuery) ||
          attendance.statusLabel.toLowerCase().contains(lowercaseQuery) ||
          attendance.office.name.toLowerCase().contains(lowercaseQuery) ||
          (attendance.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get attendance by date
  AttendanceHistory? getAttendanceByDate(String date) {
    try {
      return attendances.firstWhere((attendance) => attendance.date == date);
    } catch (e) {
      return null;
    }
  }

  // Get attendances by status
  List<AttendanceHistory> getAttendancesByStatus(String status) {
    return attendances
        .where((attendance) => attendance.status == status)
        .toList();
  }

  // Get recent attendances (last 7 days)
  List<AttendanceHistory> getRecentAttendances() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return attendances.where((attendance) {
      final attendanceDate = DateTime.parse(attendance.date);
      return attendanceDate.isAfter(weekAgo) &&
          attendanceDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  // Get attendances for current month
  List<AttendanceHistory> getCurrentMonthAttendances() {
    final now = DateTime.now();
    return attendances.where((attendance) {
      final attendanceDate = DateTime.parse(attendance.date);
      return attendanceDate.year == now.year &&
          attendanceDate.month == now.month;
    }).toList();
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _setError(String message) {
    errorMessage.value = message;
    hasError.value = true;

    if (kDebugMode) {
      print('❌ AttendanceHistoryController Error: $message');
    }
  }

  void _clearError() {
    if (errorMessage.value.isNotEmpty || hasError.value) {
      errorMessage.value = '';
      hasError.value = false;
      if (kDebugMode) {
        print('🧹 Error cleared');
      }
    }
  }

  // Reset controller
  void reset() {
    attendances.clear();
    pagination.value = null;
    statistics.value = null;
    selectedStatus.value = null;
    startDate.value = null;
    endDate.value = null;
    selectedMonth.value = null;
    selectedYear.value = null;
    isLoading.value = false;
    isLoadingMore.value = false;
    hasError.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
