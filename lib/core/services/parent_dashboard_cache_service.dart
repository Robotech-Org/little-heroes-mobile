import 'dart:convert';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/home/data/models/dashboard_response_model.dart';

/// Offline cache for the parent dashboard.
///
/// Serializes the entire `ParentData` into a single JSON blob stored
/// in SharedPreferences (via StorageService). Persists across app
/// restarts and works fully offline.
class ParentDashboardCacheService {
  ParentDashboardCacheService._();
  static final ParentDashboardCacheService instance =
      ParentDashboardCacheService._();

  static const String _keyPrefix = 'cache_parent_dashboard_';
  static const String _keyTimestampPrefix = 'cache_parent_dashboard_ts_';

  final _storage = StorageService.instance;

  // Scoped by student: one cache entry for "All Children" (null) and one
  // per child id.
  String _key(String? studentId) => '$_keyPrefix${studentId ?? "all"}';
  String _tsKey(String? studentId) =>
      '$_keyTimestampPrefix${studentId ?? "all"}';

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> save(String? studentId, ParentData data) async {
    try {
      final raw = data.toJson();
      await _storage.saveString(_key(studentId), jsonEncode(raw));
      await _storage.saveString(
        _tsKey(studentId),
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Best-effort
    }
  }

  // ══════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════

  ParentData? load(String? studentId) {
    try {
      final raw = _storage.getString(_key(studentId));
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      return ParentData.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  DateTime? lastUpdated(String? studentId) {
    final raw = _storage.getString(_tsKey(studentId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ══════════════════════════════════════════════════
  // CLEAR
  // ══════════════════════════════════════════════════

  Future<void> clearAll() async {
    try {
      // Can't iterate keys via StorageService easily; clear the two
      // most common ones + let old entries age out. For a full wipe,
      // use Hive/SharedPreferences directly. For now we clear the
      // generic key and the first child's if known.
      await _storage.saveString(_key(null), '');
      await _storage.saveString(_tsKey(null), '');
    } catch (_) {}
  }
}
