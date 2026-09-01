import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/user_role.dart';

class SettingsPage extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onRoleChanged;

  const SettingsPage({
    super.key,
    required this.role,
    required this.onRoleChanged,
  });

  // ============================================================
  // ROLE NAME
  // ============================================================

  String _roleName(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';

      case UserRole.parent:
        return 'Parent';

      case UserRole.advisor:
        return 'Advisor';
    }
  }

  // ============================================================
  // ROLE ICON
  // ============================================================

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return Icons.school_outlined;

      case UserRole.parent:
        return Icons.family_restroom_outlined;

      case UserRole.advisor:
        return Icons.support_agent_outlined;
    }
  }

  // ============================================================
  // CHANGE ROLE DIALOG
  // ============================================================

  void _showRoleChanger(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Role',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Select the role you want to use.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 18),

                ...UserRole.values.map((item) {
                  final isSelected = item == role;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        child: Icon(
                          _roleIcon(item),
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        _roleName(item),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                            )
                          : const Icon(Icons.radio_button_unchecked_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);

                        if (item != role) {
                          onRoleChanged(item);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ======================================================
          // APPEARANCE
          // ======================================================

          Text(
            'Appearance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      title: const Text('System default'),
                      subtitle: const Text('Follow your device theme'),
                      secondary: const Icon(Icons.settings_suggest_outlined),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeCubit>().setSystemMode();
                        }
                      },
                    ),

                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      title: const Text('Light'),
                      secondary: const Icon(Icons.light_mode_outlined),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeCubit>().setLightMode();
                        }
                      },
                    ),

                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      title: const Text('Dark'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeCubit>().setDarkMode();
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ======================================================
          // ROLE
          // ======================================================
          Text(
            'Role',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),

              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  _roleIcon(role),
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              title: const Text(
                'Current Role',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),

              subtitle: Text(
                _roleName(role),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              trailing: FilledButton.tonal(
                onPressed: () {
                  _showRoleChanger(context);
                },
                child: const Text('Change'),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ======================================================
          // ACCOUNT
          // ======================================================
          Text(
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person_outline_rounded,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Profile'),
                  subtitle: const Text('Manage your profile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),

                ListTile(
                  leading: Icon(
                    Icons.lock_outline_rounded,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Security'),
                  subtitle: const Text('Password and security'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),

                ListTile(
                  leading: Icon(
                    Icons.notifications_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Notifications'),
                  subtitle: const Text('Notification preferences'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ======================================================
          // LOGOUT
          // ======================================================
          OutlinedButton.icon(
            onPressed: () {
              // TODO:
              // Logout through AuthBloc/AuthRepository.
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}
