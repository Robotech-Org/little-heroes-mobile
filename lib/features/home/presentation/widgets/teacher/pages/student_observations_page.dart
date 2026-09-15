import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/observation_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'observation_detail_page.dart';

class StudentObservationsPage extends StatefulWidget {
  final Student student;

  const StudentObservationsPage({super.key, required this.student});

  @override
  State<StudentObservationsPage> createState() =>
      _StudentObservationsPageState();
}

class _StudentObservationsPageState extends State<StudentObservationsPage> {
  List<ObservationModel> _observations = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
          _errorMessage = 'Please login to view observations';
        });
        return;
      }

      final repo = di.sl<ObservationRepository>();
      // Pass `student` if the backend supports filtering — otherwise
      // fetch and filter client-side.
      final response = await repo.getObservations(
        page: 1,
        pageSize: 100,
        student: widget.student.id,
      );

      final filtered = response.items
          .where((o) => o.student == widget.student.id)
          .toList();

      setState(() {
        _observations = filtered;
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

  void _openDetail(ObservationModel observation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pass both so the detail page shows the skeleton immediately
        // AND refetches to fill in photo/notes.
        builder: (_) => ObservationDetailPage(
          observation: observation,
          observationId: observation.id,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.student.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(theme, colorScheme, isDark),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return _buildErrorState(theme, colorScheme);
    }

    if (_observations.isEmpty) {
      return _buildEmpty(theme, colorScheme);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        physics: const BouncingScrollPhysics(),
        itemCount: _observations.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(theme, colorScheme, isDark);
          }
          final obs = _observations[index - 1];
          return _ObservationCard(
            observation: obs,
            onTap: () => _openDetail(obs),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final name = widget.student.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
            colorScheme.primary.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_observations.length} '
                  '${_observations.length == 1 ? 'observation' : 'observations'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              Icons.fact_check_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No observations yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no observations recorded for '
              '${widget.student.name}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
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
              'Failed to load observations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
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
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final ObservationModel observation;
  final VoidCallback onTap;
  final bool isDark;

  const _ObservationCard({
    required this.observation,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If list already has notes, use them. Otherwise fetch detail lazily.
    final hasNotesInList =
        observation.observationNotes != null &&
        observation.observationNotes!.isNotEmpty;

    final hasPhotoInList =
        observation.observationPhoto != null &&
        observation.observationPhoto!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      observation.observationClassSchedule.isEmpty
                          ? 'Observation'
                          : observation.observationClassSchedule,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (hasPhotoInList) _photoBadge(theme, colorScheme),
                ],
              ),

              const SizedBox(height: 8),

              // ── Date / teacher row ────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(observation.observationDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      observation.teacher.isEmpty ? '—' : observation.teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Notes: use list data, or fetch detail if missing ──
              if (hasNotesInList)
                _notesBox(theme, colorScheme, observation.observationNotes!)
              else
                _LazyNotesLoader(observationId: observation.id, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoBadge(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_rounded, size: 12, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            'Photo',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesBox(ThemeData theme, ColorScheme colorScheme, String note) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.3 : 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_rounded, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Teacher Note',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
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

// ────────────────────────────────────────────────────────────
// Lazy loader: fetches the observation detail and shows notes
// ────────────────────────────────────────────────────────────
class _LazyNotesLoader extends StatefulWidget {
  final String observationId;
  final bool isDark;

  const _LazyNotesLoader({required this.observationId, required this.isDark});

  @override
  State<_LazyNotesLoader> createState() => _LazyNotesLoaderState();
}

class _LazyNotesLoaderState extends State<_LazyNotesLoader> {
  ObservationModel? _full;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final repo = di.sl<ObservationRepository>();
      final result = await repo.getObservation(widget.observationId);
      if (!mounted) return;
      setState(() {
        _full = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    final note = _full?.observationNotes;
    if (note == null || note.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(
            alpha: widget.isDark ? 0.3 : 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_rounded, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Teacher Note',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
