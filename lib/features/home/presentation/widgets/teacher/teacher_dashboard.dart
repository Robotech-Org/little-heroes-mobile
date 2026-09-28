import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/dashboard_response_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/dashboard_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/common/home_header.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/widgeta/attendance_section.dart';
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
  bool _isRefreshing = false;
  String _errorMessage = '';

  TeacherData? _cachedData;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool useCache = true}) async {
    if (useCache && _cachedData != null && _lastCacheTime != null) {
      final cacheAge = DateTime.now().difference(_lastCacheTime!);
      if (cacheAge < _cacheDuration) {
        setState(() {
          _dashboardData = _cachedData;
          _isLoading = false;
          _isError = false;
        });
        return;
      }
    }

    final hasCachedData = _cachedData != null;
    if (!hasCachedData) {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    } else {
      setState(() {
        _isRefreshing = true;
        _isError = false;
      });
    }

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Please login to view dashboard';
        });
        return;
      }

      final repository = di.sl<DashboardRepository>();
      final response = await repository.getDashboard();

      if (response.data is TeacherData) {
        final data = response.data as TeacherData;
        setState(() {
          _dashboardData = data;
          _cachedData = data;
          _lastCacheTime = DateTime.now();
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
        });
      } else if (response.data is ParentData) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Teacher dashboard not available for parent role';
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Invalid dashboard data';
        });
      }
    } catch (e) {
      if (_cachedData != null) {
        setState(() {
          _dashboardData = _cachedData;
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeletonLoading();
    if (_isError) return _buildErrorWidget();
    if (_dashboardData == null) return const SizedBox.shrink();

    final data = _dashboardData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeHeader(),
        const SizedBox(height: 12),

        // Weekly Theme
        _WeeklyThemeCard(themeData: data.theme),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════
        // TEACHER TOOLS (reporting only — no attendance)
        // ═══════════════════════════════════════════════════════
        const _SectionTitle(title: 'Teacher Tools'),
        const SizedBox(height: 5),
        // ═══════════════════════════════════════════════════════
        // ATTENDANCE (all in one reusable widget)
        // ═══════════════════════════════════════════════════════

        TeacherTools(dashboardData: data.dashboard, onToolTap: (tool) {}),
        const SizedBox(height: 24),

        const _SectionTitle(title: 'Attendance'),
        const SizedBox(height: 12),
        const AttendanceSection(isPermitted: false),
      ],
    );
  }

  // ============================================================
  // SKELETON LOADING
  // ============================================================
  Widget _buildSkeletonLoading() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSkeletonLine(width: 120, height: 12),
              const SizedBox(height: 10),
              _buildSkeletonLine(width: 200, height: isSmallScreen ? 20 : 24),
              const SizedBox(height: 10),
              _buildSkeletonLine(width: double.infinity, height: 14),
              const SizedBox(height: 4),
              _buildSkeletonLine(width: 150, height: 14),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSkeletonLine(width: 150, height: 20),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isSmallScreen ? 2.2 : 1.8,
          ),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSkeletonLine(width: 80, height: 14),
                        const SizedBox(height: 4),
                        _buildSkeletonLine(width: 60, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonLine({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
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
              onPressed: () => _loadDashboard(useCache: false),
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

// ============================================================
// WEEKLY THEME
// ============================================================
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
        mainAxisSize: MainAxisSize.min,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            themeData.goal,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.9),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================
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

// ============================================================
// TEACHER TOOLS GRID (reporting only)
// ============================================================
class TeacherTools extends StatelessWidget {
  final DashboardMetrics dashboardData;
  final ValueChanged<TeacherTool>? onToolTap;

  const TeacherTools({super.key, required this.dashboardData, this.onToolTap});

  @override
  Widget build(BuildContext context) {
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
      TeacherTool(
        title: 'Add a Moment',
        description: 'Share with parents',
        count: '',
        countLabel: '',
        icon: Icons.photo_camera_rounded,
        route: AppRoutes.addMoment,
      ),
      TeacherTool(
        title: 'Compile 3 Month Report',
        description: '3 Month Report',
        count: '',
        countLabel: '',
        icon: Icons.history_edu_rounded,
        route: AppRoutes.Compile_3_onth_report,
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
      case AppRoutes.threeMonthReports:
      case AppRoutes.weeklyPlanner:
      case AppRoutes.observations:
      case AppRoutes.addMoment:
      case AppRoutes.Compile_3_onth_report:
        // context.push(tool.route);
        break;
      default:
        break;
    }
  }
}

// ============================================================
// TOOL MODEL
// ============================================================
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

// ============================================================
// TOOL CARD
// ============================================================
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
