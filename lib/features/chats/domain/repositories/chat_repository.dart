import '../../data/models/chat_models.dart';

abstract class ChatRepository {
  Future<List<ChatChannel>> listMyChannels({int page, int pageSize});
  Future<List<ChatMessage>> getChannelMessages({
    required String channelId,
    int page,
    int pageSize,
  });
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
  });
  Future<void> markAsRead({required String channelId});

  Future<List<ChatChannel>> adminListChannels({
    int page,
    int pageSize,
    Map<String, dynamic>? filters,
  });
  Future<void> adminPostIntervention({
    required String channelId,
    required String text,
  });
}
