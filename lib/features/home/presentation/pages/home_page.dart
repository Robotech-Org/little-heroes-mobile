import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/main/domain/entities/user_role.dart';

import '../widgets/home_header.dart';
import '../widgets/home_stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/role_dashboard.dart';

class HomePage extends StatelessWidget {
  final UserRole role;

  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            // ======================================================
            // HEADER
            // ======================================================

            SliverToBoxAdapter(child: HomeHeader(role: role)),

            // ======================================================
            // CONTENT
            // ======================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ==================================================
                  // ROLE DASHBOARD
                  // ==================================================

                  RoleDashboard(role: role),

                  const SizedBox(height: 24),

                  // ==================================================
                  // STATISTICS
                  // ==================================================
                  HomeStatCard(role: role),

                  const SizedBox(height: 28),

                  // ==================================================
                  // QUICK ACTIONS
                  // ==================================================
                  _SectionHeader(title: 'Quick Actions'),

                  const SizedBox(height: 14),

                  QuickActionCard(role: role),

                  const SizedBox(height: 28),

                  // ==================================================
                  // RECENT ACTIVITY
                  // ==================================================
                  _SectionHeader(title: _activityTitle),

                  const SizedBox(height: 14),

                  _RecentActivity(role: role),

                  const SizedBox(height: 28),

                  // ==================================================
                  // UPCOMING
                  // ==================================================
                  const _SectionHeader(title: 'Upcoming'),

                  const SizedBox(height: 14),

                  _UpcomingCard(role: role),

                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // ACTIVITY TITLE
  // ==============================================================

  String get _activityTitle {
    switch (role) {
      case UserRole.teacher:
        return 'Recent Class Activity';

      case UserRole.parent:
        return 'Child Activity';

      case UserRole.advisor:
        return 'Recent Activities';
    }
  }
}

// ==================================================================
// SECTION HEADER
// ==================================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}

// ==================================================================
// RECENT ACTIVITY
// ==================================================================

class _RecentActivity extends StatelessWidget {
  final UserRole role;

  const _RecentActivity({required this.role});

  // ================================================================
  // ACTIVITY DATA
  // ================================================================

  List<_Activity> get activities {
    switch (role) {
      case UserRole.teacher:
        return const [
          _Activity(
            title: 'Assignment submitted',
            subtitle: 'Mathematics • Grade 4A',
            time: '10 min ago',
            icon: Icons.assignment_turned_in_outlined,
          ),
          _Activity(
            title: 'Attendance completed',
            subtitle: 'Grade 4A',
            time: '1 hour ago',
            icon: Icons.fact_check_outlined,
          ),
          _Activity(
            title: 'New parent message',
            subtitle: 'Sarah\'s parent',
            time: '2 hours ago',
            icon: Icons.message_outlined,
          ),
        ];

      case UserRole.parent:
        return const [
          _Activity(
            title: 'Homework completed',
            subtitle: 'Mathematics',
            time: '20 min ago',
            icon: Icons.check_circle_outline,
          ),
          _Activity(
            title: 'New teacher message',
            subtitle: 'Grade 4 teacher',
            time: '1 hour ago',
            icon: Icons.message_outlined,
          ),
          _Activity(
            title: 'School announcement',
            subtitle: 'Important announcement',
            time: '3 hours ago',
            icon: Icons.campaign_outlined,
          ),
        ];

      case UserRole.advisor:
        return const [
          _Activity(
            title: 'New student case',
            subtitle: 'Student support required',
            time: '15 min ago',
            icon: Icons.folder_open_outlined,
          ),
          _Activity(
            title: 'Support session completed',
            subtitle: 'Student counseling',
            time: '1 hour ago',
            icon: Icons.event_available_outlined,
          ),
          _Activity(
            title: 'New parent message',
            subtitle: 'Parent communication',
            time: '2 hours ago',
            icon: Icons.message_outlined,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Column(
        children: activities
            .map((activity) => _ActivityTile(activity: activity))
            .toList(),
      ),
    );
  }
}

// ==================================================================
// ACTIVITY MODEL
// ==================================================================

class _Activity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}

// ==================================================================
// ACTIVITY TILE
// ==================================================================

class _ActivityTile extends StatelessWidget {
  final _Activity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              activity.icon,
              color: colorScheme.onPrimaryContainer,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          // ========================================================
          // TEXT
          // ========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ========================================================
          // TIME
          // ========================================================
          Text(
            activity.time,

            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// UPCOMING
// ==================================================================

class _UpcomingCard extends StatelessWidget {
  final UserRole role;

  const _UpcomingCard({required this.role});

  _Upcoming get upcoming {
    switch (role) {
      case UserRole.teacher:
        return const _Upcoming(
          title: 'Mathematics Class',
          subtitle: 'Grade 4A • Room 203',
          time: '09:00 AM',
          icon: Icons.school_outlined,
        );

      case UserRole.parent:
        return const _Upcoming(
          title: 'Parent Meeting',
          subtitle: 'Meeting with teacher',
          time: '02:00 PM',
          icon: Icons.groups_outlined,
        );

      case UserRole.advisor:
        return const _Upcoming(
          title: 'Student Support Session',
          subtitle: 'Student counseling',
          time: '11:00 AM',
          icon: Icons.support_agent_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final item = upcoming;

    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Row(
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(item.icon, color: colorScheme.onPrimaryContainer),
          ),

          const SizedBox(width: 14),

          // ========================================================
          // INFORMATION
          // ========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ========================================================
          // TIME
          // ========================================================
          Text(
            item.time,

            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// UPCOMING MODEL
// ==================================================================

class _Upcoming {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _Upcoming({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}
