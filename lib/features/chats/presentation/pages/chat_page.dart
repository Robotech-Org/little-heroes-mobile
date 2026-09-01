
import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chats_page.dart';

import '../../data/datasources/chat_local_data_source.dart';
import '../../domain/entities/chat.dart';
import 'chat_page.dart';
import '../widgets/chat_search.dart';
import '../widgets/chat_list_tile.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatLocalDataSource _dataSource =
      const ChatLocalDataSource();

  final TextEditingController _searchController =
      TextEditingController();

  List<Chat> _chats = [];
  List<Chat> _filteredChats = [];

  bool _isLoading = true;

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
    });

    final chats = await _dataSource.getChats();

    if (!mounted) return;

    setState(() {
      _chats = chats;
      _filteredChats = chats;
      _isLoading = false;
    });
  }

  void _search(String query) {
    final value = query.trim().toLowerCase();

    setState(() {
      if (value.isEmpty) {
        _filteredChats = _chats;
      } else {
        _filteredChats = _chats.where((chat) {
          return chat.personName.toLowerCase().contains(value) ||
              chat.role.toLowerCase().contains(value) ||
              chat.lastMessage.toLowerCase().contains(value);
        }).toList();
      }
    });
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(chat: chat),
      ),
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
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      body: RefreshIndicator(
        onRefresh: _loadChats,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),

          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            24,
          ),

          children: [
            Text(
              'Stay connected',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Chat with parents, teachers and advisors.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            ChatSearch(
              controller: _searchController,
              onChanged: _search,
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Chats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredChats.length}',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_filteredChats.isEmpty)
              _EmptyChats()
            else
              ..._filteredChats.map(
                (chat) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChatListTile(
                    chat: chat,
                    onTap: () => _openChat(chat),
                  ),
                ),
              ),
          ],
        ),
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
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try searching for another person.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
