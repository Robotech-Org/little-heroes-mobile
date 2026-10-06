// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:little_heroes_mobile/injection_container.dart' as di;

// import '../../data/models/chat_models.dart';
// import '../bloc/chat_bloc.dart';
// import 'chat_screen.dart';

// class ChatsPage extends StatefulWidget {
//   const ChatsPage({super.key});

//   @override
//   State<ChatsPage> createState() => _ChatsPageState();
// }

// class _ChatsPageState extends State<ChatsPage> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _pollTimer;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();

//     context.read<ChatBloc>().add(LoadChannels());

//     // Auto-refresh the list every 5 s without flicker.
//     _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
//       if (!mounted) return;
//       context.read<ChatBloc>().add(LoadChannels(silent: true));
//     });
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ═════════════════════════════════════════════
//   // Search
//   // ═════════════════════════════════════════════
//   void _onSearchChanged(String value) {
//     setState(() => _searchQuery = value.trim().toLowerCase());
//   }

//   void _clearSearch() {
//     _searchController.clear();
//     setState(() => _searchQuery = '');
//   }

//   List<ChatChannel> _filterAndSort(List<ChatChannel> channels) {
//     var list = channels;

//     if (_searchQuery.isNotEmpty) {
//       list = channels.where((c) {
//         final name = (c.studentName ?? '').toLowerCase();
//         final room = (c.classroom ?? '').toLowerCase();
//         final preview = _stripHtml(c.lastMessagePreview).toLowerCase();
//         final title = (c.title ?? '').toLowerCase();
//         final subtitle = (c.subtitle ?? '').toLowerCase();
//         return name.contains(_searchQuery) ||
//             room.contains(_searchQuery) ||
//             preview.contains(_searchQuery) ||
//             title.contains(_searchQuery) ||
//             subtitle.contains(_searchQuery);
//       }).toList();
//     }

//     final sorted = List<ChatChannel>.from(list)
//       ..sort((a, b) {
//         // Pinned first
//         final ap = (a.isPinned == true) ? 1 : 0;
//         final bp = (b.isPinned == true) ? 1 : 0;
//         if (ap != bp) return bp.compareTo(ap);

//         final at = a.lastMessageTime ?? a.creationTime ?? DateTime(1970);
//         final bt = b.lastMessageTime ?? b.creationTime ?? DateTime(1970);
//         return bt.compareTo(at);
//       });
//     return sorted;
//   }

//   // ═════════════════════════════════════════════
//   // Build
//   // ═════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: theme.scaffoldBackgroundColor,
//         surfaceTintColor: Colors.transparent,
//         title: const Text(
//           'Messages',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Refresh',
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: () => context.read<ChatBloc>().add(LoadChannels()),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//             child: _buildSearchBar(theme),
//           ),
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is ChannelsLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (state is ChannelsLoaded) {
//                   if (state.channels.isEmpty) {
//                     return _buildEmpty(theme);
//                   }

//                   final visible = _filterAndSort(state.channels);

//                   if (visible.isEmpty && _searchQuery.isNotEmpty) {
//                     return _buildNoSearchResults(theme);
//                   }

//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       context.read<ChatBloc>().add(LoadChannels());
//                       await Future.delayed(const Duration(milliseconds: 600));
//                     },
//                     child: ListView.separated(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: visible.length,
//                       separatorBuilder: (_, __) => Divider(
//                         height: 1,
//                         indent: 80,
//                         color: theme.dividerColor.withValues(alpha: 0.08),
//                       ),
//                       itemBuilder: (_, i) => _channelTile(theme, visible[i]),
//                     ),
//                   );
//                 }

//                 if (state is ChatError) {
//                   return _buildError(theme, state.message);
//                 }

//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════
//   // Channel tile
//   // ═════════════════════════════════════════════
//   Widget _channelTile(ThemeData theme, ChatChannel channel) {
//     final isAdmin = channel.isAdmin;
//     final titleText = channel.displayTitle;

//     //    Prefer the API preview (stripped of HTML), fall back to displaySubtitle
//     final rawPreview = channel.lastMessagePreview;
//     final subtitleText = (rawPreview != null && rawPreview.trim().isNotEmpty)
//         ? _stripHtml(rawPreview)
//         : channel.displaySubtitle;

//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       leading: CircleAvatar(
//         radius: 26,
//         backgroundColor: isAdmin
//             ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.7)
//             : theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
//         child: isAdmin
//             ? Icon(
//                 Icons.support_agent_rounded,
//                 color: theme.colorScheme.onSecondaryContainer,
//                 size: 26,
//               )
//             : Text(
//                 _initials(channel.studentName),
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   color: theme.colorScheme.onPrimaryContainer,
//                 ),
//               ),
//       ),
//       title: Row(
//         children: [
//           if (channel.isPinned == true) ...[
//             Icon(
//               Icons.push_pin_rounded,
//               size: 14,
//               color: theme.colorScheme.primary,
//             ),
//             const SizedBox(width: 4),
//           ],
//           Expanded(
//             child: Text(
//               titleText,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//       subtitle: subtitleText.isEmpty
//           ? null
//           : Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis),
//       trailing: Text(
//         _formatRelative(channel.lastMessageTime ?? channel.creationTime),
//         style: theme.textTheme.bodySmall?.copyWith(
//           color: theme.colorScheme.onSurfaceVariant,
//         ),
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => BlocProvider(
//               create: (_) => di.sl<ChatBloc>(),
//               child: ChatRoomScreen(
//                 channelId: channel.ravenChannel,
//                 title: titleText,
//               ),
//             ),
//           ),
//         ).then((_) {
//           if (mounted) {
//             context.read<ChatBloc>().add(LoadChannels(silent: true));
//           }
//         });
//       },
//     );
//   }

//   // ═════════════════════════════════════════════
//   // Search bar
//   // ═════════════════════════════════════════════
//   Widget _buildSearchBar(ThemeData theme) {
//     final colors = theme.colorScheme;
//     return TextField(
//       controller: _searchController,
//       onChanged: _onSearchChanged,
//       textInputAction: TextInputAction.search,
//       decoration: InputDecoration(
//         hintText: 'Search conversations...',
//         prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
//         suffixIcon: _searchController.text.isNotEmpty
//             ? IconButton(
//                 icon: Icon(Icons.clear_rounded, color: colors.onSurfaceVariant),
//                 onPressed: _clearSearch,
//               )
//             : null,
//         filled: true,
//         fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 4),
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════
//   // HTML stripping
//   // ═════════════════════════════════════════════
//   /// Strips HTML tags for preview text (list view).
//   String _stripHtml(String? input) {
//     if (input == null || input.isEmpty) return '';
//     return input
//         .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
//         .replaceAll(RegExp(r'<[^>]+>'), '')
//         .replaceAll('&nbsp;', ' ')
//         .replaceAll('&amp;', '&')
//         .replaceAll('&lt;', '<')
//         .replaceAll('&gt;', '>')
//         .replaceAll('&quot;', '"')
//         .replaceAll('&#39;', "'")
//         .trim();
//   }

//   // ═════════════════════════════════════════════
//   // Empty / search / error states
//   // ═════════════════════════════════════════════
//   Widget _buildEmpty(ThemeData theme) {
//     final colors = theme.colorScheme;
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: colors.surfaceContainerHighest,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.forum_outlined,
//                 size: 34,
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No conversations yet',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your chats with teachers will appear here.',
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoSearchResults(ThemeData theme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off_rounded,
//               size: 48,
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'No matches for "$_searchQuery"',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             TextButton.icon(
//               onPressed: _clearSearch,
//               icon: const Icon(Icons.clear_rounded),
//               label: const Text('Clear search'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildError(ThemeData theme, String message) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               size: 48,
//               color: theme.colorScheme.error,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () => context.read<ChatBloc>().add(LoadChannels()),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════
//   // Helpers
//   // ═════════════════════════════════════════════
//   String _initials(String? name) {
//     if (name == null) return '?';

//     final parts = name
//         .trim()
//         .split(RegExp(r'\s+'))
//         .where((p) => p.isNotEmpty)
//         .toList();

//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) {
//       final p = parts.first;
//       return p.isNotEmpty ? p[0].toUpperCase() : '?';
//     }
//     return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   }

//   String _formatRelative(DateTime? time) {
//     if (time == null) return '';
//     final diff = DateTime.now().difference(time);
//     if (diff.isNegative || diff.inMinutes < 1) return 'now';
//     if (diff.inHours < 1) return '${diff.inMinutes}m';
//     if (diff.inDays < 1) return '${diff.inHours}h';
//     if (diff.inDays < 7) return '${diff.inDays}d';
//     return '${time.day}/${time.month}';
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// Cached channels shown before/without network.
  List<ChatChannel> _cachedChannels = [];
  bool _isOffline = false;
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Load cache immediately so the page has content while the API runs.
    final cached = ChatCacheService.instance.load();
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _cachedChannels = cached;
        _cachedAt = ChatCacheService.instance.lastUpdated();
      });
    }

    // 2️⃣ Kick off network fetch
    context.read<ChatBloc>().add(LoadChannels());

    // 3️⃣ Background refresh every 5s — skipped silently if we're offline.
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
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                // Persist fresh channels to cache & clear offline flag
                if (state is ChannelsLoaded) {
                  ChatCacheService.instance.save(state.channels);
                  if (_isOffline) {
                    setState(() {
                      _isOffline = false;
                      _cachedAt = DateTime.now();
                    });
                  }
                } else if (state is ChatError) {
                  // Network failed — if we have cached data, stay on it
                  if (_cachedChannels.isNotEmpty) {
                    setState(() => _isOffline = true);
                  }
                }
              },
              builder: (context, state) {
                // ── Choose which list to render ──
                List<ChatChannel>? channelsToShow;
                bool showSkeleton = false;

                if (state is ChannelsLoaded && state.channels.isNotEmpty) {
                  channelsToShow = state.channels;
                } else if (_cachedChannels.isNotEmpty) {
                  channelsToShow = _cachedChannels;
                } else if (state is ChannelsLoading || state is ChatInitial) {
                  // No cache + loading → skeleton
                  showSkeleton = true;
                } else if (state is ChatError) {
                  // No cache + error → error screen
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
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 80,
                            color: theme.dividerColor.withValues(alpha: 0.08),
                          ),
                          itemBuilder: (_, i) =>
                              _channelTile(theme, visible[i]),
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

  // ═════════════════════════════════════════════
  // Channel tile
  // ═════════════════════════════════════════════
  Widget _channelTile(ThemeData theme, ChatChannel channel) {
    final isAdmin = channel.isAdmin;
    final titleText = channel.displayTitle;

    final rawPreview = channel.lastMessagePreview;
    final subtitleText = (rawPreview != null && rawPreview.trim().isNotEmpty)
        ? _stripHtml(rawPreview)
        : channel.displaySubtitle;

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
                title: titleText,
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

  // ═════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════
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

// ═════════════════════════════════════════════
// SKELETON
// ═════════════════════════════════════════════
class _ChatsSkeleton extends StatelessWidget {
  const _ChatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: 8,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 80,
        color: theme.dividerColor.withValues(alpha: 0.08),
      ),
      itemBuilder: (_, i) => _ChatTileSkeleton(baseColor: baseColor, delay: i),
    );
  }
}

class _ChatTileSkeleton extends StatelessWidget {
  final Color baseColor;
  final int delay;

  const _ChatTileSkeleton({required this.baseColor, required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = (1.0 - delay * 0.08).clamp(0.4, 1.0);

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _bar(
                          width: 140.0 + ((delay * 17) % 60),
                          height: 14,
                          color: baseColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _bar(
                        width: 28,
                        height: 10,
                        color: baseColor.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _bar(
                    width: double.infinity,
                    height: 11,
                    color: baseColor.withValues(alpha: 0.7),
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
