import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/features/main/domain/entities/user_role.dart';

class HomeHeader extends StatelessWidget {
  final UserRole role;

  const HomeHeader({super.key, required this.role});

  String get roleName {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';

      case UserRole.parent:
        return 'Parent';

      case UserRole.advisor:
        return 'Advisor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ======================================================
          // PROFILE
          // ======================================================

          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.person_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // ======================================================
          // WELCOME
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good afternoon 👋',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Welcome back!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  roleName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // NOTIFICATIONS
          // ======================================================

          _HeaderButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              context.push(AppRoutes.notifications);
            },
          ),

          const SizedBox(width: 8),

          // ======================================================
          // SETTINGS
          // ======================================================

          _HeaderButton(
            icon: Icons.settings_outlined,
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// HEADER BUTTON
// ==================================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}