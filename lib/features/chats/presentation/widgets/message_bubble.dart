import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_heroes_mobile/features/chats/data/models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const MessageBubble({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                message.owner,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: isMine ? Colors.white : colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.creation.toLocal()),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white70
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.sendStatus == MessageSendStatus.sending
                        ? Icons.access_time_rounded
                        : message.sendStatus == MessageSendStatus.failed
                        ? Icons.error_outline_rounded
                        : Icons.check_rounded,
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
