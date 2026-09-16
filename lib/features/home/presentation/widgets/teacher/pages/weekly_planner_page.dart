import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/lesson_plan_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/lesson_plan_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/lesson_plan_detail_page.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'create_lesson_plan_page.dart';

class WeeklyPlannerPage extends StatefulWidget {
  const WeeklyPlannerPage({super.key});

  @override
  State<WeeklyPlannerPage> createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  List<LessonPlanModel> _lessonPlans = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isRefreshing = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalPlans = 0;
  final int _pageSize = 20;

  // Cache
  List<LessonPlanModel>? _cachedLessonPlans;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadLessonPlans();
  }

  Future<void> _loadLessonPlans({int page = 1, bool useCache = true}) async {
    // Check cache
    if (useCache && _cachedLessonPlans != null && _lastCacheTime != null) {
      final cacheAge = DateTime.now().difference(_lastCacheTime!);
      if (cacheAge < _cacheDuration) {
        setState(() {
          _lessonPlans = _cachedLessonPlans!;
          _isLoading = false;
          _isError = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = _cachedLessonPlans == null;
      _isRefreshing = _cachedLessonPlans != null;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Please login to view lesson plans';
        });
        return;
      }

      final repository = di.sl<LessonPlanRepository>();
      final response = await repository.getLessonPlans(
        page: page,
        pageSize: _pageSize,
      );

      setState(() {
        _lessonPlans = response.items;
        _cachedLessonPlans = response.items;
        _lastCacheTime = DateTime.now();
        _totalPlans = response.total;
        _totalPages = response.totalPages;
        _currentPage = response.page;
        _isLoading = false;
        _isRefreshing = false;
        _isError = false;
      });
    } catch (e) {
      // Use cached data if available
      if (_cachedLessonPlans != null) {
        setState(() {
          _lessonPlans = _cachedLessonPlans!;
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

  void _openLessonPlanDetail(LessonPlanModel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPlanDetailPage(
          plan: plan, // show skeleton immediately
          lessonPlanName: plan.name, // then refetch for full detail
        ),
      ),
    ).then((_) => _loadLessonPlans(useCache: false));
  }

  void _navigateToCreateLessonPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateLessonPlanPage()),
    ).then((_) => _loadLessonPlans(useCache: false));
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Weekly Planner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadLessonPlans(useCache: false),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _navigateToCreateLessonPlan,
            tooltip: 'Create Lesson Plan',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadLessonPlans(useCache: false),
        child: _buildContent(theme, colorScheme),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return _buildSkeletonLoading(theme, colorScheme);
    }

    if (_isError) {
      return _buildErrorWidget(theme, colorScheme);
    }

    if (_lessonPlans.isEmpty) {
      return _buildEmptyWidget(theme, colorScheme);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
              
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            physics: const BouncingScrollPhysics(),
            itemCount: _lessonPlans.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 14), // ← the gap
            itemBuilder: (context, index) {
              final plan = _lessonPlans[index];
              return _LessonPlanCard(
                plan: plan,
                onTap: () => _openLessonPlanDetail(plan),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildSkeletonLine(width: 160, height: 18)),
                  _buildSkeletonLine(width: 60, height: 20),
                ],
              ),
              const SizedBox(height: 8),
              _buildSkeletonLine(width: 120, height: 14),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSkeletonLine(width: 80, height: 12),
                  const SizedBox(width: 12),
                  _buildSkeletonLine(width: 80, height: 12),
                ],
              ),
              const SizedBox(height: 8),
              _buildSkeletonLine(width: double.infinity, height: 12),
              const SizedBox(height: 4),
              _buildSkeletonLine(width: 140, height: 12),
            ],
          ),
        );
      }),
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

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load lesson plans',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadLessonPlans(useCache: false),
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 34,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Lesson Plans',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start creating your weekly lesson plans.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreateLessonPlan,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Lesson Plan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonPlanCard extends StatelessWidget {
  final LessonPlanModel plan;
  final VoidCallback onTap;

  const _LessonPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final statusColor = _statusColor(plan.status);
    final statusLabel = _statusLabel(plan.status);

    final title = plan.titleOfLesson?.trim().isNotEmpty == true
        ? plan.titleOfLesson!
        : 'Untitled Lesson';
    final dateStr = plan.lessonPlanDate?.isNotEmpty == true
        ? _formatDate(plan.lessonPlanDate!)
        : 'No date';

    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final tertiaryText = isDark
        ? AppColors.darkTextTertiary
        : AppColors.lightTextTertiary;
    final surfaceColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Subject chip + status pill ──
                Row(
                  children: [
                    if (plan.subject?.isNotEmpty == true) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            plan.subject!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                              fontSize: 10,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              fontSize: 9.5,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Row 2: Title ────────────────────────
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // ═══════════════════════════════════════════════
                //  ADMIN REJECTION BANNER
                // ═══════════════════════════════════════════════
                if (plan.hasRejection) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejected by Admin',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                  fontSize: 10.5,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                plan.adminRejectionNote!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryText,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ── Row 3: Meta (classroom, date) ──────
                Row(
                  children: [
                    _metaItem(
                      theme: theme,
                      icon: Icons.class_rounded,
                      label: plan.classroom.isNotEmpty ? plan.classroom : '—',
                      color: secondaryText,
                    ),
                    const SizedBox(width: 12),
                    _metaItem(
                      theme: theme,
                      icon: Icons.calendar_today_rounded,
                      label: dateStr,
                      color: secondaryText,
                    ),
                  ],
                ),

                // ── Row 4: Objective preview ───────────
                if (plan.objective?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: isDark ? 0.25 : 0.45,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.objective!.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tertiaryText,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 130),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warningDark;
      case 'rejected':
        return AppColors.error;
      case 'draft':
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'APPROVED';
      case 'pending':
        return 'PENDING';
      case 'rejected':
        return 'REJECTED';
      case 'draft':
        return 'DRAFT';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso.replaceFirst(' ', 'T'));
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
