
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Icon(
            icon,
            color: colors.primary,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!),
          trailing: const Icon(
            Icons.chevron_right_rounded,
          ),
          onTap: onTap,
        ),

        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: colors.outlineVariant.withOpacity(0.35),
          ),
      ],
    );
  }
}
