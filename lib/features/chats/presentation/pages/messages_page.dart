import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chats_page.dart';

import '../../data/datasources/chat_local_data_source.dart';
import '../../domain/entities/chat.dart';
import 'chat_page.dart';
import '../widgets/chat_search.dart';
import '../widgets/chat_tile.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatLocalDataSource _dataSource = const ChatLocalDataSource();

  final TextEditingController _searchController = TextEditingController();

  List<Chat> _allChats = [];
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

  // LOAD CHATS

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    final chats = await _dataSource.getChats();

    if (!mounted) {
      return;
    }

    setState(() {
      _allChats = chats;
      _filteredChats = chats;
      _isLoading = false;
    });
  }

  // SEARCH

  void _searchChats(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      setState(() {
        _filteredChats = _allChats;
      });

      return;
    }

    final results = _allChats.where((chat) {
      return chat.personName.toLowerCase().contains(value) ||
          chat.role.toLowerCase().contains(value) ||
          chat.lastMessage.toLowerCase().contains(value);
    }).toList();

    setState(() {
      _filteredChats = results;
    });
  }

  // OPEN CHAT

  void _openChat(Chat chat) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChatPage(chat: chat)));
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),

        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,

        elevation: 0,

        surfaceTintColor: Colors.transparent,
      ),

      body: RefreshIndicator(
        onRefresh: _loadChats,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),

          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

          children: [
            //
            // HEADER
            //

            Text(
              'Messages',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Stay connected with parents, teachers and advisors.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            //
            // SEARCH
            //
            ChatSearch(controller: _searchController, onChanged: _searchChats),

            const SizedBox(height: 22),

            //
            // TITLE
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Recent Conversations',

                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                if (_filteredChats.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      '${_filteredChats.length}',

                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            //
            // LOADING
            //
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),

                child: Center(child: CircularProgressIndicator()),
              )
            //
            // EMPTY
            //
            else if (_filteredChats.isEmpty)
              const _EmptyChats()
            //
            // CHAT LIST
            //
            else
              ..._filteredChats.map(
                (chat) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),

                  child: ChatTile(
                    chat: chat,

                    onTap: () {
                      _openChat(chat);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// EMPTY CHATS

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),

      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),

            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No conversations found',

            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try searching for another person.',

            textAlign: TextAlign.center,

            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
