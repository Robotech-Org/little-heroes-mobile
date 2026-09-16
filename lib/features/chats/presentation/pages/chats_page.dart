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
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChannels());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChannelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChannelsLoaded) {
            if (state.channels.isEmpty) {
              return const Center(child: Text('No conversations yet'));
            }

            //   Sort by last message time (newest first)
            final sorted = List<ChatChannel>.from(state.channels)
              ..sort((a, b) {
                final aT = a.lastMessageTime ?? DateTime(1970);
                final bT = b.lastMessageTime ?? DateTime(1970);
                return bT.compareTo(aT);
              });

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ChatBloc>().add(LoadChannels()),
              child: ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: theme.dividerColor.withOpacity(0.08),
                ),
                itemBuilder: (context, i) {
                  final channel = sorted[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 26,
                      child: Text(_initials(channel.studentName)),
                    ),
                    title: Text(
                      channel.studentName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      channel.lastMessagePreview ?? channel.classroom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatRelative(channel.lastMessageTime),
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => di.sl<ChatBloc>(),
                            child: ChatRoomScreen(
                              channelId: channel.ravenChannel,
                              title: channel.studentName,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatRelative(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}
