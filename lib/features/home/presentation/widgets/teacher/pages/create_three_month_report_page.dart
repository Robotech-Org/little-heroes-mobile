import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/assessment_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/classroom_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/competency_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/level_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/competency_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'three_month_report_detail_page.dart';

class CreateThreeMonthReportPage extends StatefulWidget {
  const CreateThreeMonthReportPage({super.key});

  @override
  State<CreateThreeMonthReportPage> createState() =>
      _CreateThreeMonthReportPageState();
}

class _CreateThreeMonthReportPageState
    extends State<CreateThreeMonthReportPage> {
  // Data
  List<Student> _students = [];
  List<ClassroomModel> _classrooms = [];
  List<CompetencyModel> _competencies = [];

  // Selection
  Student? _selectedStudent;
  ClassroomModel? _selectedClassroom;
  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;
  String _selectedStatus = 'Submitted';

  // Competency selection
  String? _selectedDomain;
  final Map<String, TextEditingController> _noteControllers = {};

  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  /// The teacher-built list of assessments (filled as they rate competencies).
  final List<AssessmentModel> _assessments = [];

  // Loading
  bool _isLoadingStudents = true;
  bool _isLoadingClassrooms = true;
  bool _isLoadingCompetencies = true;
  bool _isSubmitting = false;

  final List<String> _months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<int> get _years {
    final now = DateTime.now().year;
    return [now - 1, now, now + 1];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    _introductionController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStudents(),
      _loadClassrooms(),
      _loadCompetencies(),
    ]);
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isLoadingStudents = false);
        return;
      }
      final repo = di.sl<StudentRepository>();
      final response = await repo.getStudents(page: 1, pageSize: 100);
      if (!mounted) return;
      setState(() {
        _students = response.items;
        _isLoadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingStudents = false);
      SnackbarUtils.showError(context, 'Failed to load students: $e');
    }
  }

  Future<void> _loadClassrooms() async {
    setState(() => _isLoadingClassrooms = true);
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isLoadingClassrooms = false);
        return;
      }
      final repo = di.sl<ClassroomRepository>();
      final response = await repo.getClassrooms(page: 1, pageSize: 20);
      if (!mounted) return;
      setState(() {
        _classrooms = response.items;
        _isLoadingClassrooms = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingClassrooms = false);
    }
  }

  Future<void> _loadCompetencies() async {
    setState(() => _isLoadingCompetencies = true);
    try {
      final repo = di.sl<CompetencyRepository>();
      final response = await repo.getCompetencies(page: 1, pageSize: 100);
      if (!mounted) return;
      setState(() {
        _competencies = response.items;
        _isLoadingCompetencies = false;
        if (_competencies.isNotEmpty) {
          _selectedDomain = _competencies.first.domain;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCompetencies = false);
      // debugPrint('Failed to load competencies: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════
  // CREATE
  // ═════════════════════════════════════════════════════════════
  Future<void> _createReport() async {
    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }
    if (_selectedClassroom == null) {
      SnackbarUtils.showError(context, 'Please select a classroom');
      return;
    }
    if (_assessments.isEmpty) {
      SnackbarUtils.showError(
        context,
        'Add at least one assessment before creating',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isSubmitting = false);
        SnackbarUtils.showError(context, 'Please login to continue');
        return;
      }

      // Build assessments payload (only those with a level selected).
      final assessedItems = _assessments
          .where((a) => a.levelAchieved >= 0)
          .toList();

      final assessmentsData = assessedItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final a = entry.value;

        final competency = _competencies.firstWhere(
          (c) => c.competencyCode == a.competency,
          orElse: () => CompetencyModel(
            name: a.competency,
            domain: a.domain,
            domainTitle: '',
            competencyCode: a.competency,
            title: a.competencyTitle,
            sequence: 0,
            maxLevel: 5,
            isActive: 1,
            creation: '',
            modified: '',
            levels: [],
          ),
        );

        final noteText = _noteControllers[a.competency]?.text ?? a.notes ?? '';

        return {
          'competency': competency.competencyCode,
          'level_achieved': a.levelAchieved,
          'notes': noteText,
          'domain': competency.domain,
          'competency_title': competency.title,
          'idx': idx + 1,
        };
      }).toList();

      final data = {
        'student': _selectedStudent!.id,
        'student_name': _selectedStudent!.name,
        'classroom': _selectedClassroom!.classroomName,
        // 'month': _selectedMonth,
        // "period_start_date": "2026-09-01",
        // "period_end_date": "2026-11-30",
        // 'academic_year': "2026-2027",
        'report_date': DateTime.now().toIso8601String().split('T').first,
        // 'status': "Submitted",
        'teacher': authState.user.fullName,
        'assessments': assessmentsData,
        'report_introduction': _wrapHtml(_introductionController.text.trim()),
        'report_summary': _wrapHtml(_summaryController.text.trim()),
      };

      final repo = di.sl<ThreeMonthReportRepository>();
      final created = await repo.createThreeMonthReport(data);

      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'Report created');

      // Replace so back button returns to the list, not to this create page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThreeMonthReportDetailPage(reportName: created.name),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      SnackbarUtils.showError(
        context,
        'Failed to create: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  /// Wrap plain text in <p>...</p> so Frappe renders it in rich text fields.
  /// Each blank-line-separated paragraph becomes its own <p> tag.
  String _wrapHtml(String input) {
    if (input.isEmpty) return '';
    return input
        .split(RegExp(r'\n\s*\n'))
        .map((para) => '<p>${para.trim().replaceAll('\n', '<br>')}</p>')
        .join();
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'New 3 Month Report',
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
          TextButton(
            onPressed: _isSubmitting ? null : _createReport,
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : const Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: _isLoadingStudents || _isLoadingClassrooms || _isLoadingCompetencies
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Setup card ───────────────────────────
                  _buildSetupCard(theme, colorScheme, isDark),
                  const SizedBox(height: 20),
                  // ── NEW: Report Introduction & Summary ───
                  _buildNarrativeCard(theme, colorScheme, isDark),
                  const SizedBox(height: 20),

                  // ── Domain selector ──────────────────────
                  _buildDomainSelector(theme, colorScheme),
                  const SizedBox(height: 16),

                  // ── Competencies ─────────────────────────
                  _buildDevelopmentFrameworks(theme, colorScheme),

                  const SizedBox(height: 24),

                  // ── Submit button ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _createReport,
                      icon: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _isSubmitting
                            ? 'Creating...'
                            : 'Create Report (${_assessments.where((a) => a.levelAchieved >= 0).length} assessed)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // NEW — Report Introduction & Summary
  // ═════════════════════════════════════════════════════════════
  Widget _buildNarrativeCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Report Narrative',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Introduction ─────────────────────────
          _fieldLabel(theme, colorScheme, 'Introduction'),
          const SizedBox(height: 6),
          TextField(
            controller: _introductionController,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'General introduction about the child\'s progress this period...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.25),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 14),

          // ── Summary ──────────────────────────────
          _fieldLabel(theme, colorScheme, 'Summary (Optional)'),
          const SizedBox(height: 6),
          TextField(
            controller: _summaryController,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'Brief summary / overall observations for this reporting period...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.25),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  // ── Setup card with student/classroom/month/year ─────────────
  Widget _buildSetupCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student
          _fieldLabel(theme, colorScheme, 'Student'),
          const SizedBox(height: 6),
          _buildStudentDropdown(theme, colorScheme, isDark),
          const SizedBox(height: 14),

          // Classroom
          _fieldLabel(theme, colorScheme, 'Classroom'),
          const SizedBox(height: 6),
          _buildClassroomDropdown(theme, colorScheme, isDark),
          const SizedBox(height: 14),

          // Month + Year
          _fieldLabel(theme, colorScheme, 'Reporting Period'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildMonthDropdown(theme, colorScheme, isDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: _buildYearDropdown(theme, colorScheme, isDark),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status
          _fieldLabel(theme, colorScheme, 'Initial Status'),
          const SizedBox(height: 6),
          _buildStatusSelector(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _fieldLabel(ThemeData theme, ColorScheme colorScheme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Dropdowns ─────────────────────────────────────────────
  Widget _buildStudentDropdown(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Student>(
          value: _selectedStudent,
          isExpanded: true,
          hint: const Text('Select a student...'),
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: _students.map((s) {
            return DropdownMenuItem<Student>(value: s, child: Text(s.name));
          }).toList(),
          onChanged: _isSubmitting
              ? null
              : (v) => setState(() => _selectedStudent = v),
        ),
      ),
    );
  }

  Widget _buildClassroomDropdown(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ClassroomModel>(
          value: _selectedClassroom,
          isExpanded: true,
          hint: const Text('Select a classroom...'),
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: _classrooms.map((c) {
            return DropdownMenuItem<ClassroomModel>(
              value: c,
              child: Text(c.classroomName),
            );
          }).toList(),
          onChanged: _isSubmitting
              ? null
              : (v) => setState(() => _selectedClassroom = v),
        ),
      ),
    );
  }

  Widget _buildMonthDropdown(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: _months
              .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
              .toList(),
          onChanged: _isSubmitting
              ? null
              : (v) => setState(() => _selectedMonth = v ?? 'January'),
        ),
      ),
    );
  }

  Widget _buildYearDropdown(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: _years
              .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
              .toList(),
          onChanged: _isSubmitting
              ? null
              : (v) => setState(() => _selectedYear = v ?? DateTime.now().year),
        ),
      ),
    );
  }

  Widget _buildStatusSelector(ThemeData theme, ColorScheme colorScheme) {
    final options = ['Submitted'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((s) {
        final isSelected = _selectedStatus == s;
        return GestureDetector(
          onTap: _isSubmitting
              ? null
              : () => setState(() => _selectedStatus = s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              s,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // COMPETENCY GRID — mirrors the detail page
  // ═════════════════════════════════════════════════════════════
  Widget _buildDomainSelector(ThemeData theme, ColorScheme colorScheme) {
    final domains = _competencies.map((c) => c.domain).toSet().toList()..sort();
    if (domains.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedDomain,
          isExpanded: true,
          hint: Text(
            'Select Domain',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          icon: Icon(Icons.arrow_drop_down_rounded, color: colorScheme.primary),
          dropdownColor: colorScheme.surface,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.view_list_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Domains',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            ...domains.map((domain) {
              final count = _competencies
                  .where((c) => c.domain == domain)
                  .length;
              final assessed = _assessments
                  .where((a) => a.domain == domain && a.levelAchieved >= 0)
                  .length;

              return DropdownMenuItem<String?>(
                value: domain,
                child: Row(
                  children: [
                    Icon(
                      _getDomainIcon(domain),
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(domain, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$assessed/$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (v) => setState(() => _selectedDomain = v),
        ),
      ),
    );
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case 'Approaches to Learning':
        return Icons.lightbulb_outline_rounded;
      case 'Creative Art':
        return Icons.palette_outlined;
      case 'Language, Literacy and Communication':
        return Icons.chat_bubble_outline_rounded;
      case 'Mathematics':
        return Icons.calculate_outlined;
      case 'Physical Development and Health':
        return Icons.fitness_center_outlined;
      case 'Science and Technology':
        return Icons.science_outlined;
      case 'Social and Emotional Development':
        return Icons.people_outline_rounded;
      case 'Social Studies':
        return Icons.public_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Widget _buildDevelopmentFrameworks(ThemeData theme, ColorScheme colorScheme) {
    if (_competencies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No framework competencies available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    List<CompetencyModel> filtered;
    if (_selectedDomain == null) {
      filtered = List.from(_competencies);
    } else {
      filtered = _competencies
          .where((c) => c.domain == _selectedDomain)
          .toList();
    }
    filtered.sort((a, b) => a.sequence.compareTo(b.sequence));

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No competencies in this domain',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedDomain != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDomainIcon(_selectedDomain!),
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDomain!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${filtered.length} competencies • '
                        '${_assessments.where((a) => a.domain == _selectedDomain && a.levelAchieved >= 0).length} assessed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],
          ...filtered.map((competency) {
            final idx = _assessments.indexWhere(
              (a) => a.competency == competency.competencyCode,
            );
            final hasAssessment = idx >= 0;
            final existing = hasAssessment
                ? _assessments[idx]
                : AssessmentModel(
                    name: '',
                    domain: competency.domain,
                    competency: competency.competencyCode,
                    competencyTitle: competency.title,
                    levelAchieved: -1,
                    notes: '',
                  );
            final level = hasAssessment && existing.levelAchieved >= 0
                ? competency.levels.firstWhere(
                    (l) => l.level == existing.levelAchieved,
                    orElse: () => LevelModel(level: 0, description: ''),
                  )
                : null;

            return _buildFrameworkCard(
              theme,
              colorScheme,
              competency,
              existing,
              level,
              hasAssessment && existing.levelAchieved >= 0,
              hasAssessment ? idx : -1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFrameworkCard(
    ThemeData theme,
    ColorScheme colorScheme,
    CompetencyModel competency,
    AssessmentModel assessment,
    LevelModel? level,
    bool hasLevel,
    int index,
  ) {
    final controller = _noteControllers.putIfAbsent(
      competency.competencyCode,
      () => TextEditingController(text: assessment.notes ?? ''),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLevel
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            competency.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            competency.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      competency.domain,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (index < 0) {
                    setState(() {
                      _assessments.add(
                        AssessmentModel(
                          name: '',
                          domain: competency.domain,
                          competency: competency.competencyCode,
                          competencyTitle: competency.title,
                          levelAchieved: 0,
                          notes: controller.text,
                        ),
                      );
                    });
                  } else {
                    _showLevelSelector(context, index);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasLevel
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasLevel
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasLevel ? 'Level ${level!.level}' : 'Select Level',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasLevel
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 18,
                        color: hasLevel
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Level 1..5 quick bar
          Row(
            children: List.generate(5, (i) {
              final levelNumber = i + 1;
              final isSelected =
                  hasLevel && level != null && level.level == levelNumber;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (index < 0) {
                      setState(() {
                        _assessments.add(
                          AssessmentModel(
                            name: '',
                            domain: competency.domain,
                            competency: competency.competencyCode,
                            competencyTitle: competency.title,
                            levelAchieved: levelNumber,
                            notes: controller.text,
                          ),
                        );
                      });
                    } else {
                      final selectedLevel = competency.levels.firstWhere(
                        (l) => l.level == levelNumber,
                        orElse: () =>
                            LevelModel(level: levelNumber, description: ''),
                      );
                      setState(() {
                        _assessments[index] = AssessmentModel(
                          name: _assessments[index].name,
                          domain: competency.domain,
                          competency: competency.competencyCode,
                          competencyTitle: competency.title,
                          levelAchieved: levelNumber,
                          levelDescription: selectedLevel.description,
                          notes: controller.text,
                        );
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '$levelNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w400,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (hasLevel && level != null && level.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              level.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],

          // Notes always editable in create mode
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 2,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Add notes...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            onChanged: (value) {
              if (index >= 0 && index < _assessments.length) {
                final prev = _assessments[index];
                _assessments[index] = AssessmentModel(
                  name: prev.name,
                  domain: prev.domain,
                  competency: prev.competency,
                  competencyTitle: prev.competencyTitle,
                  levelAchieved: prev.levelAchieved,
                  levelDescription: prev.levelDescription,
                  notes: value,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLevelSelector(BuildContext context, int index) {
    final assessment = _assessments[index];
    final competency = _competencies.firstWhere(
      (c) => c.competencyCode == assessment.competency,
      orElse: () => CompetencyModel(
        name: assessment.competency,
        domain: assessment.domain,
        domainTitle: '',
        competencyCode: assessment.competency,
        title: assessment.competencyTitle,
        sequence: 0,
        maxLevel: 5,
        isActive: 1,
        creation: '',
        modified: '',
        levels: [],
      ),
    );

    if (competency.levels.isEmpty) {
      SnackbarUtils.showError(context, 'No levels available');
      return;
    }

    final levels = competency.levels.toList()
      ..sort((a, b) => a.level.compareTo(b.level));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Level',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                competency.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: levels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, li) {
                    final level = levels[li];
                    final isSelected = level.level == assessment.levelAchieved;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _assessments[index] = AssessmentModel(
                            name: assessment.name,
                            domain: competency.domain,
                            competency: competency.competencyCode,
                            competencyTitle: competency.title,
                            levelAchieved: level.level,
                            levelDescription: level.description,
                            notes: assessment.notes,
                          );
                        });
                        Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 140,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceVariant
                                    .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${level.level}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              level.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
