import 'package:flutter/material.dart';

import 'navigation_item.dart';

class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onDestinationSelected;

  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.scaffoldBackgroundColor,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: NavigationBar(
            selectedIndex: currentIndex,

            onDestinationSelected: onDestinationSelected,

            backgroundColor: theme.colorScheme.surface,

            surfaceTintColor: Colors.transparent,

            shadowColor: theme.shadowColor,

            elevation: 0,

            indicatorColor: colorScheme.primaryContainer,

            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

            destinations: items.map((item) {
              return NavigationDestination(
                icon: Icon(item.icon, color: colorScheme.onSurfaceVariant),
                selectedIcon: Icon(
                  item.activeIcon,
                  color: colorScheme.onPrimaryContainer,
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
