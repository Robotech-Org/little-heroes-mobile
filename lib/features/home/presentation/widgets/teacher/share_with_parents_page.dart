import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/framework_domain_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_narrative_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/framework_domain_repository.dart';
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
  int _step = 0; // 0 = student picker, 1..N = domain editors, N+1 = review
  bool _isSaving = false;

  // One controller per domain, created lazily.
  final Map<String, TextEditingController> _narrativeControllers = {};
  final Map<String, TextEditingController> _summaryControllers = {};

  @override
  void initState() {
    super.initState();
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
        // Seed an empty entry + controllers for each domain
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
    if (_step > 0 && _step <= _domains.length) {
      // Persist current domain entry
      final domain = _domains[_step - 1];
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
    setState(() => _step = domainIndex + 1);
  }

  Future<void> _submit() async {
    // Persist last domain
    if (_step > 0 && _step <= _domains.length) {
      final domain = _domains[_step - 1];
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

      final model = ThreeMonthNarrativeModel(
        studentId: _selectedStudent!.id,
        studentName: _selectedStudent!.name,
        monthRange: _getMonthRange(),
        domains: _entries.values.toList(),
        savedAt: DateTime.now(),
      );

      // TODO: wire to real repository
      // final repo = di.sl<ThreeMonthNarrativeRepository>();
      // await repo.submit(model);
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showSuccess(
        context,
        'Submitted for ${_selectedStudent!.name}',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to submit: $e');
    }
  }

  String _getMonthRange() {
    final now = DateTime.now();
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
    final start = now.subtract(const Duration(days: 90));
    return '${names[start.month - 1]} – ${names[now.month - 1]} ${now.year}';
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

    // Step index in domain list
    final domainIndex = _step - 1;
    if (domainIndex < _domains.length) {
      return _buildDomainEditor(theme, isDark, domainIndex);
    }

    // Review step
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
                color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('No students available'),
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
  // STEP 1..N — Domain editor
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
          // Progress indicator
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

          // Domain header
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

          // Narrative
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

          // Summary
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
  // FINAL STEP — Review & Submit
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

          // Student summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person_rounded, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedStudent?.name ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _getMonthRange(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Domain list
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
  // Bottom bar — Back / Next / Submit
  // ═════════════════════════════════════════════════════════════
  Widget _buildBottomBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final totalSteps = _domains.length + 1; // student + domains + review
    final isReview = _step > _domains.length;
    final isStudent = _step == 0;

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
            // Back button (hidden on first step)
            if (!isStudent) ...[
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
                              isStudent
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
