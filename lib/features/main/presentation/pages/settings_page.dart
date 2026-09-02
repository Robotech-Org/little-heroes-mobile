
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/user_role.dart';
import '../widgets/role_selector_sheet.dart';
import '../widgets/settings_role_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onRoleChanged;

  const SettingsPage({
    super.key,
    required this.role,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        children: [
          // ==========================================================
          // APPEARANCE
          // ==========================================================

          SettingsSection(
            title: 'Appearance',
            child: _AppearanceSettings(),
          ),

          const SizedBox(height: 28),

          // ==========================================================
          // ROLE
          // ==========================================================

          SettingsSection(
            title: 'Role',
            child: SettingsRoleTile(
              role: role,
              onChange: () {
                RoleSelectorSheet.show(
                  context: context,
                  currentRole: role,
                  onRoleSelected: onRoleChanged,
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ==========================================================
          // ACCOUNT
          // ==========================================================

          SettingsSection(
            title: 'Account',
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  subtitle: 'Manage your profile',
                  onTap: () {},
                ),

                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Security',
                  subtitle: 'Password and security',
                  onTap: () {},
                ),

                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Notification preferences',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ==========================================================
          // LOGOUT
          // ==========================================================

          OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text(
              'Logout',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(
                color: colors.error,
              ),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOGOUT DIALOG
  // ================================================================

  void _showLogoutDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                // TODO:
                // Connect logout to your authentication system later.
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// APPEARANCE SETTINGS
// ============================================================================

class _AppearanceSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return Column(
            children: [
              _ThemeOption(
                value: ThemeMode.system,
                groupValue: themeMode,
                icon: Icons.settings_suggest_outlined,
                title: 'System default',
                subtitle: 'Follow your device theme',
                onChanged: () {
                  context.read<ThemeCubit>().setSystemMode();
                },
              ),

              _ThemeOption(
                value: ThemeMode.light,
                groupValue: themeMode,
                icon: Icons.light_mode_outlined,
                title: 'Light',
                onChanged: () {
                  context.read<ThemeCubit>().setLightMode();
                },
              ),

              _ThemeOption(
                value: ThemeMode.dark,
                groupValue: themeMode,
                icon: Icons.dark_mode_outlined,
                title: 'Dark',
                onChanged: () {
                  context.read<ThemeCubit>().setDarkMode();
                },
                showDivider: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// THEME OPTION
// ============================================================================

class _ThemeOption extends StatelessWidget {
  final ThemeMode value;
  final ThemeMode groupValue;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onChanged;
  final bool showDivider;

  const _ThemeOption({
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
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        RadioListTile<ThemeMode>(
          value: value,
          groupValue: groupValue,
          onChanged: (_) {
            onChanged();
          },
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!),
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
            color: colors.outlineVariant.withOpacity(0.35),
          ),
      ],
    );
  }
}