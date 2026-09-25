import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class DailyReportPage extends StatefulWidget {
  final String studentName;
  final String studentId;

  const DailyReportPage({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  final TextEditingController _noteController = TextEditingController();
  DailyReportModel? _report;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
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
          _errorMessage = 'Please login to view report';
        });
        return;
      }

      final repository = di.sl<DailyReportRepository>();

      final today = DateTime.now();
      final reportDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final response = await repository.getDailyReports(
        page: 1,
        pageSize: 20,
        student: widget.studentId,
        startDate: reportDate,
        endDate: reportDate,
      );

      if (!mounted) return;

      setState(() {
        _report = response.items.isNotEmpty ? response.items.first : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _sendNote() {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a note first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note sent to teacher.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _noteController.clear();
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back button ───────────────────────
                    SizedBox(
                      height: 42,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 17,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // ── Header ────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Report',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                widget.studentName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_report != null)
                          StatusPill(
                            text: _report!.dailyReportStatus,
                            backgroundColor: colors.primaryContainer,
                            textColor: colors.onPrimaryContainer,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(DateTime.now()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_isError)
                      _buildErrorWidget(theme, colors)
                    else if (_report == null)
                      _buildEmptyWidget(theme, colors)
                    else ...[
                      // ═══════════════════════════════════════
                      // DATA-DRIVEN SECTIONS
                      // ═══════════════════════════════════════
                      ..._buildReportSections(theme, colors, _report!),

                      const SizedBox(height: 32),

                      // ── Teacher's note ────────────────────
                      _buildTeacherNote(theme, colors, _report!),
                      const SizedBox(height: 32),

                      // ── Parent's note input ───────────────
                      Text(
                        'NOTE TO TEACHER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colors.outlineVariant,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _noteController,
                          minLines: 4,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            height: 1.4,
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write a note to the teacher...',
                            hintStyle: TextStyle(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.65,
                              ),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _sendNote,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text(
                            'Send Note',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // REPORT SECTIONS (data-driven, only shows what exists)
  // ═════════════════════════════════════════════════════════════
  List<Widget> _buildReportSections(
    ThemeData theme,
    ColorScheme colors,
    DailyReportModel report,
  ) {
    final sections = <Widget>[];

    void addSection({
      required String title,
      required IconData icon,
      required List<String> chips,
      String? notes,
      String? extra,
    }) {
      final hasChips = chips.any((c) => c.trim().isNotEmpty);
      final hasNotes = notes != null && notes.trim().isNotEmpty;
      final hasExtra = extra != null && extra.trim().isNotEmpty;

      if (!hasChips && !hasNotes && !hasExtra) return;

      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 26));
      }

      sections.add(
        ReportItem(
          title: title,
          icon: icon,
          values: chips.where((c) => c.trim().isNotEmpty).toList(),
          notes: hasNotes ? notes : null,
          extra: hasExtra ? extra : null,
        ),
      );
    }

    // ── Meals & Snacks ─────────────────────────────
    addSection(
      title: 'MEALS & SNACKS',
      icon: Icons.restaurant_rounded,
      chips: [report.mealsAndSnacks],
      notes: report.mealsAndSnacksNotes,
    );

    // ── Nap Time ───────────────────────────────────
    addSection(
      title: 'NAP TIME',
      icon: Icons.bed_rounded,
      chips: [report.napTime],
      notes: report.napTimeNotes,
      extra: report.napDuration.isNotEmpty
          ? 'Duration: ${report.napDuration}'
          : null,
    );

    // ── Mood & Behavior ────────────────────────────
    addSection(
      title: 'MOOD & BEHAVIOR',
      icon: Icons.emoji_emotions_rounded,
      chips: [report.moodAndBehavior],
      notes: report.moodAndBehaviorNotes,
    );

    // ── Learning & Play ────────────────────────────
    addSection(
      title: 'LEARNING & PLAY',
      icon: Icons.toys_rounded,
      chips: [report.learningAndPlayActivities],
      notes: report.learningAndPlayActivitiesNotes,
    );

    // ── Diaper / Toilet ────────────────────────────
    addSection(
      title: 'DIAPER / TOILET TRAINING',
      icon: Icons.child_care_rounded,
      chips: [report.diaperToiletTraining],
      notes: report.diaperToiletTrainingNotes,
    );

    // ── Health & Hygiene ───────────────────────────
    addSection(
      title: 'HEALTH & HYGIENE',
      icon: Icons.health_and_safety_rounded,
      chips: [report.healthAndHygiene],
      notes: report.healthCheckNotes,
    );

    // ── Reminders ──────────────────────────────────
    final reminders = <String>[];
    if (report.reminderBringClothes) {
      reminders.add(
        report.reminderClothesDetails.trim().isNotEmpty
            ? 'Bring clothes: ${report.reminderClothesDetails}'
            : 'Bring extra clothes',
      );
    }
    if (report.reminderBringToyBlanket) {
      reminders.add(
        report.reminderToyBlanketDetails.trim().isNotEmpty
            ? 'Bring toy/blanket: ${report.reminderToyBlanketDetails}'
            : 'Bring toy / blanket',
      );
    }
    if (report.reminderUpcomingEvent) {
      reminders.add(
        report.reminderUpcomingEventDetails.trim().isNotEmpty
            ? 'Event: ${report.reminderUpcomingEventDetails}'
            : 'Upcoming event',
      );
    }
    if (report.reminderOther) {
      reminders.add(
        report.reminderOtherDetails.trim().isNotEmpty
            ? report.reminderOtherDetails
            : 'Other reminder',
      );
    }

    if (reminders.isNotEmpty) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 26));
      sections.add(
        ReportItem(
          title: 'REMINDERS',
          icon: Icons.notifications_active_rounded,
          values: reminders,
        ),
      );
    }

    // ── Special notes ──────────────────────────────
    if (report.specialNotesAndReminders.trim().isNotEmpty) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 26));
      sections.add(
        ReportItem(
          title: 'SPECIAL NOTES',
          icon: Icons.sticky_note_2_outlined,
          values: const [],
          notes: report.specialNotesAndReminders,
        ),
      );
    }

    return sections;
  }

  // ═════════════════════════════════════════════════════════════
  // Teacher's note (reads dailyReportNotes)
  // ═════════════════════════════════════════════════════════════
  Widget _buildTeacherNote(
    ThemeData theme,
    ColorScheme colors,
    DailyReportModel report,
  ) {
    final note = report.dailyReportNotes;
    if (note == null || note.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 14,
              color: colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              "TEACHER'S NOTE",
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 18,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load report',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No Report Found',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No daily report found for ${widget.studentName} today.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ═════════════════════════════════════════════════════════════
// REPORT ITEM — title + icon + chips + optional notes/extra
// ═════════════════════════════════════════════════════════════
class ReportItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> values;
  final String? notes;
  final String? extra;

  const ReportItem({
    super.key,
    required this.title,
    required this.icon,
    required this.values,
    this.notes,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(icon, size: 14, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Value chips
        if (values.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((value) {
              return StatusPill(
                text: value,
                backgroundColor: colors.secondaryContainer,
                textColor: colors.onSecondaryContainer,
              );
            }).toList(),
          ),

        // Extra (e.g. nap duration)
        if (extra != null && extra!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            extra!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        // Notes
        if (notes != null && notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STATUS PILL
// ═════════════════════════════════════════════════════════════
class StatusPill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const StatusPill({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
