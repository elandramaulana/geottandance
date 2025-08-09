import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geottandance/services/storage_service.dart';

class BaseApiProvider {
  static final BaseApiProvider _instance = BaseApiProvider._internal();
  factory BaseApiProvider() => _instance;
  BaseApiProvider._internal();

  late Dio _dio;
  final StorageService _storageService = StorageService();

  // Base URL untuk API
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request Interceptor - untuk menambahkan token ke setiap request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari storage
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('📤 REQUEST: ${options.method} ${options.uri}');
            print('📤 Headers: ${options.headers}');
            if (options.data != null) {
              print('📤 Data: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '📥 RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
            );
            print('📥 Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(
              '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}',
            );
            print('❌ Message: ${error.message}');
            print('❌ Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle successful response
  ApiResponse<T> _handleResponse<T>(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ApiResponse<T>(
        success: data['success'] ?? true,
        message: data['message'] ?? 'Request successful',
        data: data['data'],
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<T>(
      success: true,
      message: 'Request successful',
      data: data,
      statusCode: response.statusCode,
    );
  }

  // Handle error response
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = 'An error occurred';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final responseData = error.response?.data;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? 'Server error occurred';

          // Handle unauthorized (401) - token expired or invalid
          if (statusCode == 401) {
            _handleUnauthorized();
          }
        } else {
          message = _getStatusMessage(statusCode);
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error occurred';
        break;
      case DioExceptionType.unknown:
        message = 'An unexpected error occurred';
        break;
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      data: null,
      statusCode: statusCode,
    );
  }

  // Get status message based on HTTP status code
  String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized access';
      case 403:
        return 'Forbidden access';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        return 'Server error occurred';
    }
  }

  // Handle unauthorized access (401)
  void _handleUnauthorized() async {
    // Clear token dari storage
    await _storageService.clearSession();

    // Anda bisa menambahkan logic tambahan di sini,
    // seperti navigasi ke halaman login atau menampilkan dialog
    if (kDebugMode) {
      print('🔒 Unauthorized access detected. Session cleared.');
    }
  }

  // Update base URL jika diperlukan
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Get Dio instance jika diperlukan untuk custom request
  Dio get dioInstance => _dio;
}

// Model untuk response API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, data: $data, statusCode: $statusCode}';
  }
}
