import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
