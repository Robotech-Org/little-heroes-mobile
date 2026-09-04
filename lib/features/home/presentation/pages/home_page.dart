import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/widgets/qr_scanner/qr_scanner_page.dart';
import 'package:little_heroes_mobile/core/widgets/qr_scanner/qr_scanner_result.dart';
import 'package:little_heroes_mobile/features/main/domain/entities/user_role.dart';
import 'package:little_heroes_mobile/features/teacher/presentation/widgets/teacher_tools.dart';

import '../widgets/home_header.dart';
import '../widgets/home_stat_card.dart';
import '../widgets/role_dashboard.dart';

class HomePage extends StatelessWidget {
  final UserRole role;

  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            // ============================================================
            // HEADER
            // ============================================================

            SliverToBoxAdapter(child: HomeHeader(role: role)),

            // ============================================================
            // CONTENT
            // ============================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ======================================================
                  // ROLE DASHBOARD
                  // ======================================================

                  RoleDashboard(role: role),

                  const SizedBox(height: 24),

                  // ======================================================
                  // STATISTICS
                  // ======================================================
                  HomeStatCard(role: role),

                  // ======================================================
                  // TEACHER TOOLS
                  // ======================================================
                  // if (role == UserRole.teacher) ...[
                  //   const SizedBox(height: 28),

                  //   const _SectionHeader(title: 'Dashboard', subtitle: ''),

                  //   const SizedBox(height: 14),

                  //   TeacherTools(
                  //     role: role,
                  //     onToolTap: (tool) {
                  //       _openTeacherTool(context, tool);
                  //     },
                  //   ),
                  // ],
                  if (role == UserRole.teacher) ...[
                    const SizedBox(height: 28),

                    const _SectionHeader(title: 'Quick Actions', subtitle: ''),

                    const SizedBox(height: 14),

                    _QrScannerCard(onTap: () => _openQrScanner(context)),

                    const SizedBox(height: 28),

                    const _SectionHeader(title: 'Dashboard', subtitle: ''),

                    const SizedBox(height: 14),

                    TeacherTools(
                      role: role,
                      onToolTap: (tool) {
                        _openTeacherTool(context, tool);
                      },
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ======================================================
                  // RECENT ACTIVITY
                  // ======================================================
                  _SectionHeader(
                    title: _activityTitle,
                    subtitle: _activitySubtitle,
                  ),

                  const SizedBox(height: 14),

                  _RecentActivity(role: role),

                  const SizedBox(height: 28),

                  // ======================================================
                  // UPCOMING
                  // ======================================================
                  const _SectionHeader(
                    title: 'Upcoming',
                    subtitle: 'Your next scheduled activity',
                  ),

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

  Future<void> _openQrScanner(BuildContext context) async {
    final QrScannerResult? result = await Navigator.push<QrScannerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerPage(
          title: 'Scan QR Code',
          instruction: 'Scan the student QR code',
        ),
      ),
    );

    if (result == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('QR Code: ${result.value}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ========================================================================
  // TEACHER TOOL NAVIGATION
  // ========================================================================

  void _openTeacherTool(BuildContext context, TeacherTool tool) {
    switch (tool.title) {
      case 'Daily Report':
        _showToolMessage(context, 'Daily Report selected');
        break;

      case '3 Month Reports':
        _showToolMessage(context, '3 Month Reports selected');
        break;

      case 'Weekly Planner':
        _showToolMessage(context, 'Weekly Planner selected');
        break;

      case 'Observations':
        _showToolMessage(context, 'Observations selected');
        break;
    }
  }

  void _showToolMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ========================================================================
  // ACTIVITY TITLES
  // ========================================================================

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

  String get _activitySubtitle {
    switch (role) {
      case UserRole.teacher:
        return 'Latest updates from your classes';

      case UserRole.parent:
        return 'Latest updates about your child';

      case UserRole.advisor:
        return 'Latest student activities';
    }
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 4),

          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// RECENT ACTIVITY
// ============================================================================

class _RecentActivity extends StatelessWidget {
  final UserRole role;

  const _RecentActivity({required this.role});

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
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: List.generate(activities.length, (index) {
          final activity = activities[index];

          return _ActivityTile(
            activity: activity,
            showDivider: index != activities.length - 1,
          );
        }),
      ),
    );
  }
}

class _QrScannerCard extends StatelessWidget {
  final VoidCallback onTap;

  const _QrScannerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: colors.onPrimaryContainer,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan QR Code',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Scan a student QR code',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ACTIVITY MODEL
// ============================================================================

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

// ============================================================================
// ACTIVITY TILE
// ============================================================================

class _ActivityTile extends StatelessWidget {
  final _Activity activity;
  final bool showDivider;

  const _ActivityTile({required this.activity, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  activity.icon,
                  color: colors.onPrimaryContainer,
                  size: 21,
                ),
              ),

              const SizedBox(width: 13),

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
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      activity.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                activity.time,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            indent: 74,
            endIndent: 16,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
      ],
    );
  }
}

// ============================================================================
// UPCOMING CARD
// ============================================================================

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
    final colors = theme.colorScheme;

    final item = upcoming;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(item.icon, color: colors.onPrimaryContainer),
          ),

          const SizedBox(width: 14),

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
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            item.time,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// UPCOMING MODEL
// ============================================================================

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
