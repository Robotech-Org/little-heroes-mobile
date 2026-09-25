import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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

      //  Accept null, missing key, or non-list → return empty
      final raw = data['messages'];
      if (raw == null) return const [];
      if (raw is! List) {
        // Some backends return { "items": [...] } instead
        final items = data['items'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return const [];
      }

      return raw
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
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
  // UPLOAD ATTACHMENT (Step 1 of two-step flow)
  // ═════════════════════════════════════════════════════════════
  Future<AttachmentUploadResult> uploadAttachment({
    required String channelId,
    required File file,
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    try {
      final dioClient = await DioClient.create();

      final name = fileName ?? file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'channel_id': channelId,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: name,
          contentType: _contentTypeFor(name),
        ),
      });

      final response = await dioClient.dio.post(
        ApiConstants.uploadAttachment,
        data: formData,
        onSendProgress: onProgress,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = _unwrap(response.data);
      return AttachmentUploadResult.fromJson(data);
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // SEND MESSAGE (supports text, file_url, or direct multipart)
  // ═════════════════════════════════════════════════════════════
  Future<ChatMessage> sendMessage({
    required String channelId,
    String text = '',
    String? fileUrl,
    String? messageType,
    // Option 2: direct multipart (skip upload_attachment call)
    File? directFile,
    ProgressCallback? onProgress,
  }) async {
    try {
      final dioClient = await DioClient.create();

      // ── Direct multipart upload path ──────────────────────
      if (directFile != null) {
        final name = directFile.path.split(Platform.pathSeparator).last;
        final formData = FormData.fromMap({
          'channel_id': channelId,
          'text': text,
          'file': await MultipartFile.fromFile(
            directFile.path,
            filename: name,
            contentType: _contentTypeFor(name),
          ),
        });

        final response = await dioClient.dio.post(
          ApiConstants.sendMessage,
          data: formData,
          onSendProgress: onProgress,
          options: Options(contentType: 'multipart/form-data'),
        );

        final data = _unwrap(response.data);
        return ChatMessage.fromJson(Map<String, dynamic>.from(data));
      }

      // ── Two-step / text-only JSON path ────────────────────
      final response = await dioClient.dio.post(
        ApiConstants.sendMessage,
        data: {
          'channel_id': channelId,
          'text': text,
          if (fileUrl != null) 'file_url': fileUrl,
          if (messageType != null) 'message_type': messageType,
        },
      );

      final data = _unwrap(response.data);
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

  /// Maps a filename extension to a MIME type so the multipart upload
  /// advertises the correct `Content-Type` to the backend.
  MediaType? _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.heic')) return MediaType('image', 'heic');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    if (lower.endsWith('.doc')) return MediaType('application', 'msword');
    if (lower.endsWith('.docx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    if (lower.endsWith('.xls')) {
      return MediaType('application', 'vnd.ms-excel');
    }
    if (lower.endsWith('.xlsx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
    if (lower.endsWith('.txt')) return MediaType('text', 'plain');
    return null; // let Dio guess from extension
  }

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
