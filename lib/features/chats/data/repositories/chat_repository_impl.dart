import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_models.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl({required this.remote});

  @override
  Future<List<ChatChannel>> listMyChannels({int page = 1, int pageSize = 20}) =>
      remote.listMyChannels(page: page, pageSize: pageSize);

  @override
  Future<List<ChatMessage>> getChannelMessages({
    required String channelId,
    int page = 1,
    int pageSize = 50,
  }) => remote.getChannelMessages(
    channelId: channelId,
    page: page,
    pageSize: pageSize,
  );

  @override
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String text,
  }) => remote.sendMessage(channelId: channelId, text: text);

  @override
  Future<AttachmentUploadResult> uploadAttachment({
    required String channelId,
    required File file,
    String? fileName,
    ProgressCallback? onProgress,
  }) => remote.uploadAttachment(
    channelId: channelId,
    file: file,
    fileName: fileName,
    onProgress: onProgress,
  );

  @override
  Future<ChatMessage> sendAttachmentMessage({
    required String channelId,
    required AttachmentUploadResult attachment,
    String text = '',
  }) => remote.sendMessage(
    channelId: channelId,
    text: text,
    fileUrl: attachment.fileUrl,
    messageType: attachment.messageType,
  );

  @override
  Future<ChatMessage> sendMessageWithFile({
    required String channelId,
    required File file,
    String text = '',
    ProgressCallback? onProgress,
  }) => remote.sendMessage(
    channelId: channelId,
    text: text,
    directFile: file,
    onProgress: onProgress,
  );

  @override
  Future<void> markAsRead({required String channelId}) =>
      remote.markAsRead(channelId: channelId);

  @override
  Future<List<ChatChannel>> adminListChannels({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) => remote.adminListChannels(
    page: page,
    pageSize: pageSize,
    filters: filters,
  );

  @override
  Future<void> adminPostIntervention({
    required String channelId,
    required String text,
  }) => remote.adminPostIntervention(channelId: channelId, text: text);
}
