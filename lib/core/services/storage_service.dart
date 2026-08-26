import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_constants.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  SharedPreferences? _preferences;

  // =========================
  // Initialization
  // =========================

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefs {
    if (_preferences == null) {
      throw StateError(
        'StorageService has not been initialized. '
        'Call StorageService.instance.init() first.',
      );
    }

    return _preferences!;
  }

  // =========================
  // Secure Storage
  // =========================

  Future<void> saveSecure(
    String key,
    String value,
  ) async {
    await _secureStorage.write(
      key: key,
      value: value,
    );
  }

  Future<String?> getSecure(String key) async {
    return _secureStorage.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // =========================
  // Normal Storage
  // =========================

  Future<bool> saveString(
    String key,
    String value,
  ) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> saveBool(
    String key,
    bool value,
  ) async {
    return _prefs.setBool(key, value);
  }

  bool getBool(
    String key, {
    bool defaultValue = false,
  }) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<bool> saveInt(
    String key,
    int value,
  ) async {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> saveDouble(
    String key,
    double value,
  ) async {
    return _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  bool contains(String key) {
    return _prefs.containsKey(key);
  }

  Future<bool> clear() async {
    return _prefs.clear();
  }

  // =========================
  // JSON Storage
  // =========================

  Future<bool> saveJson(
    String key,
    Map<String, dynamic> value,
  ) async {
    return saveString(
      key,
      jsonEncode(value),
    );
  }

  Map<String, dynamic>? getJson(String key) {
    final value = getString(key);

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // =========================
  // Access Token
  // =========================

  Future<void> saveAccessToken(String token) async {
    await saveSecure(
      StorageConstants.accessToken,
      token,
    );
  }

  Future<String?> getAccessToken() async {
    return getSecure(
      StorageConstants.accessToken,
    );
  }

  Future<void> removeAccessToken() async {
    await removeSecure(
      StorageConstants.accessToken,
    );
  }

  // =========================
  // Refresh Token
  // =========================

  Future<void> saveRefreshToken(String token) async {
    await saveSecure(
      StorageConstants.refreshToken,
      token,
    );
  }

  Future<String?> getRefreshToken() async {
    return getSecure(
      StorageConstants.refreshToken,
    );
  }

  Future<void> removeRefreshToken() async {
    await removeSecure(
      StorageConstants.refreshToken,
    );
  }

  // =========================
  // Authentication
  // =========================

  Future<void> setLoggedIn(bool value) async {
    await saveBool(
      StorageConstants.isLoggedIn,
      value,
    );
  }

  bool isLoggedIn() {
    return getBool(
      StorageConstants.isLoggedIn,
    );
  }

  // =========================
  // User
  // =========================

  Future<void> saveUser(
    Map<String, dynamic> user,
  ) async {
    await saveJson(
      StorageConstants.user,
      user,
    );
  }

  Map<String, dynamic>? getUser() {
    return getJson(
      StorageConstants.user,
    );
  }

  Future<void> removeUser() async {
    await remove(
      StorageConstants.user,
    );
  }

  // =========================
  // User ID
  // =========================

  Future<void> saveUserId(String id) async {
    await saveString(
      StorageConstants.userId,
      id,
    );
  }

  String? getUserId() {
    return getString(
      StorageConstants.userId,
    );
  }

  // =========================
  // Onboarding
  // =========================

  Future<void> setOnboardingCompleted(
    bool value,
  ) async {
    await saveBool(
      StorageConstants.onboardingCompleted,
      value,
    );
  }

  bool isOnboardingCompleted() {
    return getBool(
      StorageConstants.onboardingCompleted,
    );
  }

  // =========================
  // Theme
  // =========================

  Future<void> saveThemeMode(String mode) async {
    await saveString(
      StorageConstants.themeMode,
      mode,
    );
  }

  String? getThemeMode() {
    return getString(
      StorageConstants.themeMode,
    );
  }

  // =========================
  // Language
  // =========================

  Future<void> saveLanguage(String language) async {
    await saveString(
      StorageConstants.language,
      language,
    );
  }

  String? getLanguage() {
    return getString(
      StorageConstants.language,
    );
  }

  // =========================
  // Notifications
  // =========================

  Future<void> setNotificationsEnabled(
    bool value,
  ) async {
    await saveBool(
      StorageConstants.notificationsEnabled,
      value,
    );
  }

  bool areNotificationsEnabled() {
    return getBool(
      StorageConstants.notificationsEnabled,
      defaultValue: true,
    );
  }

  // =========================
  // Cache
  // =========================

  Future<void> saveCachedData(
    String key,
    Map<String, dynamic> data,
  ) async {
    await saveJson(key, data);
  }

  Map<String, dynamic>? getCachedData(String key) {
    return getJson(key);
  }

  Future<void> removeCachedData(String key) async {
    await remove(key);
  }

  // =========================
  // Last Sync
  // =========================

  Future<void> saveLastSyncTime(
    DateTime dateTime,
  ) async {
    await saveString(
      StorageConstants.lastSyncTime,
      dateTime.toIso8601String(),
    );
  }

  DateTime? getLastSyncTime() {
    final value = getString(
      StorageConstants.lastSyncTime,
    );

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  // =========================
  // Logout
  // =========================

  Future<void> logout() async {
    await removeSecure(
      StorageConstants.accessToken,
    );

    await removeSecure(
      StorageConstants.refreshToken,
    );

    await remove(
      StorageConstants.isLoggedIn,
    );

    await remove(
      StorageConstants.userId,
    );

    await remove(
      StorageConstants.user,
    );
  }

  // =========================
  // Clear Everything
  // =========================

  Future<void> clearEverything() async {
    await clearSecure();
    await clear();
  }
}