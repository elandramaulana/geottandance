import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  FlutterSecureStorage? _secureStorage;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';

  // Secure storage options
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static const LinuxOptions _linuxOptions = LinuxOptions();

  static const WindowsOptions _windowsOptions = WindowsOptions();

  static const MacOsOptions _macOsOptions = MacOsOptions();

  static const WebOptions _webOptions = WebOptions();

  // Initialize FlutterSecureStorage
  Future<void> initialize() async {
    _secureStorage ??= const FlutterSecureStorage(
      aOptions: _androidOptions,
      iOptions: _iosOptions,
      lOptions: _linuxOptions,
      wOptions: _windowsOptions,
      mOptions: _macOsOptions,
      webOptions: _webOptions,
    );

    if (kDebugMode) {
      print('🔐 Secure Storage initialized');
    }
  }

  // Pastikan SecureStorage sudah diinisialisasi
  FlutterSecureStorage get _storage {
    if (_secureStorage == null) {
      throw Exception('Storage not initialized. Call initialize() first.');
    }
    return _secureStorage!;
  }

  // ========== AUTH RELATED METHODS ==========

  // Save login session
  Future<bool> saveLoginSession({
    required String token,
    required int userId,
    required String role,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _userIdKey, value: userId.toString()),
        _storage.write(key: _userRoleKey, value: role),
        _storage.write(key: _isLoggedInKey, value: 'true'),
      ]);

      if (kDebugMode) {
        print('✅ Login session saved successfully');
        print('📝 Token: ${token.substring(0, 10)}...');
        print('📝 User ID: $userId');
        print('📝 Role: $role');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving login session: $e');
      }
      return false;
    }
  }

  // Get auth token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token: $e');
      }
      return null;
    }
  }

  // Get user ID
  Future<int?> getUserId() async {
    try {
      final userIdString = await _storage.read(key: _userIdKey);
      if (userIdString != null) {
        return int.tryParse(userIdString);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user ID: $e');
      }
      return null;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user role: $e');
      }
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedString = await _storage.read(key: _isLoggedInKey);
      final token = await _storage.read(key: _tokenKey);

      // User dianggap login jika flag true DAN token tersedia
      return isLoggedString == 'true' && token != null && token.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking login status: $e');
      }
      return false;
    }
  }

  // Clear login session (logout)
  Future<bool> clearSession() async {
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _userRoleKey),
        _storage.write(key: _isLoggedInKey, value: 'false'),
      ]);

      if (kDebugMode) {
        print('🔓 Session cleared successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing session: $e');
      }
      return false;
    }
  }

  // Get complete user session data
  Future<UserSession?> getUserSession() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _tokenKey),
        _storage.read(key: _userIdKey),
        _storage.read(key: _userRoleKey),
        _storage.read(key: _isLoggedInKey),
      ]);

      final token = results[0];
      final userIdString = results[1];
      final role = results[2];
      final isLoggedString = results[3];

      if (token != null &&
          userIdString != null &&
          role != null &&
          isLoggedString == 'true') {
        final userId = int.tryParse(userIdString);
        if (userId != null) {
          return UserSession(
            token: token,
            userId: userId,
            role: role,
            isLoggedIn: true,
          );
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user session: $e');
      }
      return null;
    }
  }

  // ========== GENERAL SECURE STORAGE METHODS ==========

  // Save string value
  Future<bool> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving string for key $key: $e');
      }
      return false;
    }
  }

  // Get string value
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting string for key $key: $e');
      }
      return null;
    }
  }

  // Save integer value
  Future<bool> saveInt(String key, int value) async {
    try {
      await _storage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving int for key $key: $e');
      }
      return false;
    }
  }

  // Get integer value
  Future<int?> getInt(String key) async {
    try {
      final stringValue = await _storage.read(key: key);
      if (stringValue != null) {
        return int.tryParse(stringValue);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting int for key $key: $e');
      }
      return null;
    }
  }

  // Save boolean value
  Future<bool> saveBool(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving bool for key $key: $e');
      }
      return false;
    }
  }

  // Get boolean value
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final stringValue = await _storage.read(key: key);
      if (stringValue != null) {
        return stringValue.toLowerCase() == 'true';
      }
      return defaultValue;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting bool for key $key: $e');
      }
      return defaultValue;
    }
  }

  // Save double value
  Future<bool> saveDouble(String key, double value) async {
    try {
      await _storage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving double for key $key: $e');
      }
      return false;
    }
  }

  // Get double value
  Future<double?> getDouble(String key) async {
    try {
      final stringValue = await _storage.read(key: key);
      if (stringValue != null) {
        return double.tryParse(stringValue);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting double for key $key: $e');
      }
      return null;
    }
  }

  // Save list of strings (sebagai JSON string)
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      // Convert list to JSON string
      final jsonString = value.join('|||'); // Simple delimiter approach
      await _storage.write(key: key, value: jsonString);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving string list for key $key: $e');
      }
      return false;
    }
  }

  // Get list of strings
  Future<List<String>?> getStringList(String key) async {
    try {
      final jsonString = await _storage.read(key: key);
      if (jsonString != null && jsonString.isNotEmpty) {
        return jsonString.split('|||');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting string list for key $key: $e');
      }
      return null;
    }
  }

  // Remove specific key
  Future<bool> remove(String key) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing key $key: $e');
      }
      return false;
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking key $key: $e');
      }
      return false;
    }
  }

  // Clear all storage data
  Future<bool> clearAll() async {
    try {
      await _storage.deleteAll();

      if (kDebugMode) {
        print('🗑️ All secure storage data cleared');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing all data: $e');
      }
      return false;
    }
  }

  // Get all keys
  Future<Set<String>> getAllKeys() async {
    try {
      final allData = await _storage.readAll();
      return allData.keys.toSet();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all keys: $e');
      }
      return <String>{};
    }
  }

  // Get all data (untuk debugging - hati-hati dengan sensitive data)
  Future<Map<String, String>> getAllData() async {
    try {
      if (kDebugMode) {
        return await _storage.readAll();
      } else {
        throw Exception(
          'getAllData() only available in debug mode for security',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all data: $e');
      }
      return <String, String>{};
    }
  }

  // Check storage health
  Future<bool> checkStorageHealth() async {
    try {
      const testKey = 'health_check_test';
      const testValue = 'test_value';

      // Write test
      await _storage.write(key: testKey, value: testValue);

      // Read test
      final readValue = await _storage.read(key: testKey);

      // Cleanup test
      await _storage.delete(key: testKey);

      return readValue == testValue;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage health check failed: $e');
      }
      return false;
    }
  }
}

// Model untuk user session data
class UserSession {
  final String token;
  final int userId;
  final String role;
  final bool isLoggedIn;

  UserSession({
    required this.token,
    required this.userId,
    required this.role,
    required this.isLoggedIn,
  });

  @override
  String toString() {
    return 'UserSession{userId: $userId, role: $role, isLoggedIn: $isLoggedIn, token: ${token.substring(0, 10)}...}';
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'userId': userId,
      'role': role,
      'isLoggedIn': isLoggedIn,
    };
  }

  // Create from Map
  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      token: map['token'] ?? '',
      userId: map['userId'] ?? 0,
      role: map['role'] ?? '',
      isLoggedIn: map['isLoggedIn'] ?? false,
    );
  }
}
