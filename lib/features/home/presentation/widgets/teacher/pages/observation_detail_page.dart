import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/observation_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ObservationDetailPage extends StatefulWidget {
  final ObservationModel? observation;
  final String? observationId;

  const ObservationDetailPage({super.key, this.observation, this.observationId})
    : assert(
        observation != null || observationId != null,
        'Provide either an observation or an observationId',
      );

  @override
  State<ObservationDetailPage> createState() => _ObservationDetailPageState();
}

class _ObservationDetailPageState extends State<ObservationDetailPage> {
  ObservationModel? _observation;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Always fetch fresh — the list response is missing notes/photo.
    _observation = widget.observation; // show quickly if we have something
    _load(); // then refresh from server
  }

  Future<void> _load() async {
    final id = widget.observationId ?? widget.observation?.id;
    if (id == null || id.isEmpty) {
      setState(() => _error = 'Missing observation id');
      return;
    }

    setState(() {
      _loading = _observation == null;
      _error = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _loading = false;
          _error = 'Please login to view this observation';
        });
        return;
      }

      final repo = di.sl<ObservationRepository>();
      final result = await repo.getObservation(id);

      if (!mounted) return;
      setState(() {
        _observation = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // If we already had a partial model, keep it — just show a toast
        if (_observation == null) {
          _error = e.toString();
        } else {
          SnackbarUtils.showError(context, 'Could not refresh details');
        }
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
          'Observation',
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
    final o = _observation;
    if (o == null) return _buildEmpty(theme, colorScheme);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          _buildStudentHeader(theme, colorScheme, isDark, o),
          const SizedBox(height: 20),

          // Activity banner (class schedule)
          _buildActivityBanner(theme, colorScheme, o),
          const SizedBox(height: 20),

          // Meta info
          _buildMetaCard(theme, colorScheme, isDark, o),

          // Photo
          if (o.hasPhoto) ...[
            const SizedBox(height: 20),
            _sectionLabel(theme, colorScheme, 'Photo'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _isImage(o.observationPhoto!)
                  ? AuthenticatedImage(
                      imageUrl: o.observationPhoto!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: Container(
                        height: 240,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: Container(
                        height: 240,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined, size: 48),
                        ),
                      ),
                    )
                  : _buildFileTile(
                      theme,
                      colorScheme,
                      isDark,
                      o.fileName ?? 'File',
                      o.observationPhoto!,
                    ),
            ),
          ],

          // Notes
          const SizedBox(height: 20),
          _sectionLabel(theme, colorScheme, 'Observation Note'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              o.hasNotes ? o.observationNotes! : 'No notes recorded.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),

          // Tagged students
          if (o.taggedStudents.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel(theme, colorScheme, 'Tagged Students'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: o.taggedStudents.map((s) {
                final label = s is Map
                    ? (s['student_name']?.toString() ??
                          s['student']?.toString() ??
                          s.toString())
                    : s.toString();
                return Chip(
                  label: Text(label),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Recorded ${_formatDateTime(o.creation)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, ColorScheme colorScheme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildStudentHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    ObservationModel o,
  ) {
    final initial = o.student.isEmpty ? '?' : o.student[0].toUpperCase();

    return Container(
      width: double.infinity,
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
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.20),
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
                  'Student',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  o.student.isEmpty ? 'Unknown' : o.student,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBanner(
    ThemeData theme,
    ColorScheme colorScheme,
    ObservationModel o,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.book_rounded,
                size: 16,
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'Activity',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            o.observationClassSchedule.isEmpty
                ? 'No activity'
                : o.observationClassSchedule,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    ObservationModel o,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          _metaRow(
            theme,
            colorScheme,
            Icons.calendar_today_rounded,
            'Date',
            _formatDate(o.observationDate),
          ),
          const SizedBox(height: 12),
          _metaRow(
            theme,
            colorScheme,
            Icons.person_outline_rounded,
            'Teacher',
            o.teacher.isEmpty ? '—' : o.teacher,
          ),
        ],
      ),
    );
  }

  Widget _metaRow(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileTile(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    String name,
    String url,
  ) {
    return InkWell(
      onTap: () => SnackbarUtils.showSuccess(context, 'Opening $name'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to open',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  bool _isImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.contains('.jpg?') ||
        lower.contains('.png?');
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final cleaned = iso.replaceFirst(' ', 'T');
      final d = DateTime.parse(cleaned);
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
      final cleaned = iso.replaceFirst(' ', 'T');
      final d = DateTime.parse(cleaned);
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
              'Could not load observation',
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
              Icons.fact_check_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Observation not found',
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
