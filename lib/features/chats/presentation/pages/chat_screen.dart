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

  late final ChatBloc _bloc;

  /// Name of the newest message we've already auto-scrolled for.
  /// Used so pagination / loading older messages doesn't jump the view.
  String? _lastNewestMessageName;

  /// Whether to show the "jump to latest" FAB.
  bool _showJumpToLatest = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ChatBloc>();
    _bloc.add(OpenChannel(widget.channelId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Use the saved reference, not context (context is unsafe here).
    _bloc.add(CloseChannel());
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════
  // Scroll handling
  // ═════════════════════════════════════════════
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final atBottom = _scrollController.position.pixels <= 50;
    if (_showJumpToLatest == atBottom) {
      setState(() => _showJumpToLatest = !atBottom);
    }

    // Reverse list: maxScrollExtent is toward older messages.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _bloc.add(LoadMessages(channelId: widget.channelId, loadMore: true));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  // ═════════════════════════════════════════════
  // Send
  // ═════════════════════════════════════════════
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _bloc.add(SendChatMessage(channelId: widget.channelId, text: text));
    _controller.clear();
    _scrollToBottom();
  }

  // ═════════════════════════════════════════════
  // Sorting + dedup
  // ═════════════════════════════════════════════
  List<ChatMessage> _sorted(List<ChatMessage> messages) {
    final seen = <String>{};
    final unique = <ChatMessage>[];
    for (final m in messages) {
      if (seen.add(m.name)) unique.add(m);
    }
    unique.sort((a, b) => a.creation.compareTo(b.creation));
    return unique;
  }

  // ═════════════════════════════════════════════
  // Build
  // ═════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is! ChannelOpen) return;
          final sorted = _sorted(state.messages);
          if (sorted.isEmpty) return;

          final newestName = sorted.last.name;
          if (newestName != _lastNewestMessageName) {
            _lastNewestMessageName = newestName;
            _scrollToBottom();
          }
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
                      // reverse:true → index 0 is the bottom-most item,
                      // so pull from the end of the sorted list.
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
      floatingActionButton: _showJumpToLatest
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              tooltip: 'Jump to latest',
              child: const Icon(Icons.arrow_downward_rounded),
            )
          : null,
    );
  }

  // ═════════════════════════════════════════════
  // Input bar
  // ═════════════════════════════════════════════
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
              minLines: 1,
              maxLines: 5,
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
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }
}
