import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';

/// Local storage service using Hive and Secure Storage
class StorageService {
  static late Box _box;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  static Future<void> init() async {
    _box = await Hive.openBox('stepify_storage');
  }
  
  // ============================================
  // SECURE STORAGE (for tokens)
  // ============================================
  
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }
  
  static Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConstants.accessTokenKey);
  }
  
  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }
  
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }
  
  // ============================================
  // HIVE STORAGE (for general data)
  // ============================================
  
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.put(AppConstants.userKey, user);
  }
  
  static Map<String, dynamic>? getUser() {
    final data = _box.get(AppConstants.userKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
  
  static Future<void> clearUser() async {
    await _box.delete(AppConstants.userKey);
  }
  
  // Onboarding
  static bool isOnboardingComplete() {
    return _box.get(AppConstants.onboardingCompleteKey, defaultValue: false);
  }
  
  static Future<void> setOnboardingComplete() async {
    await _box.put(AppConstants.onboardingCompleteKey, true);
  }
  
  // Theme
  static String getThemeMode() {
    return _box.get(AppConstants.themeKey, defaultValue: 'system');
  }
  
  static Future<void> setThemeMode(String mode) async {
    await _box.put(AppConstants.themeKey, mode);
  }
  
  // Generic methods
  static Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }
  
  static T? get<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }
  
  static Future<void> delete(String key) async {
    await _box.delete(key);
  }
  
  static Future<void> clearAll() async {
    await _box.clear();
    await _secureStorage.deleteAll();
  }
}
