// // lib/features/chats/data/datasources/chat_remote_datasource.dart

// import 'package:little_heroes_mobile/core/constants/api_constants.dart';
// import 'package:little_heroes_mobile/core/network/dio_client.dart';

// import '../models/chat_models.dart';

// class ChatRemoteDataSource {
//   ///   List channels for current user
//   Future<List<ChatChannel>> listMyChannels({
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     final dioClient = await DioClient.create();
//     final response = await dioClient.dio.get(
//       ApiConstants.listMyChannels,
//       queryParameters: {'page': page, 'page_size': pageSize},
//     );

//     final data = response.data['message']['data'];
//     return (data['items'] as List)
//         .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   ///   Get paginated messages for a channel
//   Future<List<ChatMessage>> getChannelMessages({
//     required String channelId,
//     int page = 1,
//     int pageSize = 50,
//   }) async {
//     final dioClient = await DioClient.create();
//     final response = await dioClient.dio.get(
//       ApiConstants.getChannelMessages,
//       queryParameters: {
//         'channel_id': channelId,
//         'page': page,
//         'page_size': pageSize,
//       },
//     );

//     final data = response.data['message']['data'];
//     return (data['messages'] as List)
//         .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   ///   Send a message
//   Future<ChatMessage> sendMessage({
//     required String channelId,
//     required String text,
//   }) async {
//     final dioClient = await DioClient.create();
//     final response = await dioClient.dio.post(
//       ApiConstants.sendMessage,
//       data: {'channel_id': channelId, 'text': text},
//     );

//     final data = response.data['message']['data'];
//     return ChatMessage.fromJson(data as Map<String, dynamic>);
//   }

//   ///   Mark channel as read
//   Future<void> markAsRead({required String channelId}) async {
//     final dioClient = await DioClient.create();
//     await dioClient.dio.post(
//       ApiConstants.markAsRead,
//       data: {'channel_id': channelId},
//     );
//   }

//   ///   Admin: list all channels
//   Future<List<ChatChannel>> adminListChannels({
//     int page = 1,
//     int pageSize = 20,
//     Map<String, dynamic>? filters,
//   }) async {
//     final dioClient = await DioClient.create();
//     final response = await dioClient.dio.get(
//       ApiConstants.adminListChannels,
//       queryParameters: {
//         'page': page,
//         'page_size': pageSize,
//         if (filters != null) 'filters': filters,
//       },
//     );

//     final data = response.data['message']['data'];
//     return (data['items'] as List)
//         .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   ///   Admin: post official intervention
//   Future<void> adminPostIntervention({
//     required String channelId,
//     required String text,
//   }) async {
//     final dioClient = await DioClient.create();
//     await dioClient.dio.post(
//       ApiConstants.adminPostIntervention,
//       data: {'channel_id': channelId, 'text': text},
//     );
//   }
// }

// lib/features/chats/data/datasources/chat_remote_datasource.dart

import 'package:dio/dio.dart';

import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/error/dio_error_handler.dart';
import 'package:little_heroes_mobile/core/error/exceptions.dart';
import 'package:little_heroes_mobile/core/network/dio_client.dart';

import '../models/chat_models.dart';

class ChatRemoteDataSource {
  // ═════════════════════════════════════════════════════════════
  // LIST CHANNELS
  // ═════════════════════════════════════════════════════════════
  Future<List<ChatChannel>> listMyChannels({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get(
        ApiConstants.listMyChannels,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final data = _unwrap(response.data);
      final items = data['items'];
      if (items is! List) {
        throw const UnknownException('Unexpected response format');
      }

      return items
          .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // GET CHANNEL MESSAGES
  // ═════════════════════════════════════════════════════════════
  Future<List<ChatMessage>> getChannelMessages({
    required String channelId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get(
        ApiConstants.getChannelMessages,
        queryParameters: {
          'channel_id': channelId,
          'page': page,
          'page_size': pageSize,
        },
      );

      final data = _unwrap(response.data);
      final messages = data['messages'];
      if (messages is! List) {
        throw const UnknownException('Unexpected response format');
      }

      return messages
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // SEND MESSAGE
  // ═════════════════════════════════════════════════════════════
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
  }) async {
    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.post(
        ApiConstants.sendMessage,
        data: {'channel_id': channelId, 'text': text},
      );

      final data = _unwrap(response.data);
      if (data is! Map) {
        throw const UnknownException('Unexpected response format');
      }

      return ChatMessage.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // MARK AS READ
  // ═════════════════════════════════════════════════════════════
  Future<void> markAsRead({required String channelId}) async {
    try {
      final dioClient = await DioClient.create();
      await dioClient.dio.post(
        ApiConstants.markAsRead,
        data: {'channel_id': channelId},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // ADMIN — LIST CHANNELS
  // ═════════════════════════════════════════════════════════════
  Future<List<ChatChannel>> adminListChannels({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get(
        ApiConstants.adminListChannels,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (filters != null) 'filters': filters,
        },
      );

      final data = _unwrap(response.data);
      final items = data['items'];
      if (items is! List) {
        throw const UnknownException('Unexpected response format');
      }

      return items
          .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // ADMIN — POST INTERVENTION
  // ═════════════════════════════════════════════════════════════
  Future<void> adminPostIntervention({
    required String channelId,
    required String text,
  }) async {
    try {
      final dioClient = await DioClient.create();
      await dioClient.dio.post(
        ApiConstants.adminPostIntervention,
        data: {'channel_id': channelId, 'text': text},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════════════════════

  /// Frappe wraps every response as:
  ///   { "message": { "success": true, "data": { ... } } }
  /// This unwraps to the inner `data` map.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is! Map) {
      throw const UnknownException('Unexpected response type');
    }
    final json = Map<String, dynamic>.from(raw);

    final message = json['message'];
    if (message is Map) {
      final inner = Map<String, dynamic>.from(message);
      final data = inner['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      // Some endpoints return the data directly under `message`
      return inner;
    }

    // Some endpoints skip the envelope
    final data = json['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
  }
}
