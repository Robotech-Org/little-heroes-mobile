import 'package:flutter/material.dart';

import '../../domain/entities/user_role.dart';

class SettingsRoleTile extends StatelessWidget {
  final UserRole role;
  final VoidCallback onChange;

  const SettingsRoleTile({
    super.key,
    required this.role,
    required this.onChange,
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
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(_roleIcon(role), color: colors.onPrimaryContainer),
        ),

        title: const Text(
          'Current Role',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),

        subtitle: Text(
          _roleName(role),
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
        ),

        trailing: FilledButton.tonal(
          onPressed: onChange,
          child: const Text('Change'),
        ),
      ),
    );
  }
}
