import 'package:flutter/material.dart';

import '../../domain/entities/chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              // ==
              // AVATAR
              // ==

              _ChatAvatar(name: chat.personName),

              const SizedBox(width: 13),

              // ==
              // CHAT INFORMATION
              // ==
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.personName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _chatTime(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      chat.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ==
              // ARROW
              // ==
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _chatTime() {
    // Replace this later with chat.updatedAt / timestamp
    // when your Chat entity contains a real timestamp.
    return 'Now';
  }
}


// CHAT AVATAR


class _ChatAvatar extends StatelessWidget {
  final String name;

  const _ChatAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return '?';
    }

    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
