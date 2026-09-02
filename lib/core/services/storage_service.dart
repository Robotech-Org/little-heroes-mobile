
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

  // ============================================================
  // INITIALIZATION
  // ============================================================

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

  // ============================================================
  // SECURE STORAGE
  // ============================================================

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

  // ============================================================
  // NORMAL STORAGE
  // ============================================================

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
    String key, {
    required bool value,
  }) async {
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

  // ============================================================
  // JSON STORAGE
  // ============================================================

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

  // ============================================================
  // ACCESS TOKEN
  // ============================================================

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

  // ============================================================
  // REFRESH TOKEN
  // ============================================================

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

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  Future<void> setLoggedIn(bool value) async {
    await saveBool(
      StorageConstants.isLoggedIn,
      value: value,
    );
  }

  bool isLoggedIn() {
    return getBool(
      StorageConstants.isLoggedIn,
    );
  }

  // ============================================================
  // USER
  // ============================================================

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

  // ============================================================
  // USER ID
  // ============================================================

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

  // ============================================================
  // ONBOARDING
  // ============================================================

  Future<void> setOnboardingCompleted(
    bool value,
  ) async {
    await saveBool(
      StorageConstants.onboardingCompleted,
      value: value,
    );
  }

  bool isOnboardingCompleted() {
    return getBool(
      StorageConstants.onboardingCompleted,
    );
  }

  // ============================================================
  // THEME
  // ============================================================

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

  Future<void> removeThemeMode() async {
    await remove(
      StorageConstants.themeMode,
    );
  }

  // ============================================================
  // LANGUAGE
  // ============================================================

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

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> setNotificationsEnabled(
    bool value,
  ) async {
    await saveBool(
      StorageConstants.notificationsEnabled,
      value: value,
    );
  }

  bool areNotificationsEnabled() {
    return getBool(
      StorageConstants.notificationsEnabled,
      defaultValue: true,
    );
  }

  // ============================================================
  // CACHE
  // ============================================================

  Future<void> saveCachedData(
    String key,
    Map<String, dynamic> data,
  ) async {
    await saveJson(
      key,
      data,
    );
  }

  Map<String, dynamic>? getCachedData(String key) {
    return getJson(key);
  }

  Future<void> removeCachedData(String key) async {
    await remove(key);
  }

  // ============================================================
  // LAST SYNC
  // ============================================================

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

  // ============================================================
  // LOGOUT
  // ============================================================

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

    // Theme preference is intentionally NOT removed.
    // The user's appearance preference should remain on the device.
  }

  // ============================================================
  // CLEAR EVERYTHING
  // ============================================================

  Future<void> clearEverything() async {
    await clearSecure();
    await clear();
  }
}
