import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // WEEKLY THEME

        const _WeeklyThemeCard(),

        const SizedBox(height: 24),

        // TEACHER DASHBOARD
        const _SectionTitle(title: 'Teacher Dashboard'),

        const SizedBox(height: 12),

        const TeacherTools(),
      ],
    );
  }
}

// WEEKLY THEME

class _WeeklyThemeCard extends StatelessWidget {
  const _WeeklyThemeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "THIS WEEK'S THEME",
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'All About Me & My World',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Plan engaging activities and keep track of your students throughout the week.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// SECTION TITLE

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

// TEACHER TOOLS / DASHBOARD

class TeacherTools extends StatelessWidget {
  final ValueChanged<TeacherTool>? onToolTap;

  const TeacherTools({super.key, this.onToolTap});

  @override
  Widget build(BuildContext context) {
    const tools = [
      TeacherTool(
        title: 'Daily Report',
        description: 'Complete today\'s report',
        count: '3',
        countLabel: 'pending',
        icon: Icons.edit_note_rounded,
      ),
      TeacherTool(
        title: '3 Month Reports',
        description: 'View previous reports',
        count: '12',
        countLabel: 'available',
        icon: Icons.bar_chart_rounded,
      ),
      TeacherTool(
        title: 'Weekly Planner',
        description: 'Plan your weekly lessons',
        count: '5',
        countLabel: 'upcoming',
        icon: Icons.calendar_month_rounded,
      ),
      TeacherTool(
        title: 'Observations',
        description: 'Student observations',
        count: '3',
        countLabel: 'pending',
        icon: Icons.visibility_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 165,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];

        return TeacherToolCard(
          tool: tool,
          onTap: () {
            _openTool(context, tool);
            onToolTap?.call(tool);
          },
        );
      },
    );
  }
}

// OPEN TOOL

void _openTool(BuildContext context, TeacherTool tool) {
  switch (tool.title) {
    case 'Daily Report':
      context.push(AppRoutes.dailyReport);
      break;

    case '3 Month Reports':
      context.push(AppRoutes.threeMonthReports);
      break;

    case 'Weekly Planner':
      context.push(AppRoutes.weeklyPlanner);
      break;

    case 'Observations':
      context.push(AppRoutes.observations);
      break;
  }
}

// TOOL MODEL

class TeacherTool {
  final String title;
  final String description;
  final String count;
  final String countLabel;
  final IconData icon;

  const TeacherTool({
    required this.title,
    required this.description,
    required this.count,
    required this.countLabel,
    required this.icon,
  });
}

// TOOL CARD

class TeacherToolCard extends StatelessWidget {
  final TeacherTool tool;
  final VoidCallback? onTap;

  const TeacherToolCard({super.key, required this.tool, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  tool.icon,
                  size: 22,
                  color: colors.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 12),

              // TITLE
              Text(
                tool.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              // DESCRIPTION
              Text(
                tool.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              // COUNT + LABEL
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tool.count,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        tool.countLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
