import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  late final ChatBloc _bloc;

  /// Name of the newest message we've already auto-scrolled for.
  /// Used so pagination / loading older messages doesn't jump the view.
  String? _lastNewestMessageName;

  /// Whether to show the "jump to latest" FAB.
  bool _showJumpToLatest = false;

  /// Guard against double-taps opening two pickers at once.
  bool _isPickingAttachment = false;

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
  // Send — text
  // ═════════════════════════════════════════════
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _bloc.add(SendChatMessage(channelId: widget.channelId, text: text));
    _controller.clear();
    _scrollToBottom();
  }

  // ═════════════════════════════════════════════
  // Send — attachment
  // ═════════════════════════════════════════════
  void _showAttachmentSheet() {
    if (_isPickingAttachment) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Send attachment',
                style: Theme.of(sheetContext).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.image_outlined)),
              title: const Text('Photo'),
              subtitle: const Text('Pick an image from your gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.attach_file_rounded),
              ),
              title: const Text('File'),
              subtitle: const Text('Documents, PDFs, spreadsheets, etc.'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFile();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_isPickingAttachment) return;
    _isPickingAttachment = true;
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (picked == null) return;

      final text = _controller.text.trim();
      _controller.clear();

      _bloc.add(
        SendAttachment(
          channelId: widget.channelId,
          file: File(picked.path),
          text: text,
        ),
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
    } finally {
      _isPickingAttachment = false;
    }
  }

  Future<void> _pickFile() async {
    if (_isPickingAttachment) return;
    _isPickingAttachment = true;
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.isEmpty) return;

      final path = result.first.path;
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file path')),
        );
        return;
      }

      final text = _controller.text.trim();
      _controller.clear();

      _bloc.add(
        SendAttachment(
          channelId: widget.channelId,
          file: File(path),
          text: text,
        ),
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not pick file: $e')));
    } finally {
      _isPickingAttachment = false;
    }
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
          // ── Error state ───────────────────────────────
          if (state is ChatError) {
            return _buildError(theme, state.message, () {
              // Retry opening the channel
              _bloc.add(OpenChannel(widget.channelId));
            });
          }

          // ── Not yet open ──────────────────────────────
          if (state is! ChannelOpen) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = _sorted(state.messages);

          return Column(
            children: [
              Expanded(
                child: (state.isLoading && messages.isEmpty)
                    // First load in progress → spinner
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    //    Empty room → friendly hint, not blank
                    ? _buildEmptyRoom(theme)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final msg = messages[messages.length - 1 - i];
                          final mine = msg.isMe || msg.owner == 'me';
                          return MessageBubble(message: msg, isMine: mine);
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
  // Empty room
  // ═════════════════════════════════════════════
  Widget _buildEmptyRoom(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 34,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Say hello to start the conversation.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  // Error state
  // ═════════════════════════════════════════════
  Widget _buildError(ThemeData theme, String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load messages',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  // Input bar
  // ═════════════════════════════════════════════
  Widget _buildInput(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Attach button ────────────────────────────
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _showAttachmentSheet,
            tooltip: 'Attach',
            iconSize: 28,
          ),

          // ── Text field ───────────────────────────────
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

          // ── Send button ──────────────────────────────
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
