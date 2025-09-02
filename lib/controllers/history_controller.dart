// controllers/attendance_history_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:geottandance/services/history_service.dart';
import 'package:geottandance/models/history_model.dart';

enum HistoryLoadingState { idle, loading, loaded, error, loadingMore }

class AttendanceHistoryController extends GetxController {
  final AttendanceHistoryService _historyService = AttendanceHistoryService();

  // State management
  HistoryLoadingState _state = HistoryLoadingState.idle;
  String _errorMessage = '';

  // Data
  List<AttendanceHistory> _attendances = [];
  PaginationInfo? _pagination;
  AttendanceStatistics? _statistics;

  // Filter parameters
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedMonth;
  int? _selectedYear;

  // Getters
  HistoryLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  List<AttendanceHistory> get attendances => _attendances;
  PaginationInfo? get pagination => _pagination;
  AttendanceStatistics? get statistics => _statistics;
  String? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int? get selectedMonth => _selectedMonth;
  int? get selectedYear => _selectedYear;

  // Computed properties
  bool get isLoading => _state == HistoryLoadingState.loading;
  bool get isLoadingMore => _state == HistoryLoadingState.loadingMore;
  bool get hasError => _state == HistoryLoadingState.error;
  bool get hasData => _attendances.isNotEmpty;
  bool get canLoadMore => _pagination != null && _pagination!.hasNextPage;

  @override
  void onInit() {
    super.onInit();
    // Initialize with all data (no filters applied) - delayed to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAllHistory();
    });
  }

  // Load all attendance history without filters
  Future<void> loadAllHistory() async {
    try {
      _setState(HistoryLoadingState.loading);
      _attendances.clear();
      _clearError(); // Clear any previous errors

      final response = await _historyService.getAttendanceHistory(
        page: 1,
        perPage: 100, // Load more records initially
      );

      if (response.success && response.data != null) {
        _pagination = response.data!.pagination;
        _attendances = response.data!.attendances;

        // Sort by date descending (latest first)
        _attendances.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
        );

        _setState(HistoryLoadingState.loaded);

        if (kDebugMode) {
          print(
            '✅ Loaded ${response.data!.attendances.length} attendance records',
          );
        }
      } else {
        // Check if this is a "no data" response vs actual error
        if (response.message.toLowerCase().contains('no data') ||
            response.message.toLowerCase().contains('tidak ada data') ||
            response.message.toLowerCase().contains('empty')) {
          // This is not an error, just no data available
          _attendances.clear();
          _setState(HistoryLoadingState.loaded);
          if (kDebugMode) {
            print('ℹ️ No attendance data available');
          }
        } else {
          _setError(response.message);
        }
      }
    } catch (e) {
      _setError('Failed to load attendance history: ${e.toString()}');
    }
  }

  // Load attendance history with current filters
  Future<void> loadAttendanceHistory({
    int page = 1,
    bool isLoadMore = false,
  }) async {
    try {
      if (isLoadMore) {
        _setState(HistoryLoadingState.loadingMore);
      } else {
        _setState(HistoryLoadingState.loading);
        if (page == 1) {
          _attendances.clear(); // Clear existing data for fresh load
        }
      }

      _clearError(); // Clear any previous errors

      if (kDebugMode) {
        print('🔍 Loading attendance with filters:');
        print('   Status: $_selectedStatus');
        print(
          '   Start Date: ${_startDate != null ? _formatDate(_startDate!) : null}',
        );
        print(
          '   End Date: ${_endDate != null ? _formatDate(_endDate!) : null}',
        );
        print('   Month: ${_selectedMonth?.toString().padLeft(2, '0')}');
        print('   Year: ${_selectedYear?.toString()}');
      }

      final response = await _historyService.getAttendanceHistory(
        page: page,
        status: _selectedStatus,
        startDate: _startDate != null ? _formatDate(_startDate!) : null,
        endDate: _endDate != null ? _formatDate(_endDate!) : null,
        month: _selectedMonth?.toString().padLeft(2, '0'),
        year: _selectedYear?.toString(),
      );

      if (response.success && response.data != null) {
        _pagination = response.data!.pagination;

        List<AttendanceHistory> newAttendances = response.data!.attendances;

        // Sort by date descending (latest first)
        newAttendances.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
        );

        if (isLoadMore) {
          _attendances.addAll(newAttendances);
        } else {
          _attendances = newAttendances;
        }

        _setState(HistoryLoadingState.loaded);

        if (kDebugMode) {
          print(
            '✅ Loaded ${newAttendances.length} attendance records (Total: ${_attendances.length})',
          );
          if (_attendances.isNotEmpty) {
            print('   First record date: ${_attendances.first.date}');
            print('   Last record date: ${_attendances.last.date}');
          }
        }
      } else {
        // Handle different types of "no data" responses
        if (response.message.toLowerCase().contains('no data') ||
            response.message.toLowerCase().contains('tidak ada data') ||
            response.message.toLowerCase().contains('empty') ||
            response.message.toLowerCase().contains('validation')) {
          // This is not an error, just no data matching the filter
          if (!isLoadMore) {
            _attendances.clear();
          }
          _setState(HistoryLoadingState.loaded);
          if (kDebugMode) {
            print('ℹ️ No attendance data matching current filters');
          }
        } else {
          // This is an actual error
          _setError(response.message);
        }
      }
    } catch (e) {
      _setError('Failed to load attendance history: ${e.toString()}');
    }
  }

  // Load more data (pagination)
  Future<void> loadMoreData() async {
    if (!canLoadMore || isLoadingMore) return;

    final nextPage = (_pagination?.currentPage ?? 0) + 1;
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
      _statistics = await _historyService.getAttendanceStatistics(
        month: _selectedMonth?.toString().padLeft(2, '0'),
        year: _selectedYear?.toString(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });

      if (kDebugMode) {
        print('✅ Statistics loaded: ${_statistics.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading statistics: $e');
      }
    }
  }

  // Set filters
  void setStatusFilter(String? status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      _clearError(); // Clear error when filter changes
      if (kDebugMode) {
        print('📊 Status filter set to: $status');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    if (_startDate != startDate || _endDate != endDate) {
      _startDate = startDate;
      _endDate = endDate;
      // Clear month/year filter when using date range
      _selectedMonth = null;
      _selectedYear = null;
      _clearError(); // Clear error when filter changes

      if (kDebugMode) {
        print(
          '📅 Date range filter set to: ${startDate != null ? _formatDate(startDate) : null} - ${endDate != null ? _formatDate(endDate) : null}',
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  void setMonthFilter(int year, int month) {
    if (_selectedYear != year || _selectedMonth != month) {
      _selectedYear = year;
      _selectedMonth = month;
      // Clear date range filter when using month filter
      _startDate = null;
      _endDate = null;
      _clearError(); // Clear error when filter changes

      if (kDebugMode) {
        print(
          '🗓️ Month filter set to: $year-${month.toString().padLeft(2, '0')}',
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  // Clear all filters and reload all data
  void clearFilters() {
    bool hasChanges = false;

    if (_selectedStatus != null) {
      _selectedStatus = null;
      hasChanges = true;
    }
    if (_startDate != null) {
      _startDate = null;
      hasChanges = true;
    }
    if (_endDate != null) {
      _endDate = null;
      hasChanges = true;
    }
    if (_selectedMonth != null) {
      _selectedMonth = null;
      hasChanges = true;
    }
    if (_selectedYear != null) {
      _selectedYear = null;
      hasChanges = true;
    }

    if (hasChanges) {
      _clearError(); // Clear error when filters are cleared
      if (kDebugMode) {
        print('🧹 All filters cleared');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  // Apply filters and reload data
  Future<void> applyFilters() async {
    if (kDebugMode) {
      print('🔄 Applying filters...');
    }

    _clearError(); // Clear any previous errors before applying filters

    // If no filters are applied, load all history
    if (_selectedStatus == null &&
        _startDate == null &&
        _endDate == null &&
        _selectedMonth == null &&
        _selectedYear == null) {
      await loadAllHistory();
    } else {
      await loadAttendanceHistory();
    }

    // Only load statistics if we have month/year filter or all data
    if (_selectedMonth != null && _selectedYear != null) {
      await loadStatistics();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    if (kDebugMode) {
      print('🔄 Refreshing data...');
    }

    _clearError(); // Clear any previous errors

    // Check if any filters are active
    bool hasActiveFilters =
        _selectedStatus != null ||
        _startDate != null ||
        _endDate != null ||
        (_selectedMonth != null && _selectedYear != null);

    if (hasActiveFilters) {
      await loadAttendanceHistory();
      if (_selectedMonth != null && _selectedYear != null) {
        await loadStatistics();
      }
    } else {
      await loadAllHistory();
    }
  }

  // Search in current data
  List<AttendanceHistory> searchAttendances(String query) {
    if (query.isEmpty) return _attendances;

    final lowercaseQuery = query.toLowerCase();
    return _attendances.where((attendance) {
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
      return _attendances.firstWhere((attendance) => attendance.date == date);
    } catch (e) {
      return null;
    }
  }

  // Get attendances by status
  List<AttendanceHistory> getAttendancesByStatus(String status) {
    return _attendances
        .where((attendance) => attendance.status == status)
        .toList();
  }

  // Get recent attendances (last 7 days)
  List<AttendanceHistory> getRecentAttendances() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _attendances.where((attendance) {
      final attendanceDate = DateTime.parse(attendance.date);
      return attendanceDate.isAfter(weekAgo) &&
          attendanceDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  // Get attendances for current month
  List<AttendanceHistory> getCurrentMonthAttendances() {
    final now = DateTime.now();
    return _attendances.where((attendance) {
      final attendanceDate = DateTime.parse(attendance.date);
      return attendanceDate.year == now.year &&
          attendanceDate.month == now.month;
    }).toList();
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _setState(HistoryLoadingState newState) {
    if (_state != newState) {
      _state = newState;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(HistoryLoadingState.error);

    if (kDebugMode) {
      print('❌ AttendanceHistoryController Error: $message');
    }
  }

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      if (kDebugMode) {
        print('🧹 Error message cleared');
      }
    }
  }

  // Check if current state should show empty vs error
  bool get shouldShowEmptyState {
    return !hasData && !hasError && !isLoading;
  }

  bool get shouldShowErrorState {
    return hasError &&
        _errorMessage.isNotEmpty &&
        !_errorMessage.toLowerCase().contains('validation') &&
        !_errorMessage.toLowerCase().contains('no data') &&
        !_errorMessage.toLowerCase().contains('tidak ada data');
  }

  // Reset controller
  void reset() {
    _attendances.clear();
    _pagination = null;
    _statistics = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _selectedMonth = null;
    _selectedYear = null;
    _setState(HistoryLoadingState.idle);
    _errorMessage = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
