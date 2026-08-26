import 'package:flutter/material.dart';

class AppEmpty extends StatelessWidget {
  final String message;
  final String? description;
  final IconData icon;

  final VoidCallback? onAction;
  final String? actionText;

  const AppEmpty({
    super.key,
    this.message = 'No data available.',
    this.description,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),

            if (description != null) ...[
              const SizedBox(height: 8),

              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 20),

              FilledButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}  

// how to use it
// AppEmpty(
//   message: 'No notifications',
//   description: 'You are all caught up.',
//   icon: Icons.notifications_none,
// )