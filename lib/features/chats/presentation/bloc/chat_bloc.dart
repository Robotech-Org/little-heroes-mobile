// lib/features/chats/presentation/bloc/chat_bloc.dart

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
  String? _activeChannelId;

  ChatBloc({required this.repository, required this.socketService})
    : super(ChatInitial()) {
    on<LoadChannels>(_onLoadChannels);
    on<OpenChannel>(_onOpenChannel);
    on<CloseChannel>(_onCloseChannel);
    on<LoadMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendChatMessage);
    on<IncomingMessage>(_onIncomingMessage);

    // ✅ Live updates from Socket.IO
    _socketSub = socketService.onNewMessage.listen((payload) {
      add(IncomingMessage(payload));
    });
  }

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

  Future<void> _onOpenChannel(
    OpenChannel event,
    Emitter<ChatState> emit,
  ) async {
    _activeChannelId = event.channelId;

    await socketService.connect();
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
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onCloseChannel(CloseChannel event, Emitter<ChatState> emit) {
    if (_activeChannelId != null) {
      socketService.leaveChannel(_activeChannelId!);
      _activeChannelId = null;
    }
  }

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

      final updated = current.messages.map((m) {
        if (m.name == optimistic.name) {
          return sent.copyWith(sendStatus: MessageSendStatus.sent);
        }
        return m;
      }).toList();

      emit(current.copyWith(messages: updated));
    } catch (e) {
      final failed = current.messages.map((m) {
        if (m.name == optimistic.name) {
          return m.copyWith(sendStatus: MessageSendStatus.failed);
        }
        return m;
      }).toList();
      emit(current.copyWith(messages: failed));
    }
  }

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

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
  }
}
