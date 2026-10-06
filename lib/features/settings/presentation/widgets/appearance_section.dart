import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';

import '../../../../core/theme/theme_cubit.dart';

class AppearanceSection extends StatelessWidget {
  final bool isDark;
  const AppearanceSection({super.key, required this.isDark});

  /// Dispatches to the correct method on your ThemeCubit.
  void _applyMode(BuildContext context, ThemeMode mode) {
    final cubit = context.read<ThemeCubit>();
    switch (mode) {
      case ThemeMode.light:
        cubit.setLightMode();
        break;
      case ThemeMode.dark:
        cubit.setDarkMode();
        break;
      case ThemeMode.system:
        cubit.setSystemMode();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // ✅ ThemeCubit's state IS the ThemeMode
    final mode = context.watch<ThemeCubit>().state;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          _AppearanceTile(
            colorScheme: colorScheme,
            icon: Icons.brightness_auto_outlined,
            label: 'System default',
            subtitle: 'Follow your device theme',
            value: ThemeMode.system,
            groupValue: mode,
            onChanged: (v) => _applyMode(context, v),
          ),
          Divider(height: 1, indent: 72, color: dividerColor),
          _AppearanceTile(
            colorScheme: colorScheme,
            icon: Icons.light_mode_outlined,
            label: 'Light',
            value: ThemeMode.light,
            groupValue: mode,
            onChanged: (v) => _applyMode(context, v),
          ),
          Divider(height: 1, indent: 72, color: dividerColor),
          _AppearanceTile(
            colorScheme: colorScheme,
            icon: Icons.dark_mode_outlined,
            label: 'Dark',
            value: ThemeMode.dark,
            groupValue: mode,
            onChanged: (v) => _applyMode(context, v),
          ),
        ],
      ),
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  final ColorScheme colorScheme;
  final IconData icon;
  final String label;
  final String? subtitle;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  const _AppearanceTile({
    required this.colorScheme,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;

    return ListTile(
      onTap: () => onChanged(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: selected
          ? Icon(Icons.radio_button_checked_rounded, color: colorScheme.primary)
          : Icon(
              Icons.radio_button_off_rounded,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
    );
  }
}
