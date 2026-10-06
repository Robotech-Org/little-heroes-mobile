import 'dart:convert';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/notifications/data/models/announcement_model.dart';

/// Offline cache for the notifications / announcements list.
///
/// Stores the full list as a single JSON blob. Because pagination is
/// not relevant offline, we only cache the **first page** — which is
/// what users typically see.
class AnnouncementCacheService {
  AnnouncementCacheService._();
  static final AnnouncementCacheService instance = AnnouncementCacheService._();

  static const String _keyItems = 'cache_announcements_items';
  static const String _keyTimestamp = 'cache_announcements_ts';

  final _storage = StorageService.instance;

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> save(List<AnnouncementModel> items) async {
    try {
      final raw = items.map(_toJson).toList();
      await _storage.saveString(_keyItems, jsonEncode(raw));
      await _storage.saveString(
        _keyTimestamp,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Best-effort
    }
  }

  // ══════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════

  List<AnnouncementModel>? load() {
    try {
      final raw = _storage.getString(_keyItems);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      return decoded
          .whereType<Map>()
          .map((m) => _fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  DateTime? lastUpdated() {
    final raw = _storage.getString(_keyTimestamp);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _storage.saveString(_keyItems, '');
    await _storage.saveString(_keyTimestamp, '');
  }

  // ══════════════════════════════════════════════════
  // SERIALIZATION
  // ══════════════════════════════════════════════════

  Map<String, dynamic> _toJson(AnnouncementModel a) => a.toJson();

  AnnouncementModel _fromJson(Map<String, dynamic> j) =>
      AnnouncementModel.fromJson(j);
}
