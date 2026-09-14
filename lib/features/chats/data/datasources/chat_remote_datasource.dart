// lib/features/chats/data/datasources/chat_remote_datasource.dart

import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/network/dio_client.dart';

import '../models/chat_models.dart';

class ChatRemoteDataSource {
  ///   List channels for current user
  Future<List<ChatChannel>> listMyChannels({
    int page = 1,
    int pageSize = 20,
  }) async {
    final dioClient = await DioClient.create();
    final response = await dioClient.dio.get(
      ApiConstants.listMyChannels,
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    final data = response.data['message']['data'];
    return (data['items'] as List)
        .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///   Get paginated messages for a channel
  Future<List<ChatMessage>> getChannelMessages({
    required String channelId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final dioClient = await DioClient.create();
    final response = await dioClient.dio.get(
      ApiConstants.getChannelMessages,
      queryParameters: {
        'channel_id': channelId,
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data['message']['data'];
    return (data['messages'] as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///   Send a message
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
  }) async {
    final dioClient = await DioClient.create();
    final response = await dioClient.dio.post(
      ApiConstants.sendMessage,
      data: {'channel_id': channelId, 'text': text},
    );

    final data = response.data['message']['data'];
    return ChatMessage.fromJson(data as Map<String, dynamic>);
  }

  ///   Mark channel as read
  Future<void> markAsRead({required String channelId}) async {
    final dioClient = await DioClient.create();
    await dioClient.dio.post(
      ApiConstants.markAsRead,
      data: {'channel_id': channelId},
    );
  }

  ///   Admin: list all channels
  Future<List<ChatChannel>> adminListChannels({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    final dioClient = await DioClient.create();
    final response = await dioClient.dio.get(
      ApiConstants.adminListChannels,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (filters != null) 'filters': filters,
      },
    );

    final data = response.data['message']['data'];
    return (data['items'] as List)
        .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///   Admin: post official intervention
  Future<void> adminPostIntervention({
    required String channelId,
    required String text,
  }) async {
    final dioClient = await DioClient.create();
    await dioClient.dio.post(
      ApiConstants.adminPostIntervention,
      data: {'channel_id': channelId, 'text': text},
    );
  }
}
