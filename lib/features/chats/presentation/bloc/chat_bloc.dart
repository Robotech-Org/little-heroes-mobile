import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/network/socket/socket_service.dart';

import '../../data/models/chat_models.dart';
import '../../domain/repositories/chat_repository.dart';

// ============ EVENTS ============
abstract class ChatEvent {}

class LoadChannels extends ChatEvent {
  /// When `true`, the bloc will NOT emit `ChannelsLoading` first — it
  /// updates the list in place so the UI doesn't flicker on auto-refresh.
  final bool silent;

  LoadChannels({this.silent = false});
}

class OpenChannel extends ChatEvent {
  final String channelId;
  OpenChannel(this.channelId);
}

class CloseChannel extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String channelId;
  final bool loadMore;
  LoadMessages({required this.channelId, this.loadMore = false});
}

class SendChatMessage extends ChatEvent {
  final String channelId;
  final String text;
  SendChatMessage({required this.channelId, required this.text});
}

/// Send a text + file/image attachment.
///
/// Uses the two-step flow documented in
/// `Messaging Updates — Summary for Mobile Developers`:
///   1. `upload_attachment` → returns `file_url` + `message_type`
///   2. `send_message`      → posts the message referencing that URL
class SendAttachment extends ChatEvent {
  final String channelId;
  final File file;
  final String text;
  SendAttachment({required this.channelId, required this.file, this.text = ''});
}

class IncomingMessage extends ChatEvent {
  final Map<String, dynamic> payload;
  IncomingMessage(this.payload);
}

/// Internal event — reports upload progress for an in-flight attachment.
class UploadProgressChanged extends ChatEvent {
  final String tempId;
  final double progress;
  UploadProgressChanged({required this.tempId, required this.progress});
}

// ============ STATES ============
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChannelsLoading extends ChatState {}

class ChannelsLoaded extends ChatState {
  final List<ChatChannel> channels;
  ChannelsLoaded(this.channels);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChannelOpen extends ChatState {
  final String channelId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool hasMore;
  final int page;

  ChannelOpen({
    required this.channelId,
    this.messages = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
  });

  ChannelOpen copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return ChannelOpen(
      channelId: channelId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// ============ BLOC ============
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final SocketService socketService;

  StreamSubscription? _socketSub;
  Timer? _pollTimer;
  String? _activeChannelId;

  ChatBloc({required this.repository, required this.socketService})
    : super(ChatInitial()) {
    on<LoadChannels>(_onLoadChannels);
    on<OpenChannel>(_onOpenChannel);
    on<CloseChannel>(_onCloseChannel);
    on<LoadMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendChatMessage);
    on<SendAttachment>(_onSendAttachment);
    on<UploadProgressChanged>(_onUploadProgress);
    on<IncomingMessage>(_onIncomingMessage);

    // Socket.IO live updates (when the backend supports it)
    _socketSub = socketService.onNewMessage.listen((payload) {
      add(IncomingMessage(payload));
    });
  }

  // ═════════════════════════════════════════════
  // CHANNELS
  // ═════════════════════════════════════════════
  Future<void> _onLoadChannels(
    LoadChannels event,
    Emitter<ChatState> emit,
  ) async {
    if (!event.silent) emit(ChannelsLoading());

    try {
      final channels = await repository.listMyChannels();

      // When the request was silent and the payload is identical,
      // skip re-emitting to avoid useless rebuilds.
      if (event.silent && state is ChannelsLoaded) {
        final existing = (state as ChannelsLoaded).channels;
        if (_channelsEqual(existing, channels)) return;
      }

      emit(ChannelsLoaded(channels));
    } catch (e) {
      // For silent refresh failures, keep showing the previous list.
      if (!event.silent) emit(ChatError(e.toString()));
    }
  }

  bool _channelsEqual(List<ChatChannel> a, List<ChatChannel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].ravenChannel != b[i].ravenChannel) return false;
      if (a[i].lastMessageTime != b[i].lastMessageTime) return false;
      if (a[i].lastMessagePreview != b[i].lastMessagePreview) return false;
    }
    return true;
  }

  // ═════════════════════════════════════════════
  // OPEN / CLOSE CHANNEL
  // ═════════════════════════════════════════════
  Future<void> _onOpenChannel(
    OpenChannel event,
    Emitter<ChatState> emit,
  ) async {
    _activeChannelId = event.channelId;

    // Best-effort socket
    unawaited(socketService.connect());
    socketService.joinChannel(event.channelId);

    emit(ChannelOpen(channelId: event.channelId, isLoading: true));

    try {
      await repository.markAsRead(channelId: event.channelId);

      final messages = await repository.getChannelMessages(
        channelId: event.channelId,
        page: 1,
      );

      emit(
        ChannelOpen(
          channelId: event.channelId,
          messages: messages,
          hasMore: messages.length >= 50,
          page: 1,
        ),
      );

      // Start polling for new messages
      _startPolling(event.channelId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onCloseChannel(CloseChannel event, Emitter<ChatState> emit) {
    _stopPolling();
    if (_activeChannelId != null) {
      socketService.leaveChannel(_activeChannelId!);
      _activeChannelId = null;
    }
  }

  // ═════════════════════════════════════════════
  // POLLING
  // ═════════════════════════════════════════════
  void _startPolling(String channelId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollNewMessages(channelId);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollNewMessages(String channelId) async {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;
    if (current.channelId != channelId) return;

    try {
      final latest = await repository.getChannelMessages(
        channelId: channelId,
        page: 1,
      );

      final existingNames = current.messages.map((m) => m.name).toSet();
      final fresh = latest
          .where((m) => !existingNames.contains(m.name))
          .toList();

      if (fresh.isEmpty) return;
      if (state is! ChannelOpen) return;

      final now = state as ChannelOpen;
      if (now.channelId != channelId) return;

      final nowNames = now.messages.map((m) => m.name).toSet();
      final stillFresh = fresh
          .where((m) => !nowNames.contains(m.name))
          .toList();
      if (stillFresh.isEmpty) return;

      emit(now.copyWith(messages: [...now.messages, ...stillFresh]));
    } catch (_) {
      // Silent — polling failures shouldn't spam the UI
    }
  }

  // ═════════════════════════════════════════════
  // PAGINATION
  // ═════════════════════════════════════════════
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    if (!event.loadMore || !current.hasMore || current.isLoading) return;

    emit(current.copyWith(isLoading: true));

    try {
      final nextPage = current.page + 1;
      final messages = await repository.getChannelMessages(
        channelId: event.channelId,
        page: nextPage,
      );

      emit(
        current.copyWith(
          messages: [...current.messages, ...messages],
          isLoading: false,
          hasMore: messages.length >= 50,
          page: nextPage,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoading: false));
    }
  }

  // ═════════════════════════════════════════════
  // SEND — TEXT
  // ═════════════════════════════════════════════
  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    final optimistic = ChatMessage(
      name: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      channelId: event.channelId,
      owner: 'me',
      senderName: 'Me',
      senderRole: '',
      senderRoleLabel: '',
      isMe: true,
      isAdmin: false,
      sender: MessageSender.fromLegacy(owner: 'me', isMe: true),
      text: event.text,
      creation: DateTime.now(),
      modified: DateTime.now(),
      sendStatus: MessageSendStatus.sending,
    );

    emit(current.copyWith(messages: [...current.messages, optimistic]));

    try {
      final sent = await repository.sendMessage(
        channelId: event.channelId,
        text: event.text,
      );

      if (state is! ChannelOpen) return;
      final latest = state as ChannelOpen;

      final updated = latest.messages.map((m) {
        if (m.name == optimistic.name) {
          return sent.copyWith(sendStatus: MessageSendStatus.sent);
        }
        return m;
      }).toList();

      emit(latest.copyWith(messages: updated));

      // Kick a poll immediately so we pull anything we missed
      _pollNewMessages(event.channelId);
    } catch (e) {
      if (state is! ChannelOpen) return;
      final latest = state as ChannelOpen;

      final failed = latest.messages.map((m) {
        if (m.name == optimistic.name) {
          return m.copyWith(sendStatus: MessageSendStatus.failed);
        }
        return m;
      }).toList();
      emit(latest.copyWith(messages: failed));
    }
  }

  // ═════════════════════════════════════════════
  // SEND — ATTACHMENT (image / file)
  // ═════════════════════════════════════════════
  Future<void> _onSendAttachment(
    SendAttachment event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final isImage = _isImageFile(event.file.path);

    // Optimistic bubble — shows local file + 0% progress
    final optimistic = ChatMessage(
      name: tempId,
      channelId: event.channelId,
      owner: 'me',
      senderName: 'Me',
      senderRole: '',
      senderRoleLabel: '',
      isMe: true,
      isAdmin: false,
      sender: MessageSender.fromLegacy(owner: 'me', isMe: true),
      text: event.text,
      messageType: isImage ? 'Image' : 'File',
      file: event.file.path, // local path until uploaded
      fileName: event.file.path.split(Platform.pathSeparator).last,
      creation: DateTime.now(),
      modified: DateTime.now(),
      sendStatus: MessageSendStatus.sending,
      uploadProgress: 0,
    );

    emit(current.copyWith(messages: [...current.messages, optimistic]));

    try {
      // ── Step 1: upload ───────────────────────────────
      final upload = await repository.uploadAttachment(
        channelId: event.channelId,
        file: event.file,
        onProgress: (sent, total) {
          if (total > 0) {
            add(UploadProgressChanged(tempId: tempId, progress: sent / total));
          }
        },
      );

      // ── Step 2: send message referencing the file ────
      final sent = await repository.sendAttachmentMessage(
        channelId: event.channelId,
        attachment: upload,
        text: event.text,
      );

      if (state is! ChannelOpen) return;
      final latest = state as ChannelOpen;

      final updated = latest.messages.map((m) {
        if (m.name == tempId) {
          return sent.copyWith(sendStatus: MessageSendStatus.sent);
        }
        return m;
      }).toList();

      emit(latest.copyWith(messages: updated));

      // Pull anything else we may have missed
      _pollNewMessages(event.channelId);
    } catch (e) {
      if (state is! ChannelOpen) return;
      final latest = state as ChannelOpen;

      final failed = latest.messages.map((m) {
        if (m.name == tempId) {
          return m.copyWith(sendStatus: MessageSendStatus.failed);
        }
        return m;
      }).toList();

      emit(latest.copyWith(messages: failed));
    }
  }

  void _onUploadProgress(UploadProgressChanged event, Emitter<ChatState> emit) {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    final updated = current.messages.map((m) {
      if (m.name == event.tempId) {
        return m.copyWith(uploadProgress: event.progress);
      }
      return m;
    }).toList();

    emit(current.copyWith(messages: updated));
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  // ═════════════════════════════════════════════
  // SOCKET INCOMING
  // ═════════════════════════════════════════════
  void _onIncomingMessage(IncomingMessage event, Emitter<ChatState> emit) {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    final payload = event.payload;
    final channelId = payload['channel_id'] ?? payload['raven_channel'] ?? '';
    if (channelId != current.channelId) return;

    final message = ChatMessage.fromJson(payload);

    // If this echoes our optimistic message, replace it (upload finished
    // server-side and now has a real `name` + `file_url`).
    final byOwner = message.isMe
        ? current.messages.firstWhere(
            (m) =>
                m.isMe && m.name.startsWith('temp_') && m.text == message.text,
            orElse: () => message,
          )
        : message;

    if (byOwner.name != message.name &&
        current.messages.any((m) => m.name == byOwner.name)) {
      final updated = current.messages.map((m) {
        if (m.name == byOwner.name) {
          return message.copyWith(sendStatus: MessageSendStatus.sent);
        }
        return m;
      }).toList();
      emit(current.copyWith(messages: updated));
      return;
    }

    final exists = current.messages.any((m) => m.name == message.name);
    if (!exists) {
      emit(current.copyWith(messages: [...current.messages, message]));
    }
  }

  // ═════════════════════════════════════════════
  // CLEANUP
  // ═════════════════════════════════════════════
  @override
  Future<void> close() {
    _stopPolling();
    _socketSub?.cancel();
    return super.close();
  }
}
