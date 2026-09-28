import 'package:flutter/material.dart';

class AttendanceActionBar extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const AttendanceActionBar({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: foreground, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: foreground.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
