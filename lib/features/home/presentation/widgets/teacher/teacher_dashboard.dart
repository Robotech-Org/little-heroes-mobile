import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/dashboard_response_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/dashboard_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  TeacherData? _dashboardData;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Please login to view dashboard';
        });
        return;
      }

      final repository = di.sl<DashboardRepository>();
      final response = await repository.getDashboard();

      // Check if the response data is for teacher
      if (response.data is TeacherData) {
        setState(() {
          _dashboardData = response.data as TeacherData;
          _isLoading = false;
        });
      } else if (response.data is ParentData) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Teacher dashboard not available for parent role';
        });
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Invalid dashboard data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return _buildErrorWidget();
    }

    if (_dashboardData == null) {
      return const SizedBox.shrink();
    }

    final data = _dashboardData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Theme
        _WeeklyThemeCard(themeData: data.theme),
        const SizedBox(height: 24),

        // Teacher Dashboard
        const _SectionTitle(title: 'Teacher Dashboard'),
        const SizedBox(height: 12),

        // Teacher Tools with real data
        TeacherTools(
          dashboardData: data.dashboard,
          onToolTap: (tool) {
            // Handle tool tap if needed
          },
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WEEKLY THEME
class _WeeklyThemeCard extends StatelessWidget {
  final ThemeInfo themeData;

  const _WeeklyThemeCard({required this.themeData});

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
            themeData.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            themeData.goal,
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
  final DashboardMetrics dashboardData;
  final ValueChanged<TeacherTool>? onToolTap;

  const TeacherTools({super.key, required this.dashboardData, this.onToolTap});

  @override
  Widget build(BuildContext context) {
    // Build tools from dashboard data
    final tools = [
      TeacherTool(
        title: dashboardData.dailyReport.label,
        description: 'Complete today\'s report',
        count: dashboardData.dailyReport.reportsLogged.toString(),
        countLabel: 'of ${dashboardData.dailyReport.totalStudents}',
        icon: Icons.edit_note_rounded,
        route: AppRoutes.dailyReport_teachers,
      ),
      TeacherTool(
        title: dashboardData.threeMonthReport.label,
        description: 'View previous reports',
        count: dashboardData.threeMonthReport.frameworksCount.toString(),
        countLabel: 'frameworks',
        icon: Icons.bar_chart_rounded,
        route: AppRoutes.threeMonthReports,
      ),
      TeacherTool(
        title: dashboardData.weeklyPlanner.label,
        description: 'Plan your weekly lessons',
        count: dashboardData.weeklyPlanner.pendingReview.toString(),
        countLabel: 'pending review',
        icon: Icons.calendar_month_rounded,
        route: AppRoutes.weeklyPlanner,
      ),
      TeacherTool(
        title: dashboardData.observation.label,
        description: 'Student observations',
        count: '0',
        countLabel: 'pending',
        icon: Icons.visibility_outlined,
        route: AppRoutes.observations,
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

  void _openTool(BuildContext context, TeacherTool tool) {
    switch (tool.route) {
      case AppRoutes.dailyReport_teachers:
        context.push(AppRoutes.dailyReport_teachers);
        break;
      case AppRoutes.threeMonthReports:
        context.push(AppRoutes.threeMonthReports);
        break;
      case AppRoutes.weeklyPlanner:
        context.push(AppRoutes.weeklyPlanner);
        break;
      case AppRoutes.observations:
        context.push(AppRoutes.observations);
        break;
      default:
        break;
    }
  }
}

// TOOL MODEL
class TeacherTool {
  final String title;
  final String description;
  final String count;
  final String countLabel;
  final IconData icon;
  final String route;

  const TeacherTool({
    required this.title,
    required this.description,
    required this.count,
    required this.countLabel,
    required this.icon,
    required this.route,
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
