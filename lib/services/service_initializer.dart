import 'package:flutter/foundation.dart';
import 'package:geottandance/core/base_provider.dart';
import 'storage_service.dart';

class ServiceInitializer {
  static bool _isInitialized = false;

  /// Inisialisasi semua service yang diperlukan
  static Future<void> initializeServices() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ Services already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🚀 Starting services initialization...');
      }

      // Inisialisasi Storage Service terlebih dahulu (diperlukan oleh API Provider)
      await _initializeStorageService();

      // Inisialisasi Base API Provider
      await _initializeApiProvider();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ All services initialized successfully');
      }
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print('❌ Error initializing services: $e');
      }
      rethrow;
    }
  }

  /// Inisialisasi Storage Service
  static Future<void> _initializeStorageService() async {
    try {
      if (kDebugMode) {
        print('📦 Initializing Storage Service...');
      }

      await StorageService().initialize();

      if (kDebugMode) {
        print('✅ Storage Service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Storage Service: $e');
      }
      throw Exception('Storage Service initialization failed: $e');
    }
  }

  /// Inisialisasi API Provider
  static Future<void> _initializeApiProvider() async {
    try {
      if (kDebugMode) {
        print('🌐 Initializing API Provider...');
      }

      BaseApiProvider().initialize();

      if (kDebugMode) {
        print('✅ API Provider initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize API Provider: $e');
      }
      throw Exception('API Provider initialization failed: $e');
    }
  }

  /// Check apakah services sudah diinisialisasi
  static bool get isInitialized => _isInitialized;

  /// Reset initialization status (untuk testing atau restart)
  static void reset() {
    _isInitialized = false;
    if (kDebugMode) {
      print('🔄 Services initialization status reset');
    }
  }

  /// Inisialisasi ulang semua services
  static Future<void> reinitialize() async {
    reset();
    await initializeServices();
  }

  /// Cleanup semua services (untuk dispose)
  static Future<void> cleanup() async {
    try {
      if (kDebugMode) {
        print('🧹 Cleaning up services...');
      }

      // Cleanup storage jika diperlukan
      // await StorageService().cleanup(); // implement jika diperlukan

      _isInitialized = false;

      if (kDebugMode) {
        print('✅ Services cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during cleanup: $e');
      }
    }
  }

  /// Get service initialization status dengan detail
  static Map<String, dynamic> getInitializationStatus() {
    return {
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
      'services': {
        'storageService': 'initialized',
        'apiProvider': 'initialized',
      },
    };
  }
}
