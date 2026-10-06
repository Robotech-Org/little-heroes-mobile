import 'dart:convert';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/home/data/models/newsletter_model.dart';

/// Offline cache for newsletters using the app's SharedPreferences
/// (via StorageService) as the backing store.
///
/// Stores the entire JSON list under a single key. Also stores
/// a timestamp so we can show "last updated X ago" if needed.
class NewsletterCacheService {
  NewsletterCacheService._();
  static final NewsletterCacheService instance = NewsletterCacheService._();

  static const String _keyItems = 'cache_newsletters_items';
  static const String _keyTimestamp = 'cache_newsletters_timestamp';

  final _storage = StorageService.instance;

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> save(List<NewsletterModel> items) async {
    try {
      final rawList = items.map((n) => n.toJson()).toList();
      final json = jsonEncode(rawList);
      await _storage.saveString(_keyItems, json);
      await _storage.saveString(
        _keyTimestamp,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Silent — cache is best-effort
    }
  }

  // ══════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════

  List<NewsletterModel>? load() {
    try {
      final raw = _storage.getString(_keyItems);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      return decoded
          .whereType<Map>()
          .map((m) => NewsletterModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════
  // TIMESTAMP
  // ══════════════════════════════════════════════════

  DateTime? lastUpdated() {
    final raw = _storage.getString(_keyTimestamp);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ══════════════════════════════════════════════════
  // CLEAR (call on logout)
  // ══════════════════════════════════════════════════

  Future<void> clear() async {
    await _storage.saveString(_keyItems, '');
    await _storage.saveString(_keyTimestamp, '');
  }
}
