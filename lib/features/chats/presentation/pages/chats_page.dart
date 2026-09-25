import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import '../../data/models/chat_models.dart';
import '../bloc/chat_bloc.dart';
import 'chat_screen.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _pollTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(LoadChannels());

    // Auto-refresh the list every 5 s without flicker.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      context.read<ChatBloc>().add(LoadChannels(silent: true));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════
  // Search
  // ═════════════════════════════════════════════
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim().toLowerCase());
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<ChatChannel> _filterAndSort(List<ChatChannel> channels) {
    var list = channels;

    if (_searchQuery.isNotEmpty) {
      list = channels.where((c) {
        final name = (c.studentName ?? '').toLowerCase();
        final room = (c.classroom ?? '').toLowerCase();
        final preview = (c.lastMessagePreview ?? '').toLowerCase();
        final title = (c.title ?? '').toLowerCase();
        final subtitle = (c.subtitle ?? '').toLowerCase();
        return name.contains(_searchQuery) ||
            room.contains(_searchQuery) ||
            preview.contains(_searchQuery) ||
            title.contains(_searchQuery) ||
            subtitle.contains(_searchQuery);
      }).toList();
    }

    final sorted = List<ChatChannel>.from(list)
      ..sort((a, b) {
        // Pinned first
        final ap = (a.isPinned == true) ? 1 : 0;
        final bp = (b.isPinned == true) ? 1 : 0;
        if (ap != bp) return bp.compareTo(ap);

        final at = a.lastMessageTime ?? a.creationTime ?? DateTime(1970);
        final bt = b.lastMessageTime ?? b.creationTime ?? DateTime(1970);
        return bt.compareTo(at);
      });
    return sorted;
  }

  // ═════════════════════════════════════════════
  // Build
  // ═════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ChatBloc>().add(LoadChannels()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildSearchBar(theme),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChannelsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChannelsLoaded) {
                  if (state.channels.isEmpty) {
                    return _buildEmpty(theme);
                  }

                  final visible = _filterAndSort(state.channels);

                  if (visible.isEmpty && _searchQuery.isNotEmpty) {
                    return _buildNoSearchResults(theme);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ChatBloc>().add(LoadChannels());
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 80,
                        color: theme.dividerColor.withValues(alpha: 0.08),
                      ),
                      itemBuilder: (_, i) => _channelTile(theme, visible[i]),
                    ),
                  );
                }

                if (state is ChatError) {
                  return _buildError(theme, state.message);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelTile(ThemeData theme, ChatChannel channel) {
    final isAdmin = channel.isAdmin;
    final titleText = channel.displayTitle;
    final subtitleText = channel.displaySubtitle;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: isAdmin
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.7)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
        child: isAdmin
            ? Icon(
                Icons.support_agent_rounded,
                color: theme.colorScheme.onSecondaryContainer,
                size: 26,
              )
            : Text(
                _initials(channel.studentName),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
      ),
      title: Row(
        children: [
          if (channel.isPinned == true) ...[
            Icon(
              Icons.push_pin_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              titleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      subtitle: subtitleText.isEmpty
          ? null
          : Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        _formatRelative(channel.lastMessageTime ?? channel.creationTime),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => di.sl<ChatBloc>(),
              child: ChatRoomScreen(
                channelId: channel.ravenChannel,
                title: titleText, //  never null/empty
              ),
            ),
          ),
        ).then((_) {
          if (mounted) {
            context.read<ChatBloc>().add(LoadChannels(silent: true));
          }
        });
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final colors = theme.colorScheme;
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search conversations...',
        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: colors.onSurfaceVariant),
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final colors = theme.colorScheme;
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
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 34,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your chats with teachers will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No matches for "$_searchQuery"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, String message) {
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
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<ChatBloc>().add(LoadChannels()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null) return '?';

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.isNotEmpty ? p[0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatRelative(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.isNegative || diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}
