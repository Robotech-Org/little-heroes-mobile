import 'package:flutter/material.dart';

enum NotificationFilter { all, unread }

class NotificationFilterWidget extends StatelessWidget {
  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onChanged;

  const NotificationFilterWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          _FilterButton(
            title: 'All',
            selected: selected == NotificationFilter.all,
            onTap: () {
              onChanged(NotificationFilter.all);
            },
          ),

          const SizedBox(width: 10),

          _FilterButton(
            title: 'Unread',
            selected: selected == NotificationFilter.unread,
            onTap: () {
              onChanged(NotificationFilter.unread);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
