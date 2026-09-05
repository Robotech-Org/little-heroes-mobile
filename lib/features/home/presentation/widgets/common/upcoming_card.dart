import 'package:flutter/material.dart';

enum UpcomingType { teacher, parent, adviser }

class UpcomingCard extends StatelessWidget {
  final UpcomingType type;

  const UpcomingCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = _upcoming();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              upcoming.icon,
              color: theme.colorScheme.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upcoming.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  upcoming.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      upcoming.date,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      upcoming.time,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _UpcomingData _upcoming() {
    switch (type) {
      case UpcomingType.parent:
        return const _UpcomingData(
          title: 'Parent Meeting',
          subtitle: 'Upcoming activity for your child',
          date: 'Tomorrow',
          time: '10:00 AM',
          icon: Icons.event_outlined,
        );

      case UpcomingType.teacher:
        return const _UpcomingData(
          title: 'Class Activity',
          subtitle: 'Your next scheduled class activity',
          date: 'Tomorrow',
          time: '9:00 AM',
          icon: Icons.school_outlined,
        );

      case UpcomingType.adviser:
        return const _UpcomingData(
          title: 'Student Review',
          subtitle: 'Upcoming student review',
          date: 'Tomorrow',
          time: '11:00 AM',
          icon: Icons.person_search_outlined,
        );
    }
  }
}

class _UpcomingData {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final IconData icon;

  const _UpcomingData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.icon,
  });
}
