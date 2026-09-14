import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/chat_models.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final String channelId;
  final String title;

  const ChatRoomScreen({
    super.key,
    required this.channelId,
    required this.title,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(OpenChannel(widget.channelId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    context.read<ChatBloc>().add(CloseChannel());
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      context.read<ChatBloc>().add(
        LoadMessages(channelId: widget.channelId, loadMore: true),
      );
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
      SendChatMessage(channelId: widget.channelId, text: text),
    );
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<ChatMessage> _sorted(List<ChatMessage> messages) {
    final copy = List<ChatMessage>.from(messages);
    copy.sort((a, b) => a.creation.compareTo(b.creation));
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChannelOpen) _scrollToBottom();
        },
        builder: (context, state) {
          if (state is! ChannelOpen) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = _sorted(state.messages);

          return Column(
            children: [
              if (state.isLoading && messages.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[messages.length - 1 - i];
                      return MessageBubble(
                        message: msg,
                        isMine: msg.owner == 'me',
                      );
                    },
                  ),
                ),
              _buildInput(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}
