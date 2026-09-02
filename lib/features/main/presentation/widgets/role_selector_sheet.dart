import 'package:flutter/material.dart';

import '../../domain/entities/user_role.dart';

class RoleSelectorSheet {
  static void show({
    required BuildContext context,
    required UserRole currentRole,
    required ValueChanged<UserRole> onRoleSelected,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      isScrollControlled: true,
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
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 18),

                ...UserRole.values.map((item) {
                  return _RoleOption(
                    role: item,
                    selected: item == currentRole,
                    onTap: () {
                      Navigator.pop(sheetContext);

                      if (item != currentRole) {
                        onRoleSelected(item);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// ROLE OPTION
// ============================================================================

class _RoleOption extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.selected,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: ListTile(
        onTap: onTap,

        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

        leading: CircleAvatar(
          backgroundColor: selected ? colors.primary : colors.surface,
          child: Icon(
            _roleIcon(role),
            color: selected ? colors.onPrimary : colors.onSurfaceVariant,
          ),
        ),

        title: Text(
          _roleName(role),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),

        trailing: Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
