import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';

class HomeStatCard extends StatelessWidget {
  final UserRole role;

  const HomeStatCard({super.key, required this.role});

  List<_Stat> get stats {
    switch (role) {
      case UserRole.teacher:
        return const [
          _Stat(
            title: 'Students',
            value: '32',
            icon: Icons.people_alt_outlined,
          ),
          _Stat(title: 'Classes', value: '4', icon: Icons.class_outlined),
          _Stat(title: 'Tasks', value: '12', icon: Icons.assignment_outlined),
        ];

      case UserRole.parent:
        return const [
          _Stat(title: 'Children', value: '2', icon: Icons.child_care_outlined),
          _Stat(
            title: 'Attendance',
            value: '94%',
            icon: Icons.calendar_month_outlined,
          ),
          _Stat(
            title: 'Activities',
            value: '8',
            icon: Icons.auto_awesome_outlined,
          ),
        ];

      case UserRole.adviser:
        return const [
          _Stat(title: 'Students', value: '48', icon: Icons.people_outline),
          _Stat(title: 'Cases', value: '7', icon: Icons.folder_open_outlined),
          _Stat(
            title: 'Sessions',
            value: '15',
            icon: Icons.event_note_outlined,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = stats;

    return Row(
      children: List.generate(items.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 10),
            child: _StatItem(stat: items[index]),
          ),
        );
      }),
    );
  }
}

// ==================================================================
// STAT MODEL
// ==================================================================

class _Stat {
  final String title;
  final String value;
  final IconData icon;

  const _Stat({required this.title, required this.value, required this.icon});
}

// ==================================================================
// STAT ITEM
// ==================================================================

class _StatItem extends StatelessWidget {
  final _Stat stat;

  const _StatItem({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Icon(stat.icon, size: 22, color: colorScheme.primary),

          const SizedBox(height: 12),

          // ========================================================
          // VALUE
          // ========================================================
          Text(
            stat.value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 3),

          // ========================================================
          // TITLE
          // ========================================================
          Text(
            stat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
