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
  String _errorMessage = '';

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

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
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

      setState(() {
        _chats = chatList;
        _filteredChats = chatList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
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
            onPressed: _loadChats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadChats,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 1, 18, 2),
          children: [
            const SizedBox(height: 18),
            ChatSearch(controller: _searchController, onChanged: _search),

            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_isError)
              _buildErrorWidget(theme, colors)
            else if (_filteredChats.isEmpty)
              _EmptyChats()
            else
              ..._filteredChats.map(
                (chat) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChatListTile(chat: chat, onTap: () => _openChat(chat)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 50, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load messages',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
            onPressed: _loadChats,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
