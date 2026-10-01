import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/framework_domain_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_narrative_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/framework_domain_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ShareWithParentsPage extends StatefulWidget {
  const ShareWithParentsPage({super.key});

  @override
  State<ShareWithParentsPage> createState() => _ShareWithParentsPageState();
}

class _ShareWithParentsPageState extends State<ShareWithParentsPage> {
  // ── Students
  List<Student> _students = [];
  Student? _selectedStudent;
  bool _isLoadingStudents = true;

  // ── Domains
  List<FrameworkDomainModel> _domains = [];
  bool _isLoadingDomains = true;

  // ── Entries (one per domain)
  final Map<String, DomainNarrativeEntry> _entries = {};

  // ── Step tracking
  int _step = 0;
  bool _isSaving = false;

  // ── Report metadata
  DateTime _periodStart = DateTime.now().subtract(const Duration(days: 90));
  DateTime _periodEnd = DateTime.now();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  // One controller per domain
  final Map<String, TextEditingController> _narrativeControllers = {};
  final Map<String, TextEditingController> _summaryControllers = {};

  @override
  void initState() {
    super.initState();
    _academicYearController.text = _currentAcademicYear();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _narrativeControllers.values) {
      c.dispose();
    }
    for (final c in _summaryControllers.values) {
      c.dispose();
    }
    _introductionController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadStudents(), _loadDomains()]);
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

  Future<void> _loadDomains() async {
    setState(() => _isLoadingDomains = true);
    try {
      final repo = di.sl<FrameworkDomainRepository>();
      final response = await repo.getFrameworkDomains(page: 1, pageSize: 20);
      final sorted = List<FrameworkDomainModel>.from(response.items)
        ..sort((a, b) => a.sequence.compareTo(b.sequence));

      if (!mounted) return;
      setState(() {
        _domains = sorted;
        for (final d in sorted) {
          _entries[d.domainCode] = DomainNarrativeEntry(
            domainCode: d.domainCode,
            domainTitle: d.domainTitle,
          );
          _narrativeControllers[d.domainCode] = TextEditingController();
          _summaryControllers[d.domainCode] = TextEditingController();
        }
        _isLoadingDomains = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDomains = false);
      SnackbarUtils.showError(context, 'Failed to load domains: $e');
    }
  }

  // ── Navigation
  void _next() {
    if (_step == 0 && _selectedStudent == null) {
      SnackbarUtils.showError(context, 'Select a student first');
      return;
    }

    // Persist domain editor on the domain steps
    final domainIndex = _step - 2;
    if (domainIndex >= 0 && domainIndex < _domains.length) {
      final domain = _domains[domainIndex];
      _entries[domain.domainCode] = DomainNarrativeEntry(
        domainCode: domain.domainCode,
        domainTitle: domain.domainTitle,
        narrative: _narrativeControllers[domain.domainCode]?.text.trim() ?? '',
        summary: _summaryControllers[domain.domainCode]?.text.trim() ?? '',
      );
    }

    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _jumpToDomain(int domainIndex) {
    setState(() => _step = domainIndex + 2);
  }

  // ═════════════════════════════════════════════════════════════
  // SUBMIT — wired to real TMR API
  // ═════════════════════════════════════════════════════════════
  Future<void> _submit() async {
    // Persist last domain if applicable
    final lastDomainIndex = _step - 2;
    if (lastDomainIndex >= 0 && lastDomainIndex < _domains.length) {
      final domain = _domains[lastDomainIndex];
      _entries[domain.domainCode] = DomainNarrativeEntry(
        domainCode: domain.domainCode,
        domainTitle: domain.domainTitle,
        narrative: _narrativeControllers[domain.domainCode]?.text.trim() ?? '',
        summary: _summaryControllers[domain.domainCode]?.text.trim() ?? '',
      );
    }

    // Validate — every domain must have a narrative
    final missing = _domains
        .where((d) => (_entries[d.domainCode]?.narrative ?? '').isEmpty)
        .toList();
    if (missing.isNotEmpty) {
      SnackbarUtils.showError(
        context,
        'Please write a narrative for: '
        '${missing.map((d) => d.domainTitle).join(", ")}',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to submit');
        setState(() => _isSaving = false);
        return;
      }

      // ── Build the TMR payload matching the API schema
      final assessments = _domains
          .where((d) => (_entries[d.domainCode]?.narrative ?? '').isNotEmpty)
          .map(
            (d) => {
              'domain': d.domainTitle,
              'teacher_notes': _entries[d.domainCode]!.narrative,
            },
          )
          .toList();

      final intro = _introductionController.text.trim();
      final reportIntroduction = intro.isEmpty
          ? '<p>Three month progress report.</p>'
          : '<p>$intro</p>';

      final academicYear = _academicYearController.text.trim().isEmpty
          ? _currentAcademicYear()
          : _academicYearController.text.trim();

      final payload = {
        'student': _selectedStudent!.id,
        'classroom': _getClassroomForStudent(),
        'academic_year': academicYear,
        'period_start_date': _formatDate(_periodStart),
        'period_end_date': _formatDate(_periodEnd),
        'report_introduction': reportIntroduction,
        'assessments': assessments,
      };

      final repo = di.sl<ThreeMonthReportRepository>();
      final report = await repo.createThreeMonthReportTmr(payload);

      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showSuccess(
        context,
        'Submitted for ${_selectedStudent!.name}',
      );
      Navigator.pop(context, report);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to submit: $e');
    }
  }

  // ── Helpers
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _currentAcademicYear() {
    final now = DateTime.now();
    final startYear = now.month >= 9 ? now.year : now.year - 1;
    return '$startYear-${startYear + 1}';
  }

  String _getClassroomForStudent() {
    // TODO: replace with real classroom source from student
    return 'Test Room 3';
  }

  String _getMonthRange() {
    const names = [
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
    return '${names[_periodStart.month - 1]} ${_periodStart.day} – '
        '${names[_periodEnd.month - 1]} ${_periodEnd.day}, ${_periodEnd.year}';
  }

  Future<void> _pickPeriodStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodStart,
      firstDate: DateTime(2020),
      lastDate: _periodEnd,
    );
    if (picked != null) setState(() => _periodStart = picked);
  }

  Future<void> _pickPeriodEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodEnd,
      firstDate: _periodStart,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _periodEnd = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '3 Month Compilation',
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
          onPressed: _step == 0 ? () => Navigator.pop(context) : _back,
        ),
      ),
      body: _buildBody(theme, isDark),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoadingStudents || _isLoadingDomains) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_step == 0) return _buildStudentStep(theme);

    // Step 1: Meta (academic year, period dates, intro)
    if (_step == 1) return _buildMetaStep(theme, isDark);

    // Steps 2..N+1: Domain editors
    final domainIndex = _step - 2;
    if (domainIndex >= 0 && domainIndex < _domains.length) {
      return _buildDomainEditor(theme, isDark, domainIndex);
    }

    // Final: Review
    return _buildReviewStep(theme, isDark);
  }

  // ═════════════════════════════════════════════════════════════
  // STEP 0 — Student picker
  // ═════════════════════════════════════════════════════════════
  Widget _buildStudentStep(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who is this for?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick the child you are writing this 3-month narrative for.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          if (_students.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No students available'),
            )
          else
            ..._students.map((s) {
              final selected = _selectedStudent?.id == s.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedStudent = s),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.08)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.15),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s.name.trim().isEmpty
                                ? '?'
                                : s.name.trim()[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (s.ageRange.isNotEmpty)
                                Text(
                                  s.ageRange,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // STEP 1 — Academic Year + Period dates + Introduction
  // ═════════════════════════════════════════════════════════════
  Widget _buildMetaStep(ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set the academic year, period dates, and a short introduction.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Academic Year
          Text(
            'Academic Year',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Format: YYYY-YYYY (e.g. 2026-2027)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _academicYearController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: '2026-2027',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.school_outlined,
                  color: colorScheme.primary,
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Period Start
          _dateField(
            theme: theme,
            label: 'Period Start',
            value: _periodStart,
            onTap: _pickPeriodStart,
          ),
          const SizedBox(height: 16),

          // Period End
          _dateField(
            theme: theme,
            label: 'Period End',
            value: _periodEnd,
            onTap: _pickPeriodEnd,
          ),
          const SizedBox(height: 24),

          // Introduction
          Text(
            'Report Introduction',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A short welcome message that appears at the top of the report.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _introductionController,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Welcome to the first term report!',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required ThemeData theme,
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(value),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // STEP 2..N+1 — Domain editor
  // ═════════════════════════════════════════════════════════════
  Widget _buildDomainEditor(ThemeData theme, bool isDark, int domainIndex) {
    final domain = _domains[domainIndex];
    final colorScheme = theme.colorScheme;
    final accent = _accentForDomain(domain.domainCode, colorScheme);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Domain ${domainIndex + 1} of ${_domains.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${_entries.values.where((e) => e.narrative.isNotEmpty).length} filled',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (domainIndex + 1) / _domains.length,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForDomain(domain.domainCode),
                  color: accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        domain.domainCode,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.5,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      domain.domainTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Narrative',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Describe what ${_selectedStudent?.name ?? "the child"} '
            'demonstrated in this domain over the last 3 months.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _narrativeControllers[domain.domainCode],
              minLines: 6,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Write the narrative for this domain...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Summary',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A short 1–2 sentence conclusion for the parents.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _summaryControllers[domain.domainCode],
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Brief summary...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // FINAL — Review & Submit
  // ═════════════════════════════════════════════════════════════
  Widget _buildReviewStep(ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'One last check before you submit.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_rounded, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedStudent?.name ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _academicYearController.text.trim().isEmpty
                          ? _currentAcademicYear()
                          : _academicYearController.text.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getMonthRange(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (_introductionController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _introductionController.text.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          ..._domains.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            final entry = _entries[d.domainCode]!;
            final filled = entry.narrative.isNotEmpty;
            final accent = _accentForDomain(d.domainCode, colorScheme);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _jumpToDomain(i),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: filled
                          ? AppColors.success.withValues(alpha: 0.35)
                          : colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconForDomain(d.domainCode),
                          color: accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.domainTitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              filled
                                  ? (entry.narrative.length > 60
                                        ? '${entry.narrative.substring(0, 60)}…'
                                        : entry.narrative)
                                  : 'Not written yet',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: filled
                                    ? colorScheme.onSurfaceVariant
                                    : AppColors.warningDark,
                                fontStyle: filled
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        filled
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        color: filled
                            ? AppColors.success
                            : colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // Bottom bar
  // ═════════════════════════════════════════════════════════════
  Widget _buildBottomBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isReview = _step > _domains.length + 1;
    final isFirst = _step == 0;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            if (!isFirst) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _back,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : isReview
                      ? _submit
                      : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isFirst
                                  ? 'Start'
                                  : isReview
                                  ? 'Submit to Admin'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (!isReview) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ],
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
  // Icon / accent helpers
  // ═════════════════════════════════════════════════════════════
  IconData _iconForDomain(String code) {
    switch (code.toUpperCase()) {
      case 'AL':
        return Icons.lightbulb_outline_rounded;
      case 'CA':
        return Icons.palette_outlined;
      case 'LLC':
        return Icons.chat_bubble_outline_rounded;
      case 'MA':
        return Icons.calculate_outlined;
      case 'PDH':
        return Icons.fitness_center_outlined;
      case 'ST':
        return Icons.science_outlined;
      case 'SED':
        return Icons.people_outline_rounded;
      case 'SS':
        return Icons.public_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _accentForDomain(String code, ColorScheme colorScheme) {
    switch (code.toUpperCase()) {
      case 'AL':
        return const Color(0xFFF59E0B);
      case 'CA':
        return const Color(0xFFEC4899);
      case 'LLC':
        return const Color(0xFF3B82F6);
      case 'MA':
        return const Color(0xFF8B5CF6);
      case 'PDH':
        return const Color(0xFF10B981);
      case 'ST':
        return const Color(0xFF06B6D4);
      case 'SED':
        return const Color(0xFFEF4444);
      case 'SS':
        return const Color(0xFF6366F1);
      default:
        return colorScheme.primary;
    }
  }
}
