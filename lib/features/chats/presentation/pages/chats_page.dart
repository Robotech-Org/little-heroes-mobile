import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_detail_page.dart';
import '../widgets/chat_search.dart';
import '../widgets/chat_list_tile.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Chat> _chats = [];
  List<Chat> _filteredChats = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isRefreshing = false;
  String _errorMessage = '';

  // Cache
  List<Chat>? _cachedChats;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChats({bool useCache = true}) async {
    // Check cache
    if (useCache && _cachedChats != null && _lastCacheTime != null) {
      final cacheAge = DateTime.now().difference(_lastCacheTime!);
      if (cacheAge < _cacheDuration) {
        setState(() {
          _chats = _cachedChats!;
          _filteredChats = _cachedChats!;
          _isLoading = false;
          _isError = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = _cachedChats == null;
      _isRefreshing = _cachedChats != null;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Please login to view messages';
        });
        return;
      }

      final role = authState.user.role;
      final repository = di.sl<ChatRepository>();

      List<Chat> chatList = [];

      if (role == UserRole.teacher) {
        // Teacher fetches parents - parents have full_name
        final response = await repository.getParents(page: 1, pageSize: 100);
        chatList = response.items.map((participant) {
          return Chat.fromParticipant({
            'name': participant.name,
            'full_name': participant.fullName,
            'relationship_type': participant.relationshipType ?? 'Parent',
          }, 'Parent');
        }).toList();
      } else if (role == UserRole.parent) {
        // Parent fetches teachers - teachers have first_name and last_name
        final response = await repository.getTeachers(page: 1, pageSize: 100);
        chatList = response.items.map((participant) {
          // Build full name from first and last name
          final fullName =
              '${participant.teacherFirstName ?? ''} ${participant.teacherLastName ?? ''}'
                  .trim();
          // If no first/last name, use the name field
          final displayName = fullName.isNotEmpty
              ? fullName
              : participant.fullName;
          return Chat.fromParticipant({
            'name': participant.name,
            'full_name': displayName,
          }, 'Teacher');
        }).toList();
      } else if (role == UserRole.adviser) {
        // Adviser fetches both parents and teachers
        final parentsResponse = await repository.getParents(
          page: 1,
          pageSize: 100,
        );
        final teachersResponse = await repository.getTeachers(
          page: 1,
          pageSize: 100,
        );

        final parents = parentsResponse.items.map((participant) {
          return Chat.fromParticipant({
            'name': participant.name,
            'full_name': participant.fullName,
            'relationship_type': participant.relationshipType ?? 'Parent',
          }, 'Parent');
        }).toList();

        final teachers = teachersResponse.items.map((participant) {
          // Build full name from first and last name
          final fullName =
              '${participant.teacherFirstName ?? ''} ${participant.teacherLastName ?? ''}'
                  .trim();
          final displayName = fullName.isNotEmpty
              ? fullName
              : participant.fullName;
          return Chat.fromParticipant({
            'name': participant.name,
            'full_name': displayName,
          }, 'Teacher');
        }).toList();

        chatList = [...parents, ...teachers];
      }

      // Sort chats by name
      chatList.sort((a, b) => a.personName.compareTo(b.personName));

      setState(() {
        _chats = chatList;
        _filteredChats = chatList;
        _cachedChats = chatList;
        _lastCacheTime = DateTime.now();
        _isLoading = false;
        _isRefreshing = false;
        _isError = false;
      });
    } catch (e) {
      // Use cached data if available
      if (_cachedChats != null) {
        setState(() {
          _chats = _cachedChats!;
          _filteredChats = _cachedChats!;
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _search(String query) {
    final value = query.trim().toLowerCase();

    setState(() {
      if (value.isEmpty) {
        _filteredChats = _chats;
      } else {
        _filteredChats = _chats.where((chat) {
          return chat.personName.toLowerCase().contains(value) ||
              chat.role.toLowerCase().contains(value);
        }).toList();
      }
    });
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailPage(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadChats(useCache: false),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadChats(useCache: false),
        child: _buildContent(theme, colors),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colors) {
    if (_isLoading) {
      return _buildSkeletonLoading(theme, colors);
    }

    if (_isError) {
      return _buildErrorWidget(theme, colors);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(18, 1, 18, 2),
      children: [
        const SizedBox(height: 18),
        ChatSearch(controller: _searchController, onChanged: _search),
        const SizedBox(height: 18),

        // Stats + Last Updated
        // _buildStats(theme, colors),
        if (_filteredChats.isEmpty)
          const _EmptyChats()
        else
          ..._filteredChats.map(
            (chat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChatListTile(chat: chat, onTap: () => _openChat(chat)),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredChats.length} contacts',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_lastCacheTime != null)
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_formatTime(_lastCacheTime!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  // ============================================================
  // SKELETON LOADING
  // ============================================================

  Widget _buildSkeletonLoading(ThemeData theme, ColorScheme colors) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 1, 18, 2),
      children: [
        const SizedBox(height: 18),
        // Search bar skeleton
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        // Stats skeleton
        _buildSkeletonLine(width: 120, height: 14),
        const SizedBox(height: 12),
        // Chat list skeletons
        ...List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                // Avatar skeleton
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: 140, height: 16),
                      const SizedBox(height: 4),
                      _buildSkeletonLine(width: 80, height: 12),
                    ],
                  ),
                ),
                _buildSkeletonLine(width: 24, height: 24),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSkeletonLine({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 50, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _loadChats(useCache: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY CHATS
// ============================================================

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations found',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a conversation with your contacts.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
