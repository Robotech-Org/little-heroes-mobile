import 'dart:io';

import 'package:dio/dio.dart';

import '../../data/models/chat_models.dart';

abstract class ChatRepository {
  Future<List<ChatChannel>> listMyChannels({int page, int pageSize});
  Future<List<ChatMessage>> getChannelMessages({
    required String channelId,
    int page,
    int pageSize,
  });

  /// Sends a text-only message (JSON).
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
  });

  /// Uploads a file/image and returns its URL (Step 1).
  Future<AttachmentUploadResult> uploadAttachment({
    required String channelId,
    required File file,
    String? fileName,
    ProgressCallback? onProgress,
  });

  /// Sends a message referencing a previously uploaded file (Step 2).
  Future<ChatMessage> sendAttachmentMessage({
    required String channelId,
    required AttachmentUploadResult attachment,
    String text,
  });

  /// One-shot: uploads + sends in a single multipart request.
  Future<ChatMessage> sendMessageWithFile({
    required String channelId,
    required File file,
    String text,
    ProgressCallback? onProgress,
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
