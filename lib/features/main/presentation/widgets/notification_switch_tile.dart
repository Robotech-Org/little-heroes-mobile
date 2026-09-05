import 'package:flutter/material.dart';

class NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const NotificationSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),

          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.onPrimaryContainer, size: 20),
          ),

          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          trailing: Switch.adaptive(value: value, onChanged: onChanged),
        ),

        if (showDivider)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
