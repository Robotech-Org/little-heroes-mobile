import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _roleName(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';

      case UserRole.parent:
        return 'Parent';

      case UserRole.adviser:
        return 'Adviser';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserRole? role;

        if (state is AuthAuthenticated) {
          role = state.user.role;
        }

        final roleText = role != null ? _roleName(role) : 'User';

        return Container(
          padding: const EdgeInsets.fromLTRB(23, 20, 16, 18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.045),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==
              // PROFILE
              // ==

              Material(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    // You can open profile/settings here later.
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.person_rounded,
                      color: colors.onPrimaryContainer,
                      size: 25,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ==
              // WELCOME INFORMATION
              // ==
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good afternoon 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Welcome back!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    //
                    // ROLE CHIP
                    //
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          roleText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ==
              // NOTIFICATION BUTTON
              // ==
              _HeaderButton(
                icon: Icons.notifications_none_rounded,
                showBadge: true,
                onTap: () {
                  context.push(AppRoutes.notifications);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// HEADER BUTTON

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: colors.onSurfaceVariant, size: 22),
              ),

              // ==
              // NOTIFICATION BADGE
              // ==
              if (showBadge)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.surfaceContainerHighest,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
