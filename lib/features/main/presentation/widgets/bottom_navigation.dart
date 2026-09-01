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
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = currentIndex == index;

              return Expanded(
                child: _NavigationButton(
                  item: item,
                  selected: selected,
                  onTap: () {
                    onDestinationSelected(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NAVIGATION BUTTON
// ============================================================================

class _NavigationButton extends StatefulWidget {
  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },

      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },

      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,

          height: 54,

          margin: const EdgeInsets.symmetric(horizontal: 2),

          decoration: BoxDecoration(
            color: widget.selected
                ? colorScheme.primaryContainer
                : Colors.transparent,

            borderRadius: BorderRadius.circular(17),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ============================================================
              // ICON
              // ============================================================

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },

                child: Icon(
                  widget.selected ? widget.item.activeIcon : widget.item.icon,

                  key: ValueKey('${widget.item.label}-$widget.selected'),

                  size: widget.selected ? 23 : 22,

                  color: widget.selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 3),

              // ============================================================
              // LABEL
              // ============================================================
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),

                style: theme.textTheme.labelSmall!.copyWith(
                  fontSize: widget.selected ? 11 : 10,

                  fontWeight: widget.selected
                      ? FontWeight.w700
                      : FontWeight.w500,

                  color: widget.selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),

                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
