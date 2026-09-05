import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';

import 'settings_section.dart';
import 'theme_option.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SettingsSection(
      title: 'Appearance',
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),

        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return Column(
              children: [
                ThemeOption(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  icon: Icons.settings_suggest_outlined,
                  title: 'System default',
                  subtitle: 'Follow your device theme',
                  onChanged: () {
                    context.read<ThemeCubit>().setSystemMode();
                  },
                ),

                ThemeOption(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  icon: Icons.light_mode_outlined,
                  title: 'Light',
                  onChanged: () {
                    context.read<ThemeCubit>().setLightMode();
                  },
                ),

                ThemeOption(
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
      ),
    );
  }
}
