import 'package:flutter/material.dart';

class ThemeOption extends StatelessWidget {
  final ThemeMode value;
  final ThemeMode groupValue;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onChanged;
  final bool showDivider;

  const ThemeOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.onChanged,
    this.subtitle,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        RadioListTile<ThemeMode>(
          value: value,
          groupValue: groupValue,
          onChanged: (_) => onChanged(),

          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          subtitle: subtitle == null ? null : Text(subtitle!),

          secondary: Icon(
            icon,
            color: colors.primary,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
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