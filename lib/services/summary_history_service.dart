// services/summary_history_service.dart
import 'package:flutter/foundation.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/models/summary_history_model.dart';
import 'package:geottandance/core/app_config.dart';
import 'dart:io';
import 'dart:async';

class SummaryHistoryService {
  static final SummaryHistoryService _instance =
      SummaryHistoryService._internal();
  factory SummaryHistoryService() => _instance;
  SummaryHistoryService._internal();

  final BaseApiProvider _apiProvider = BaseApiProvider();

  // Cache for storing recent data with month key
  final Map<int, SummaryHistoryModel> _cachedData = {};
  final Map<int, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Get attendance summary with caching and better error handling
  Future<SummaryHistoryModel?> getAttendanceSummary({
    int? month,
    bool forceRefresh = false,
  }) async {
    try {
      final currentMonth = month ?? DateTime.now().month;

      // Check if cached data is still valid (unless force refresh)
      if (!forceRefresh && _isCacheValid(currentMonth)) {
        if (kDebugMode) {
          print('📱 Using cached summary data for month $currentMonth');
        }
        return _cachedData[currentMonth];
      }

      if (kDebugMode) {
        print(
          '🔄 Fetching attendance summary from API for month $currentMonth...',
        );
      }

      // Use the endpoint from Endpoints class with month parameter
      final endpoint = Endpoints.getAttendanceSummaryUrl(month: currentMonth);

      final response = await _apiProvider
          .get<Map<String, dynamic>>(endpoint)
          .timeout(
            Duration(seconds: AppConfig.requestTimeoutSeconds),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout',
                Duration(seconds: AppConfig.requestTimeoutSeconds),
              );
            },
          );

      if (response.success && response.data != null) {
        final summaryModel = SummaryHistoryModel.fromJson(response.data!);

        // Cache the successful response with month key
        _cacheData(currentMonth, summaryModel);

        if (kDebugMode) {
          print('✅ Summary fetched successfully for month $currentMonth');
          print('📊 Period: ${summaryModel.period}');
          print('📊 Total Days: ${summaryModel.summary.totalDays}');
          print('📊 Present Days: ${summaryModel.summary.presentDays}');
          print('📊 Late Days: ${summaryModel.summary.lateDays}');
          print('📊 Absent Days: ${summaryModel.summary.absentDays}');
          print('📊 Leave Days: ${summaryModel.summary.leaveDays}');
          print('📊 Holiday Days: ${summaryModel.summary.holidayDays}');
          print('📊 Attendance Rate: ${summaryModel.summary.attendanceRate}%');
          print('📊 Total Work Hours: ${summaryModel.summary.totalWorkHours}');
          print(
            '📊 Total Overtime Hours: ${summaryModel.summary.totalOvertimeHours}',
          );
        }

        return summaryModel;
      } else {
        final errorMsg = response.message;
        if (kDebugMode) {
          print('❌ API Error: $errorMsg');
        }

        // Return cached data if available during API error
        if (_cachedData.containsKey(currentMonth)) {
          if (kDebugMode) {
            print('🔄 Returning cached data due to API error');
          }
          return _cachedData[currentMonth];
        }

        throw Exception('API Error: $errorMsg');
      }
    } on SocketException {
      if (kDebugMode) {
        print('❌ Network Error: No internet connection');
      }

      // Return cached data if available during network error
      final currentMonth = month ?? DateTime.now().month;
      if (_cachedData.containsKey(currentMonth)) {
        if (kDebugMode) {
          print('🔄 Returning cached data due to network error');
        }
        return _cachedData[currentMonth];
      }

      throw Exception('Network Error: Please check your internet connection');
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Timeout Error: ${e.message}');
      }

      // Return cached data if available during timeout
      final currentMonth = month ?? DateTime.now().month;
      if (_cachedData.containsKey(currentMonth)) {
        if (kDebugMode) {
          print('🔄 Returning cached data due to timeout');
        }
        return _cachedData[currentMonth];
      }

      throw Exception('Request timeout: Please try again');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('❌ Data Format Error: ${e.message}');
      }
      throw Exception('Invalid data format received from server');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected Error: $e');
      }

      // Return cached data if available during any other error
      final currentMonth = month ?? DateTime.now().month;
      if (_cachedData.containsKey(currentMonth)) {
        if (kDebugMode) {
          print('🔄 Returning cached data due to unexpected error');
        }
        return _cachedData[currentMonth];
      }

      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Check if cached data is still valid for specific month
  bool _isCacheValid(int month) {
    if (!_cachedData.containsKey(month) ||
        !_cacheTimestamps.containsKey(month)) {
      return false;
    }

    final now = DateTime.now();
    final cacheAge = now.difference(_cacheTimestamps[month]!);

    return cacheAge < _cacheValidDuration;
  }

  // Cache the data with timestamp for specific month
  void _cacheData(int month, SummaryHistoryModel data) {
    _cachedData[month] = data;
    _cacheTimestamps[month] = DateTime.now();

    if (kDebugMode) {
      print('💾 Data cached for month $month at ${_cacheTimestamps[month]}');
    }
  }

  // Clear cached data for specific month or all
  void clearCache({int? month}) {
    if (month != null) {
      _cachedData.remove(month);
      _cacheTimestamps.remove(month);
      if (kDebugMode) {
        print('🗑️ Cache cleared for month $month');
      }
    } else {
      _cachedData.clear();
      _cacheTimestamps.clear();
      if (kDebugMode) {
        print('🗑️ All cache cleared');
      }
    }
  }

  // Get cached data if available for specific month
  SummaryHistoryModel? getCachedData({int? month}) {
    final currentMonth = month ?? DateTime.now().month;
    return _isCacheValid(currentMonth) ? _cachedData[currentMonth] : null;
  }

  // Check if cache exists and is valid for specific month
  bool hasCachedData({int? month}) {
    final currentMonth = month ?? DateTime.now().month;
    return _isCacheValid(currentMonth);
  }

  // Get cache age in minutes for specific month
  int getCacheAgeInMinutes({int? month}) {
    final currentMonth = month ?? DateTime.now().month;
    if (!_cacheTimestamps.containsKey(currentMonth)) return -1;

    final now = DateTime.now();
    final cacheAge = now.difference(_cacheTimestamps[currentMonth]!);

    return cacheAge.inMinutes;
  }

  // Get available cached months
  List<int> getAvailableCachedMonths() {
    return _cachedData.keys.where((month) => _isCacheValid(month)).toList();
  }

  // Preload data for multiple months
  Future<void> preloadSummaryData(List<int> months) async {
    for (final month in months) {
      if (!_isCacheValid(month)) {
        try {
          await getAttendanceSummary(month: month);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to preload data for month $month: $e');
          }
        }
      }
    }
  }
}
