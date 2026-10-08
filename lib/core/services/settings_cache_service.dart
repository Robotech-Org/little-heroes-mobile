import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/settings/data/models/user_preferences_model.dart';
import 'package:little_heroes_mobile/features/settings/data/models/user_profile_model.dart';
import 'package:little_heroes_mobile/features/settings/domain/entities/user_preferences.dart';
import 'package:little_heroes_mobile/features/settings/domain/entities/user_profile.dart';

/// Offline cache for user settings (preferences + profile).
///
/// Keyed by nothing — settings belong to the logged-in user, and the
/// cache is cleared on logout.
class SettingsCacheService {
  SettingsCacheService._();
  static final SettingsCacheService instance = SettingsCacheService._();

  static const String _keyPrefs = 'cache_settings_prefs';
  static const String _keyProfile = 'cache_settings_profile';
  static const String _keyTimestamp = 'cache_settings_ts';

  final _storage = StorageService.instance;

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> savePrefs(UserPreferences prefs) async {
    try {
      final payload = {
        'user_type': prefs.userType,
        // 'biometric_login_enabled': prefs.biometricLoginEnabled ? 1 : 0,
        'quiet_hours_enabled': prefs.quietHoursEnabled ? 1 : 0,
        'quiet_hours_start': prefs.quietHoursStart,
        'quiet_hours_end': prefs.quietHoursEnd,
        'notify_chat': prefs.notifyChat ? 1 : 0,
        'notify_attendance': prefs.notifyAttendance ? 1 : 0,
        'notify_daily_reports': prefs.notifyDailyReports ? 1 : 0,
        'notify_moments': prefs.notifyMoments ? 1 : 0,
        'notify_billing': prefs.notifyBilling ? 1 : 0,
        'notify_leave_updates': prefs.notifyLeaveUpdates ? 1 : 0,
        'notify_announcements': prefs.notifyAnnouncements ? 1 : 0,
        'receive_sms_updates': prefs.receiveSmsUpdates ? 1 : 0,
      };
      await _storage.saveString(_keyPrefs, jsonEncode(payload));
      await _touch();
    } catch (e) {
      if (kDebugMode) debugPrint('SettingsCache.savePrefs failed: $e');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      final payload = {
        'user_id': profile.userId,
        'user_type': profile.userType,
        'full_name': profile.fullName,
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'email': profile.email,
        'phone_number': profile.phoneNumber,
        'emergency_phone': profile.emergencyPhone,
        'user_image': profile.userImage,
        'relationship_type': profile.relationshipType,
        'address': profile.address,
        'children': profile.children
            .map(
              (c) => {
                'student_id': c.studentId,
                'student_name': c.studentName,
                'student_photo': c.studentPhoto,
                'classroom': c.classroom,
                'status': c.status,
              },
            )
            .toList(),
      };
      await _storage.saveString(_keyProfile, jsonEncode(payload));
      await _touch();
    } catch (e) {
      if (kDebugMode) debugPrint('SettingsCache.saveProfile failed: $e');
    }
  }

  Future<void> saveAll({
    UserPreferencesModel? prefs,
    UserProfileModel? profile,
  }) async {
    if (prefs != null) await savePrefs(prefs);
    if (profile != null) await saveProfile(profile);
  }

  Future<void> _touch() async {
    try {
      await _storage.saveString(
        _keyTimestamp,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════

  UserPreferencesModel? loadPrefs() {
    try {
      final raw = _storage.getString(_keyPrefs);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return UserPreferencesModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      if (kDebugMode) debugPrint('SettingsCache.loadPrefs failed: $e');
      return null;
    }
  }

  UserProfileModel? loadProfile() {
    try {
      final raw = _storage.getString(_keyProfile);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return UserProfileModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      if (kDebugMode) debugPrint('SettingsCache.loadProfile failed: $e');
      return null;
    }
  }

  DateTime? lastUpdated() {
    final raw = _storage.getString(_keyTimestamp);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ══════════════════════════════════════════════════
  // CLEAR
  // ══════════════════════════════════════════════════

  Future<void> clear() async {
    try {
      await _storage.saveString(_keyPrefs, '');
      await _storage.saveString(_keyProfile, '');
      await _storage.saveString(_keyTimestamp, '');
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════

  Map<String, dynamic> _profileToJson(UserProfileModel p) => {
    'user_id': p.userId,
    'user_type': p.userType,
    'full_name': p.fullName,
    'first_name': p.firstName,
    'last_name': p.lastName,
    'email': p.email,
    'phone_number': p.phoneNumber,
    'emergency_phone': p.emergencyPhone,
    'user_image': p.userImage,
    'relationship_type': p.relationshipType,
    'address': p.address,
    'children': p.children
        .map(
          (c) => {
            'student_id': c.studentId,
            'student_name': c.studentName,
            'student_photo': c.studentPhoto,
            'classroom': c.classroom,
            'status': c.status,
          },
        )
        .toList(),
  };
}
