import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/services/chat_cache_service.dart';
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

  List<ChatChannel> _cachedChannels = [];
  bool _isOffline = false;
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();

    final cached = ChatCacheService.instance.load();
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _cachedChannels = cached;
        _cachedAt = ChatCacheService.instance.lastUpdated();
      });
    }

    context.read<ChatBloc>().add(LoadChannels());

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
        final preview = _stripHtml(c.lastMessagePreview).toLowerCase();
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
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
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _buildSearchBar(theme),
          ),

          // ── List ──
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChannelsLoaded) {
                  ChatCacheService.instance.save(state.channels);
                  if (_isOffline) {
                    setState(() {
                      _isOffline = false;
                      _cachedAt = DateTime.now();
                    });
                  }
                } else if (state is ChatError) {
                  if (_cachedChannels.isNotEmpty) {
                    setState(() => _isOffline = true);
                  }
                }
              },
              builder: (context, state) {
                List<ChatChannel>? channelsToShow;
                bool showSkeleton = false;

                if (state is ChannelsLoaded && state.channels.isNotEmpty) {
                  channelsToShow = state.channels;
                } else if (_cachedChannels.isNotEmpty) {
                  channelsToShow = _cachedChannels;
                } else if (state is ChannelsLoading || state is ChatInitial) {
                  showSkeleton = true;
                } else if (state is ChatError) {
                  return _buildError(theme, state.message);
                }

                if (showSkeleton) {
                  return const _ChatsSkeleton();
                }

                if (channelsToShow == null || channelsToShow.isEmpty) {
                  return _buildEmpty(theme);
                }

                final visible = _filterAndSort(channelsToShow);

                if (visible.isEmpty && _searchQuery.isNotEmpty) {
                  return _buildNoSearchResults(theme);
                }

                return Column(
                  children: [
                    if (_isOffline)
                      _OfflineBanner(
                        cachedAt: _cachedAt,
                        onRetry: () =>
                            context.read<ChatBloc>().add(LoadChannels()),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<ChatBloc>().add(LoadChannels());
                          await Future.delayed(
                            const Duration(milliseconds: 600),
                          );
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: visible.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ChatCard(
                              channel: visible[i],
                              theme: theme,
                              isDark: isDark,
                              onTap: () => _openChannel(visible[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openChannel(ChatChannel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<ChatBloc>(),
          child: ChatRoomScreen(
            channelId: channel.ravenChannel,
            title: channel.displayTitle,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<ChatBloc>().add(LoadChannels(silent: true));
      }
    });
  }

  // ═════════════════════════════════════════════
  // Search bar
  // ═════════════════════════════════════════════
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

  // ═════════════════════════════════════════════
  // HTML stripping
  // ═════════════════════════════════════════════
  String _stripHtml(String? input) {
    if (input == null || input.isEmpty) return '';
    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  // ═════════════════════════════════════════════
  // Empty / search / error states
  // ═════════════════════════════════════════════
  Widget _buildEmpty(ThemeData theme) {
    final colors = theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
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
        ),
      ],
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
}

// ═══════════════════════════════════════════════════════════
// CHAT CARD — modern, card-based UI
// ═══════════════════════════════════════════════════════════
class _ChatCard extends StatelessWidget {
  final ChatChannel channel;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const _ChatCard({
    required this.channel,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  String get _initials {
    final name = channel.studentName;
    if (name == null || name.isEmpty) return '?';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get _preview {
    final raw = channel.lastMessagePreview;
    if (raw != null && raw.trim().isNotEmpty) {
      return _strip(raw);
    }
    return channel.displaySubtitle;
  }

  static String _strip(String input) {
    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
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

  @override
  Widget build(BuildContext context) {
    final isAdmin = channel.isAdmin;
    final isPinned = channel.isPinned == true;

    // Role/type based avatar color
    final avatarColor = isAdmin
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    // Border highlights pinned channels
    final borderColor = isPinned
        ? avatarColor.withValues(alpha: 0.35)
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isPinned ? 1.5 : 1),
          ),
          child: Row(
            children: [
              // ── Avatar with status indicator ──
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          avatarColor,
                          avatarColor.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isAdmin
                        ? const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 26,
                          )
                        : Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  // Pin badge (top-right)
                  if (isPinned)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.push_pin_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // ── Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: title + timestamp
                    Row(
                      children: [
                        if (isAdmin) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.tertiary,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            channel.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isPinned
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRelative(
                            channel.lastMessageTime ?? channel.creationTime,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Row 2: preview text
                    Text(
                      _preview.isEmpty ? 'No messages yet' : _preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Chevron ──
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// SKELETON — matches the new card layout
// ═════════════════════════════════════════════
class _ChatsSkeleton extends StatelessWidget {
  const _ChatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.colorScheme.surfaceContainerHighest;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ChatCardSkeleton(
          baseColor: baseColor,
          delay: i,
          cardColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
    );
  }
}

class _ChatCardSkeleton extends StatelessWidget {
  final Color baseColor;
  final int delay;
  final Color cardColor;
  final Color borderColor;

  const _ChatCardSkeleton({
    required this.baseColor,
    required this.delay,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - delay * 0.08).clamp(0.4, 1.0);

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _bar(
                          width: 140.0 + ((delay * 17) % 60),
                          height: 15,
                          color: baseColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _bar(
                        width: 28,
                        height: 11,
                        color: baseColor.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _bar(
                    width: double.infinity,
                    height: 12,
                    color: baseColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 6),
                  _bar(
                    width: 120.0 + ((delay * 11) % 80),
                    height: 12,
                    color: baseColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// OFFLINE BANNER
// ═════════════════════════════════════════════
class _OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final VoidCallback onRetry;

  const _OfflineBanner({required this.cachedAt, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.orange.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cachedAt != null
                    ? 'Offline — showing cached messages (${_fmtAgo(cachedAt!)})'
                    : 'Offline — showing cached messages',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
