import 'dart:convert';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/chats/data/models/chat_models.dart';

/// Offline cache for the chat channel list.
class ChatCacheService {
  ChatCacheService._();
  static final ChatCacheService instance = ChatCacheService._();

  static const String _key = 'cache_chat_channels';
  static const String _keyTimestamp = 'cache_chat_channels_ts';

  final _storage = StorageService.instance;

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> save(List<ChatChannel> channels) async {
    try {
      final raw = channels.map((c) => c.toJson()).toList();
      await _storage.saveString(_key, jsonEncode(raw));
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

  List<ChatChannel>? load() {
    try {
      final raw = _storage.getString(_key);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      return decoded
          .whereType<Map>()
          .map((m) => ChatChannel.fromJson(Map<String, dynamic>.from(m)))
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
    await _storage.saveString(_key, '');
    await _storage.saveString(_keyTimestamp, '');
  }
}
