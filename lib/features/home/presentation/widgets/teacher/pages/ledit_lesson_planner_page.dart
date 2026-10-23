import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/curriculum_plan_repository.dart';
import 'package:little_heroes_mobile/features/home/data/models/classroom_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/competency_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/curriculum_plan_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/lesson_plan_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/competency_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/lesson_plan_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class EditLessonPlanPage extends StatefulWidget {
  /// The existing plan to edit.
  final LessonPlanModel plan;

  const EditLessonPlanPage({super.key, required this.plan});

  @override
  State<EditLessonPlanPage> createState() => _EditLessonPlanPageState();
}

class _EditLessonPlanPageState extends State<EditLessonPlanPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (initialized from plan)
  late final TextEditingController _subjectController;
  late final TextEditingController _titleController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _introductionController;
  late final TextEditingController _materialsController;
  late final TextEditingController _keyDevController;

  // Selections
  ClassroomModel? _selectedClassroom;
  CurriculumPlanModel? _selectedCurriculumPlan;
  String? _selectedDomain;
  CompetencyModel? _selectedSubDomain;

  // Data
  List<ClassroomModel> _classrooms = [];
  List<CurriculumPlanModel> _curriculumPlans = [];
  List<CompetencyModel> _competencies = [];

  bool _isLoading = true;
  bool _isSaving = false;

  List<String> get _domains {
    final set = _competencies.map((c) => c.domain).toSet().toList();
    set.sort();
    return set;
  }

  List<CompetencyModel> get _subDomains {
    if (_selectedDomain == null) return [];
    final list = _competencies
        .where((c) => c.domain == _selectedDomain)
        .toList();
    list.sort((a, b) => a.sequence.compareTo(b.sequence));
    return list;
  }

  // ═════════════════════════════════════════════════════════════
  // INIT
  // ═════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();

    final p = widget.plan;
    _subjectController = TextEditingController(text: p.subject ?? '');
    _titleController = TextEditingController(text: p.titleOfLesson ?? '');
    _objectiveController = TextEditingController(text: p.objective ?? '');
    _introductionController = TextEditingController(text: p.introduction ?? '');
    _materialsController = TextEditingController(text: p.materials ?? '');
    _keyDevController = TextEditingController(
      text: p.keyDevelopmentIndicator ?? '',
    );

    _loadAll();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    _objectiveController.dispose();
    _introductionController.dispose();
    _materialsController.dispose();
    _keyDevController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════
  // LOAD + PREFILL
  // ═════════════════════════════════════════════════════════════
  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    try {
      final classroomsFuture = di.sl<ClassroomRepository>().getClassrooms(
        page: 1,
        pageSize: 50,
      );
      final curriculumFuture = di
          .sl<CurriculumPlanRepository>()
          .getCurriculumPlans(page: 1, pageSize: 50);
      final competencyFuture = di.sl<CompetencyRepository>().getCompetencies(
        page: 1,
        pageSize: 100,
      );

      final classroomsResp = await classroomsFuture;
      final curriculumResp = await curriculumFuture;
      final competencyResp = await competencyFuture;

      if (!mounted) return;
      setState(() {
        _classrooms = classroomsResp.items;
        _curriculumPlans = curriculumResp.items;
        _competencies = competencyResp.items;

        _prefillSelections();

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarUtils.showError(
        context,
        'Failed to load form data: ${e.toString()}',
      );
    }
  }

  /// Try to map the existing plan's values to the loaded dropdown items.
  void _prefillSelections() {
    final p = widget.plan;

    // ── Classroom ────────────────────────────────────────────
    _selectedClassroom =
        _findFirst(_classrooms, (c) => c.classroomName == p.classroom) ??
        (_classrooms.isNotEmpty ? _classrooms.first : null);

    // ── Curriculum Plan ──────────────────────────────────────
    // NOTE: Assumes `LessonPlanModel.curriculumPlan` exists (String?).
    final planCurriculum = p.curriculumPlan;
    if (planCurriculum != null && planCurriculum.isNotEmpty) {
      _selectedCurriculumPlan = _findFirst(
        _curriculumPlans,
        (c) => c.name == planCurriculum,
      );
    }
    _selectedCurriculumPlan ??= _curriculumPlans.isNotEmpty
        ? _curriculumPlans.first
        : null;

    // ── Framework Domain / Sub-domain ────────────────────────
    // NOTE: Assumes `LessonPlanModel.subDomainObjective` holds the
    // competency code (String?) and `LessonPlanModel.frameworkDomain`
    // holds the domain name (String?).
    final planCode = p.subDomainObjective;
    if (planCode != null && planCode.isNotEmpty) {
      final match = _findFirst(
        _competencies,
        (c) => c.competencyCode == planCode,
      );
      if (match != null) {
        _selectedDomain = match.domain;
        _selectedSubDomain = match;
      }
    }

    // Fallback: try to match by domain name
    if (_selectedDomain == null) {
      final planDomain = p.frameworkDomain;
      if (planDomain != null && _domains.contains(planDomain)) {
        _selectedDomain = planDomain;
        _selectedSubDomain = _subDomains.isNotEmpty ? _subDomains.first : null;
      }
    }

    // Final fallback: first available
    if (_selectedDomain == null && _domains.isNotEmpty) {
      _selectedDomain = _domains.first;
      _selectedSubDomain = _subDomains.isNotEmpty ? _subDomains.first : null;
    }
  }

  T? _findFirst<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  // ═════════════════════════════════════════════════════════════
  // UPDATE
  // ═════════════════════════════════════════════════════════════
  Future<void> _updateLessonPlan({required bool isDraft}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClassroom == null) {
      SnackbarUtils.showError(context, 'Please select a classroom');
      return;
    }
    if (_selectedCurriculumPlan == null) {
      SnackbarUtils.showError(context, 'Please select a curriculum plan');
      return;
    }
    if (_selectedDomain == null) {
      SnackbarUtils.showError(context, 'Please select a framework domain');
      return;
    }
    if (_selectedSubDomain == null) {
      SnackbarUtils.showError(context, 'Please select a sub-domain');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to save');
        setState(() => _isSaving = false);
        return;
      }

      final p = widget.plan;

      final data = {
        'lesson_plan_classroom': _selectedClassroom!.classroomName,
        'curriculum_plan': _selectedCurriculumPlan!.name,
        'lesson_plan_framework_domain': _selectedDomain,
        'lesson_plan_sub_domain_objective': _selectedSubDomain!.competencyCode,
        'lesson_plan_date':
            p.lessonPlanDate ??
            DateTime.now().toIso8601String().split('T').first,
        'lesson_plan_week_start':
            p.lessonPlanWeekStart ??
            _getWeekStart().toIso8601String().split('T').first,
        'lesson_plan_type': p.lessonPlanType ?? 'Weekly',
        // Draft → "pending"  |  Submit → "submited"
        'lesson_plan_status': isDraft ? 'pending' : 'submited',
        'lesson_plan_subject': _subjectController.text.trim(),
        'lesson_plan_title_of_lesson': _titleController.text.trim(),
        'lesson_plan_objective': _objectiveController.text.trim(),
        'lesson_plan_introduction': _introductionController.text.trim(),
        'lesson_plan_materials': _materialsController.text.trim(),
        'lesson_plan_key_development_indicator': _keyDevController.text.trim(),
      };

      debugPrint(' [EditLessonPlan] update payload:\n$data');

      final repo = di.sl<LessonPlanRepository>();
      await repo.updateLessonPlan(lessonPlanName: p.name, data: data);

      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showSuccess(
        context,
        isDraft
            ? 'Changes saved as draft!'
            : 'Lesson plan updated and submitted!',
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to update: ${e.toString()}');
    }
  }

  DateTime _getWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
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
          'Edit Lesson Plan',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Editing banner ───────────────────
                    _editBanner(theme, colorScheme, isDark),
                    const SizedBox(height: 24),

                    // ── Setup card ───────────────────────
                    _setupCard(theme, colorScheme, isDark),
                    const SizedBox(height: 24),

                    // ── Framework domain chips ───────────
                    _sectionHeader(
                      theme,
                      colorScheme,
                      'Framework Domain',
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildDomainChips(theme, colorScheme, isDark),
                    const SizedBox(height: 20),

                    // ── Sub-domain dropdown ──────────────
                    _dropdownField<CompetencyModel>(
                      theme: theme,
                      label: 'Sub-domain Objective',
                      icon: Icons.checklist_rounded,
                      value: _selectedSubDomain,
                      items: _subDomains,
                      labelOf: (c) => '${c.competencyCode} — ${c.title}',
                      hint: _subDomains.isEmpty
                          ? 'No sub-domains for this framework'
                          : null,
                      onChanged: (v) => setState(() => _selectedSubDomain = v),
                    ),

                    const SizedBox(height: 24),

                    // ── Lesson content ──────────────────
                    _sectionHeader(
                      theme,
                      colorScheme,
                      'Lesson Content',
                      Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      theme: theme,
                      controller: _subjectController,
                      label: 'Subject',
                      hint: 'e.g. Sensory & Colors',
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      theme: theme,
                      controller: _titleController,
                      label: 'Title of Lesson',
                      hint: 'Enter lesson title...',
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      theme: theme,
                      controller: _objectiveController,
                      label: 'Objective',
                      hint: 'Enter learning objective...',
                      maxLines: 3,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      theme: theme,
                      controller: _introductionController,
                      label: 'Introduction',
                      hint: 'How will you introduce the lesson?',
                      maxLines: 2,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      theme: theme,
                      controller: _materialsController,
                      label: 'Materials Needed',
                      hint: 'List materials required...',
                      maxLines: 3,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      theme: theme,
                      controller: _keyDevController,
                      label: 'Key Development Indicator',
                      hint: 'What skill is being developed?',
                      maxLines: 2,
                      required: true,
                    ),

                    const SizedBox(height: 28),
                    _buildActionButtons(theme, colorScheme),
                  ],
                ),
              ),
            ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // EDIT BANNER
  // ═════════════════════════════════════════════════════════════
  Widget _editBanner(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final p = widget.plan;
    final title = (p.titleOfLesson?.trim().isNotEmpty ?? false)
        ? p.titleOfLesson!
        : 'Untitled Lesson';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.edit_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SETUP CARD
  // ═════════════════════════════════════════════════════════════
  Widget _setupCard(ThemeData theme, ColorScheme colorScheme, bool isDark) {
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Setup',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _dropdownField<ClassroomModel>(
            theme: theme,
            label: 'Classroom',
            icon: Icons.class_rounded,
            value: _selectedClassroom,
            items: _classrooms,
            labelOf: (c) => c.classroomName,
            onChanged: (v) => setState(() => _selectedClassroom = v),
          ),
          const SizedBox(height: 14),

          _dropdownField<CurriculumPlanModel>(
            theme: theme,
            label: 'Curriculum Plan',
            icon: Icons.menu_book_rounded,
            value: _selectedCurriculumPlan,
            items: _curriculumPlans,
            labelOf: (c) => '${c.title} • ${c.term}',
            onChanged: (v) => setState(() => _selectedCurriculumPlan = v),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // DOMAIN CHIPS
  // ═════════════════════════════════════════════════════════════
  Widget _buildDomainChips(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (_domains.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No framework domains available',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _domains.map((domain) {
          final isSelected = _selectedDomain == domain;

          return GestureDetector(
            onTap: _isSaving
                ? null
                : () {
                    setState(() {
                      _selectedDomain = domain;
                      _selectedSubDomain = _subDomains.isNotEmpty
                          ? _subDomains.first
                          : null;
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    domain,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═════════════════════════════════════════════════════════════
  Widget _sectionHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    String text,
    IconData icon,
  ) {
    return Row(
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
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hint != null ? Text(hint) : null,
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    labelOf(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _isSaving ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = false,
  }) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSaving
                ? null
                : () => _updateLessonPlan(isDraft: true),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text(
              'Save Draft',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving
                ? null
                : () => _updateLessonPlan(isDraft: false),
            icon: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
