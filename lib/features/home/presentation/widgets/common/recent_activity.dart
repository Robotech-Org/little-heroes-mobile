import 'package:flutter/material.dart';

enum RecentActivityType { teacher, parent, adviser }

class RecentActivity extends StatelessWidget {
  final RecentActivityType type;

  const RecentActivity({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final activities = _activities();

    if (activities.isEmpty) {
      return const _EmptyActivity();
    }

    return Column(
      children: activities
          .map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(activity: activity),
            ),
          )
          .toList(),
    );
  }

  List<_Activity> _activities() {
    switch (type) {
      case RecentActivityType.parent:
        return const [
          _Activity(
            title: 'Daily Report',
            subtitle: 'A new daily report is ready to view',
            time: 'Today',
            icon: Icons.description_outlined,
            status: 'Ready',
          ),
          _Activity(
            title: 'Photo Moments',
            subtitle: 'New photos have been added',
            time: 'Yesterday',
            icon: Icons.photo_library_outlined,
            status: 'New',
          ),
          _Activity(
            title: 'Payment',
            subtitle: 'Monthly payment was received',
            time: '2 days ago',
            icon: Icons.payment_outlined,
            status: 'Paid',
          ),
        ];

      case RecentActivityType.teacher:
        return const [
          _Activity(
            title: 'Class Activity',
            subtitle: 'New classroom activity was added',
            time: 'Today',
            icon: Icons.school_outlined,
            status: 'New',
          ),
          _Activity(
            title: 'Daily Report',
            subtitle: 'Daily report submitted',
            time: 'Yesterday',
            icon: Icons.description_outlined,
            status: 'Done',
          ),
        ];

      case RecentActivityType.adviser:
        return const [
          _Activity(
            title: 'Student Activity',
            subtitle: 'New student activity is available',
            time: 'Today',
            icon: Icons.person_outline,
            status: 'New',
          ),
          _Activity(
            title: 'Report',
            subtitle: 'A student report has been generated',
            time: 'Yesterday',
            icon: Icons.description_outlined,
            status: 'Ready',
          ),
        ];
    }
  }
}

class _Activity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final String status;

  const _Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.status,
  });
}

class _ActivityTile extends StatelessWidget {
  final _Activity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: theme.colorScheme.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  activity.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  activity.time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activity.status,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'No recent activity',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
