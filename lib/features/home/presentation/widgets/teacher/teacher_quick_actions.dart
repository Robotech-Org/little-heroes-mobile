import 'package:flutter/material.dart';

class TeacherQuickActions extends StatelessWidget {
  const TeacherQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _QuickActionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Weekly Planner',
          subtitle: 'Plan your classes',
          onTap: () {
            // TODO: Navigate to WeeklyPlannerPage
          },
        ),

        _QuickActionCard(
          icon: Icons.assignment_rounded,
          title: 'Daily Report',
          subtitle: 'Create daily report',
          onTap: () {
            // TODO: Navigate to DailyReportPage
          },
        ),

        _QuickActionCard(
          icon: Icons.visibility_rounded,
          title: 'Observations',
          subtitle: 'View observations',
          onTap: () {
            // TODO: Navigate to ObservationsPage
          },
        ),

        _QuickActionCard(
          icon: Icons.bar_chart_rounded,
          title: 'Reports',
          subtitle: 'View student reports',
          onTap: () {
            // TODO: Navigate to ThreeMonthReportsPage
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary, size: 22),
              ),

              const Spacer(),

              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
