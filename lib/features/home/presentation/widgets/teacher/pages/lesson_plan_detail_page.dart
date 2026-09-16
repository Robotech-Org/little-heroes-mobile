import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/lesson_plan_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/lesson_plan_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class LessonPlanDetailPage extends StatefulWidget {
  /// Pass either a full model for instant render, or just the name to fetch.
  final LessonPlanModel? plan;
  final String? lessonPlanName;

  const LessonPlanDetailPage({super.key, this.plan, this.lessonPlanName})
    : assert(
        plan != null || lessonPlanName != null,
        'Provide either plan or lessonPlanName',
      );

  @override
  State<LessonPlanDetailPage> createState() => _LessonPlanDetailPageState();
}

class _LessonPlanDetailPageState extends State<LessonPlanDetailPage> {
  LessonPlanModel? _plan;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    // Always fetch to get the full fresh detail
    _load();
  }

  Future<void> _load() async {
    final name = widget.lessonPlanName ?? widget.plan?.name;
    if (name == null || name.isEmpty) {
      setState(() => _error = 'Missing lesson plan name');
      return;
    }

    setState(() {
      _loading = _plan == null;
      _error = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _loading = false;
          _error = 'Please login to view this lesson plan';
        });
        return;
      }

      final repo = di.sl<LessonPlanRepository>();
      final result = await repo.getLessonPlan(name);

      if (!mounted) return;
      setState(() {
        _plan = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_plan == null) _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Lesson Plan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _buildBody(theme, colorScheme, isDark),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError(theme, colorScheme, _error!);
    }
    final p = _plan;
    if (p == null) return _buildEmpty(theme, colorScheme);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + status header ───────────────────────────
            _buildHeader(theme, colorScheme, isDark, p),
            const SizedBox(height: 20),

            // ── Meta grid ───────────────────────────────────────
            _buildMetaGrid(theme, colorScheme, isDark, p),
            const SizedBox(height: 20),

            // ── Sections ────────────────────────────────────────
            if (p.subject != null && p.subject!.isNotEmpty)
              _buildSection(
                theme,
                colorScheme,
                isDark,
                icon: Icons.category_outlined,
                label: 'Subject',
                body: p.subject!,
              ),
            if (p.objective != null && p.objective!.isNotEmpty)
              _buildSection(
                theme,
                colorScheme,
                isDark,
                icon: Icons.flag_outlined,
                label: 'Objective',
                body: p.objective!,
              ),
            if (p.introduction != null && p.introduction!.isNotEmpty)
              _buildSection(
                theme,
                colorScheme,
                isDark,
                icon: Icons.play_circle_outline_rounded,
                label: 'Introduction',
                body: p.introduction!,
              ),
            if (p.materials != null && p.materials!.isNotEmpty)
              _buildSection(
                theme,
                colorScheme,
                isDark,
                icon: Icons.inventory_2_outlined,
                label: 'Materials Needed',
                body: p.materials!,
              ),
            if (p.keyDevelopmentIndicator != null &&
                p.keyDevelopmentIndicator!.isNotEmpty)
              _buildSection(
                theme,
                colorScheme,
                isDark,
                icon: Icons.trending_up_rounded,
                label: 'Key Development Indicator',
                body: p.keyDevelopmentIndicator!,
              ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Created ${_formatDateTime(p.creation)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // HEADER — title, status badge, subject chip
  // ═════════════════════════════════════════════════════════════
  Widget _buildHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    LessonPlanModel p,
  ) {
    final statusColor = _statusColor(p.status);
    final statusText = p.statusText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
            colorScheme.primary.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chip + type
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
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
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (p.lessonPlanType != null && p.lessonPlanType!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.lessonPlanType!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            p.titleOfLesson?.isNotEmpty == true
                ? p.titleOfLesson!
                : 'Untitled Lesson',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // META GRID — dates, classroom, teacher
  // ═════════════════════════════════════════════════════════════
  Widget _buildMetaGrid(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    LessonPlanModel p,
  ) {
    final tiles = <_MetaTile>[
      if (p.lessonPlanDate != null && p.lessonPlanDate!.isNotEmpty)
        _MetaTile(
          icon: Icons.calendar_today_rounded,
          label: 'Lesson Date',
          value: _formatDate(p.lessonPlanDate!),
        ),
      if (p.lessonPlanWeekStart != null && p.lessonPlanWeekStart!.isNotEmpty)
        _MetaTile(
          icon: Icons.calendar_view_week_rounded,
          label: 'Week Start',
          value: _formatDate(p.lessonPlanWeekStart!),
        ),
      if (p.classroom.isNotEmpty)
        _MetaTile(
          icon: Icons.class_rounded,
          label: 'Classroom',
          value: p.classroom,
        ),
      if (p.teacher.isNotEmpty)
        _MetaTile(
          icon: Icons.person_outline_rounded,
          label: 'Teacher',
          value: p.teacher,
        ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: tiles
          .map((t) => _buildMetaTileCard(theme, colorScheme, isDark, t))
          .toList(),
    );
  }

  Widget _buildMetaTileCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    _MetaTile tile,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(tile.icon, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tile.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tile.value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SECTION — icon + label + body text
  // ═════════════════════════════════════════════════════════════
  Widget _buildSection(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark, {
    required IconData icon,
    required String label,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════════════════════
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'draft':
      default:
        return AppColors.primary;
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

  String _formatDateTime(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso.replaceFirst(' ', 'T'));
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      return '${_formatDate(iso)} at $h:$m';
    } catch (_) {
      return iso;
    }
  }

  Widget _buildError(ThemeData theme, ColorScheme colorScheme, String msg) {
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
              'Could not load lesson plan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Lesson plan not found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTile {
  final IconData icon;
  final String label;
  final String value;
  _MetaTile({required this.icon, required this.label, required this.value});
}
