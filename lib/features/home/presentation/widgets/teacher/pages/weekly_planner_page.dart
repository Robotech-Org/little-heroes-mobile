import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/features/home/data/models/lesson_plan_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/lesson_plan_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/lesson_plan_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'create_lesson_plan_page.dart'; // ADD THIS IMPORT

class WeeklyPlannerPage extends StatefulWidget {
  const WeeklyPlannerPage({super.key});

  @override
  State<WeeklyPlannerPage> createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  List<LessonPlanModel> _lessonPlans = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalPlans = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadLessonPlans();
  }

  Future<void> _loadLessonPlans({int page = 1}) async {
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
        _totalPlans = response.total;
        _totalPages = response.totalPages;
        _currentPage = response.page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _openLessonPlanDetail(LessonPlanModel plan) {
    // TODO: Navigate to lesson plan detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${plan.titleOfLesson ?? plan.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // NAVIGATE TO CREATE LESSON PLAN
  // ============================================================

  void _navigateToCreateLessonPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateLessonPlanPage()),
    ).then((_) => _loadLessonPlans());
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
            onPressed: () => _loadLessonPlans(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _navigateToCreateLessonPlan, // UPDATED
            tooltip: 'Create Lesson Plan',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadLessonPlans(),
        child: _buildContent(theme, colorScheme),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return _buildErrorWidget(theme, colorScheme);
    }

    if (_lessonPlans.isEmpty) {
      return _buildEmptyWidget(theme, colorScheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: _lessonPlans.length,
      itemBuilder: (context, index) {
        final plan = _lessonPlans[index];
        return _LessonPlanCard(
          plan: plan,
          onTap: () => _openLessonPlanDetail(plan),
        );
      },
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
              onPressed: () => _loadLessonPlans(),
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
              onPressed: _navigateToCreateLessonPlan, // UPDATED
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

// LESSON PLAN CARD
class _LessonPlanCard extends StatelessWidget {
  final LessonPlanModel plan;
  final VoidCallback onTap;

  const _LessonPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = _getStatusColor(plan.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.titleOfLesson ?? 'Lesson Plan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan.statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Subject
              if (plan.subject != null)
                Text(
                  plan.subject!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 6),
              // Classroom and Date
              Row(
                children: [
                  Icon(
                    Icons.class_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.classroom,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.lessonPlanDate ?? 'No date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Objective preview
              if (plan.objective != null)
                Text(
                  plan.objective!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
