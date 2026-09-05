import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';

class QuickActionCard extends StatelessWidget {
  final UserRole role;

  const QuickActionCard({super.key, required this.role});

  List<_Action> get actions {
    switch (role) {
      case UserRole.teacher:
        return const [
          _Action(title: 'Students', icon: Icons.people_alt_outlined),
          _Action(title: 'Attendance', icon: Icons.fact_check_outlined),
          _Action(title: 'Assignments', icon: Icons.assignment_outlined),
          _Action(title: 'Messages', icon: Icons.chat_bubble_outline),
        ];

      case UserRole.parent:
        return const [
          _Action(title: 'My Children', icon: Icons.child_care_outlined),
          _Action(title: 'Attendance', icon: Icons.calendar_today_outlined),
          _Action(title: 'Messages', icon: Icons.chat_bubble_outline),
          _Action(title: 'Progress', icon: Icons.trending_up_outlined),
        ];

      case UserRole.adviser:
        return const [
          _Action(title: 'Students', icon: Icons.people_outline),
          _Action(title: 'Cases', icon: Icons.folder_open_outlined),
          _Action(title: 'Sessions', icon: Icons.event_outlined),
          _Action(title: 'Messages', icon: Icons.chat_bubble_outline),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = actions;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: items.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),

      itemBuilder: (context, index) {
        return _ActionItem(
          action: items[index],
          onTap: () {
            // TODO:
            // Navigate to the corresponding feature.
          },
        );
      },
    );
  }
}



class _Action {
  final String title;
  final IconData icon;

  const _Action({required this.title, required this.icon});
}



class _ActionItem extends StatelessWidget {
  final _Action action;
  final VoidCallback onTap;

  const _ActionItem({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),

          child: Row(
            children: [
              // 
              // ICON
              // 

              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(
                  action.icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              // 
              // TITLE
              // 
              Expanded(
                child: Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
