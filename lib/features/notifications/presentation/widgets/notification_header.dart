import 'package:flutter/material.dart';

class NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const NotificationHeader({
    super.key,
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Notifications',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          if (unreadCount > 0)
            TextButton(
              onPressed: onMarkAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
    );
  }
}
