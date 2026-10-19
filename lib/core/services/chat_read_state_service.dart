// core/services/chat_read_state_service.dart
//
// Local "last seen" timestamps per channel, persisted in Hive.
// A channel is unseen if its lastMessageTime > lastSeenAt for that channel.

import 'package:hive/hive.dart';
import 'package:little_heroes_mobile/features/chats/data/models/chat_models.dart';

class ChatReadStateService {
  static const _boxName = 'chat_read_state_v1';

  static final ChatReadStateService instance = ChatReadStateService._();
  ChatReadStateService._();

  Box<dynamic>? _box;

  /// Call ONCE in main() after Hive.initFlutter().
  Future<void> init() async {
    if (_box != null) return;
    _box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox<dynamic>(_boxName);
  }

  Box<dynamic> get _b {
    final b = _box;
    if (b == null) {
      throw StateError('ChatReadStateService.init() must be called first.');
    }
    return b;
  }

  DateTime? _lastSeenAt(String channelId) {
    final raw = _b.get(channelId);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  /// Persist that the user has seen this channel up to `at` (default: now).
  Future<void> markSeen(String channelId, {DateTime? at}) async {
    await _b.put(channelId, (at ?? DateTime.now()).toUtc().toIso8601String());
  }

  Future<void> clear(String channelId) => _b.delete(channelId);
  Future<void> clearAll() => _b.clear();

  /// True if there's activity the user hasn't opened yet.
  bool isUnseen(ChatChannel c) {
    final lastActivity = c.lastMessageTime ?? c.creationTime;
    if (lastActivity == null) return false;
    final seenAt = _lastSeenAt(c.ravenChannel);
    if (seenAt == null) return true;
    return lastActivity.toUtc().isAfter(seenAt);
  }

  int unseenCount(Iterable<ChatChannel> channels) {
    var count = 0;
    for (final c in channels) {
      if (isUnseen(c)) count++;
    }
    return count;
  }
}
