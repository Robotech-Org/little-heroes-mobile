import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/network/socket/socket_service.dart';

import '../../data/models/chat_models.dart';
import '../../domain/repositories/chat_repository.dart';

// ============ EVENTS ============
abstract class ChatEvent {}

class LoadChannels extends ChatEvent {}

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

class IncomingMessage extends ChatEvent {
  final Map<String, dynamic> payload;
  IncomingMessage(this.payload);
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
    on<IncomingMessage>(_onIncomingMessage);

    // Live updates from Socket.IO (when the backend supports it)
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
    emit(ChannelsLoading());
    try {
      final channels = await repository.listMyChannels();
      emit(ChannelsLoaded(channels));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ═════════════════════════════════════════════
  // OPEN / CLOSE CHANNEL
  // ═════════════════════════════════════════════
  Future<void> _onOpenChannel(
    OpenChannel event,
    Emitter<ChatState> emit,
  ) async {
    _activeChannelId = event.channelId;

    // Best-effort socket (won't block if server rejects)
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

      // Poll for new messages every 3 s (socket fallback)
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

  /// Fetch the newest page and append any messages we don't already have.
  Future<void> _pollNewMessages(String channelId) async {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    // Only poll the channel we're actually viewing
    if (current.channelId != channelId) return;

    try {
      final latest = await repository.getChannelMessages(
        channelId: channelId,
        page: 1,
      );

      // Merge: keep only messages whose `name` isn't already in the list
      final existingNames = current.messages.map((m) => m.name).toSet();
      final fresh = latest
          .where((m) => !existingNames.contains(m.name))
          .toList();

      if (fresh.isEmpty) return;
      if (state is! ChannelOpen)
        return; // channel may have changed during await

      // Re-read state because it may have changed during the await
      final now = state as ChannelOpen;
      if (now.channelId != channelId) return;

      // Merge again in case a socket event added messages meanwhile
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
  // SEND
  // ═════════════════════════════════════════════
  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    // Optimistic UI
    final optimistic = ChatMessage(
      name: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      owner: 'me',
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

      // Immediately poll to pull any messages we missed while sending
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
  // SOCKET INCOMING
  // ═════════════════════════════════════════════
  void _onIncomingMessage(IncomingMessage event, Emitter<ChatState> emit) {
    if (state is! ChannelOpen) return;
    final current = state as ChannelOpen;

    final payload = event.payload;
    final channelId = payload['channel_id'] ?? payload['raven_channel'] ?? '';
    if (channelId != current.channelId) return;

    final message = ChatMessage.fromJson(payload);
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
