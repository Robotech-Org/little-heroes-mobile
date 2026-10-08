
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/classroom_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_draft_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
import 'package:little_heroes_mobile/features/home/data/services/daily_report_draft_service.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/constants/daily_report_options.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class CreateDailyReportPage extends StatefulWidget {
  final DailyReportModel? report;

  const CreateDailyReportPage({super.key, this.report});

  @override
  State<CreateDailyReportPage> createState() => _CreateDailyReportPageState();
}

class _CreateDailyReportPageState extends State<CreateDailyReportPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Student selection ──────────────────────────────────
  List<Student> _students = [];
  Student? _selectedStudent;
  bool _isLoadingStudents = true;

  // ── Classroom selection ────────────────────────────────
  List<ClassroomModel> _classrooms = [];
  ClassroomModel? _selectedClassroom;
  bool _isLoadingClassrooms = true;

  // ── Core report fields ─────────────────────────────────
  String _selectedMeal = DailyReportOptions.defaultMeal;
  String _selectedNap = DailyReportOptions.defaultNap;
  String _selectedMood = DailyReportOptions.defaultMood;
  String _selectedHealth = DailyReportOptions.defaultHealth;
  String _selectedActivity = DailyReportOptions.defaultActivity;
  String _selectedDiaper = DailyReportOptions.defaultDiaper;

  String _messageToParent = '';
  bool _isSaving = false;

  // ── Controllers ────────────────────────────────────────
  final _messageController = TextEditingController();

  // Section notes
  final _mealNotesController = TextEditingController();
  final _napNotesController = TextEditingController();
  final _napDurationController = TextEditingController();
  final _moodNotesController = TextEditingController();
  final _activityNotesController = TextEditingController();
  final _diaperNotesController = TextEditingController();
  final _healthNotesController = TextEditingController();

  // Special notes
  final _specialNotesController = TextEditingController();

  // ── Reminder state ─────────────────────────────────────
  bool _reminderBringClothes = false;
  final _reminderClothesDetailsController = TextEditingController();

  bool _reminderBringToyBlanket = false;
  final _reminderToyBlanketDetailsController = TextEditingController();

  bool _reminderUpcomingEvent = false;
  final _reminderUpcomingEventDetailsController = TextEditingController();

  bool _reminderOther = false;
  final _reminderOtherDetailsController = TextEditingController();

  // ── Draft ──────────────────────────────────────────────
  final _draftService = DailyReportDraftService();
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;

  // ═══════════════════════════════════════════════════════
  // DRAFT KEY — one draft per report (edit) or per student (new)
  // ═══════════════════════════════════════════════════════
  String get _draftKey {
    if (widget.report != null && widget.report!.name.isNotEmpty) {
      return 'report_${widget.report!.name}';
    }
    if (_selectedStudent != null) {
      return 'student_${_selectedStudent!.id}';
    }
    return 'new_draft';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.report != null) {
      _populateFields(widget.report!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraftIfAny());
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _messageController.dispose();
    _mealNotesController.dispose();
    _napNotesController.dispose();
    _napDurationController.dispose();
    _moodNotesController.dispose();
    _activityNotesController.dispose();
    _diaperNotesController.dispose();
    _healthNotesController.dispose();
    _specialNotesController.dispose();
    _reminderClothesDetailsController.dispose();
    _reminderToyBlanketDetailsController.dispose();
    _reminderUpcomingEventDetailsController.dispose();
    _reminderOtherDetailsController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // Message controller sync
  // ═══════════════════════════════════════════════════════
  void _setMessage(String value) {
    _messageToParent = value;
    if (_messageController.text != value) {
      _messageController.text = value;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // Data loading
  // ═══════════════════════════════════════════════════════
  Future<void> _loadData() async {
    await Future.wait([_loadStudents(), _loadClassrooms()]);
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isLoadingStudents = false);
        return;
      }

      final repository = di.sl<StudentRepository>();
      final response = await repository.getStudents(page: 1, pageSize: 100);

      setState(() {
        _students = response.items;
        _isLoadingStudents = false;

        if (widget.report != null) {
          _selectedStudent = _students.firstWhere(
            (s) => s.name == widget.report!.studentName,
            orElse: () => Student(
              id: widget.report!.name,
              name: widget.report!.studentName,
              gender: '',
              dateOfBirth: '',
              ageRange: '',
              enrollmentStatus: '',
              creation: '',
              modified: '',
            ),
          );
        }
      });
    } catch (e) {
      setState(() => _isLoadingStudents = false);
      SnackbarUtils.showError(
        context,
        'Failed to load students: ${e.toString()}',
      );
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

      final repository = di.sl<ClassroomRepository>();
      final response = await repository.getClassrooms(page: 1, pageSize: 20);

      setState(() {
        _classrooms = response.items;
        _isLoadingClassrooms = false;

        if (_classrooms.isNotEmpty && _selectedClassroom == null) {
          _selectedClassroom = _classrooms.first;
        }

        if (widget.report != null && _classrooms.isNotEmpty) {
          _selectedClassroom = _classrooms.firstWhere(
            (c) => c.classroomName == widget.report!.studentClassroom,
            orElse: () => _classrooms.first,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoadingClassrooms = false);
    }
  }

  // ═══════════════════════════════════════════════════════
  // Populate form from existing report (EDIT mode)
  // ═══════════════════════════════════════════════════════
  void _populateFields(DailyReportModel report) {
    _selectedStudent ??= _students.firstWhere(
      (s) => s.name == report.studentName,
      orElse: () => Student(
        id: report.name,
        name: report.studentName,
        gender: '',
        dateOfBirth: '',
        ageRange: '',
        enrollmentStatus: '',
        creation: '',
        modified: '',
      ),
    );

    _selectedMeal = _mapMealValue(report.mealsAndSnacks);
    _mealNotesController.text = report.mealsAndSnacksNotes;

    _selectedNap = _mapNapValue(report.napTime);
    _napDurationController.text = report.napDuration;
    _napNotesController.text = report.napTimeNotes;

    _selectedMood = _mapMoodValue(report.moodAndBehavior);
    _moodNotesController.text = report.moodAndBehaviorNotes;

    _selectedActivity = report.learningAndPlayActivities.isNotEmpty
        ? report.learningAndPlayActivities
        : DailyReportOptions.defaultActivity;
    _activityNotesController.text = report.learningAndPlayActivitiesNotes;

    _selectedDiaper = report.diaperToiletTraining.isNotEmpty
        ? report.diaperToiletTraining
        : DailyReportOptions.defaultDiaper;
    _diaperNotesController.text = report.diaperToiletTrainingNotes;

    _selectedHealth = _mapHealthValue(report.healthAndHygiene);
    _healthNotesController.text = report.healthCheckNotes;

    _reminderBringClothes = report.reminderBringClothes;
    _reminderClothesDetailsController.text = report.reminderClothesDetails;

    _reminderBringToyBlanket = report.reminderBringToyBlanket;
    _reminderToyBlanketDetailsController.text =
        report.reminderToyBlanketDetails;

    _reminderUpcomingEvent = report.reminderUpcomingEvent;
    _reminderUpcomingEventDetailsController.text =
        report.reminderUpcomingEventDetails;

    _reminderOther = report.reminderOther;
    _reminderOtherDetailsController.text = report.reminderOtherDetails;

    _specialNotesController.text = report.specialNotesAndReminders;
    _setMessage(report.dailyReportNotes);
  }

  // ═══════════════════════════════════════════════════════
  // Value mappers — legacy → current Select values
  // ═══════════════════════════════════════════════════════
  String _mapMealValue(String value) {
    if (DailyReportOptions.meals.contains(value)) return value;
    return DailyReportOptions.legacyMealMap[value] ??
        DailyReportOptions.defaultMeal;
  }

  String _mapNapValue(String value) {
    if (DailyReportOptions.naps.contains(value)) return value;
    return DailyReportOptions.legacyNapMap[value] ??
        DailyReportOptions.defaultNap;
  }

  String _mapMoodValue(String value) {
    if (DailyReportOptions.moods.contains(value)) return value;
    return DailyReportOptions.legacyMoodMap[value] ??
        DailyReportOptions.defaultMood;
  }

  String _mapHealthValue(String value) {
    if (DailyReportOptions.healthChecks.contains(value)) return value;
    return DailyReportOptions.legacyHealthMap[value] ??
        DailyReportOptions.defaultHealth;
  }

  // ═══════════════════════════════════════════════════════
  // SAVE REPORT
  // ═══════════════════════════════════════════════════════
  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }

    if (_selectedClassroom == null) {
      SnackbarUtils.showError(context, 'Please select a classroom');
      return;
    }

    _autoSaveTimer?.cancel();
    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to save report');
        setState(() => _isSaving = false);
        return;
      }

      final now = DateTime.now();
      final reportDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final studentId = _selectedStudent!.id;

      // ═════════════════════════════════════════════════════
      // Payload — matches API doc exactly
      // ═════════════════════════════════════════════════════
      final data = <String, dynamic>{
        // ── Required ────────────────────────────────────
        'student': studentId,
        'student_classroom': _selectedClassroom!.classroomName,
        'report_date': reportDate,
        'daily_report_status': widget.report?.dailyReportStatus ?? 'Saved',

        // ── Meals & Snacks ──────────────────────────────
        'meals_and_snacks': _selectedMeal,
        'meals_and_snacks_notes': _mealNotesController.text.trim(),

        // ── Nap ─────────────────────────────────────────
        'nap_time': _selectedNap,
        'nap_duration': _napDurationController.text.trim(),
        'nap_time_notes': _napNotesController.text.trim(),

        // ── Mood & Behavior ─────────────────────────────
        'mood_and_behavior': _selectedMood,
        'mood_and_behavior_notes': _moodNotesController.text.trim(),

        // ── Learning & Play ─────────────────────────────
        'learning_and_play_activities': _selectedActivity,
        'learning_and_play_activities_notes': _activityNotesController.text
            .trim(),

        // ── Diaper / Toilet ─────────────────────────────
        'diaper_toilet_training': _selectedDiaper,
        'diaper_toilet_training_notes': _diaperNotesController.text.trim(),

        // ── Health & Hygiene ────────────────────────────
        'health_and_hygiene': _selectedHealth,
        'health_check_notes': _healthNotesController.text.trim(),

        // ── Reminders ───────────────────────────────────
        'reminder_bring_clothes': _reminderBringClothes ? 1 : 0,
        'reminder_clothes_details': _reminderClothesDetailsController.text
            .trim(),
        'reminder_bring_toy_blanket': _reminderBringToyBlanket ? 1 : 0,
        'reminder_toy_blanket_details': _reminderToyBlanketDetailsController
            .text
            .trim(),
        'reminder_upcoming_event': _reminderUpcomingEvent ? 1 : 0,
        'reminder_upcoming_event_details':
            _reminderUpcomingEventDetailsController.text.trim(),
        'reminder_other': _reminderOther ? 1 : 0,
        'reminder_other_details': _reminderOtherDetailsController.text.trim(),

        // ── Free-form ───────────────────────────────────
        'special_notes_and_reminders': _specialNotesController.text.trim(),
        'daily_report_notes': _messageToParent,
      };

      // print('📝 Daily report payload: $data');

      final repository = di.sl<DailyReportRepository>();

      if (widget.report != null) {
        await repository.updateDailyReport(
          reportName: widget.report!.name,
          data: data,
        );
        SnackbarUtils.showSuccess(context, 'Report updated successfully!');
      } else {
        await repository.createDailyReport(data);
        SnackbarUtils.showSuccess(context, 'Report created successfully!');
      }

      await _deleteDraft();

      setState(() => _isSaving = false);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to save: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════
  // Draft handling
  // ═══════════════════════════════════════════════════════
  Future<void> _restoreDraftIfAny() async {
    if (!mounted) return;
    if (widget.report == null) return;

    final draft = await _draftService.getDraft(_draftKey);
    if (draft == null || !mounted) return;

    final restore = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Draft Found'),
        content: Text(
          'You have an unsaved draft from ${_formatTimeAgo(draft.savedAt)}.\n\n'
          'Would you like to restore it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (restore == true) {
      setState(() {
        _selectedMeal = draft.selectedMeal;
        _selectedNap = draft.selectedNap;
        _selectedMood = draft.selectedMood;
        _selectedHealth = draft.selectedHealth;
        _setMessage(draft.messageToParent);
      });
      SnackbarUtils.showSuccess(context, 'Draft restored');
    } else {
      await _draftService.deleteDraft(_draftKey);
    }
  }

  Future<void> _onStudentChanged(Student? student) async {
    if (student == null) return;

    _autoSaveTimer?.cancel();

    setState(() {
      _selectedStudent = student;
      _resetForm();
    });

    final draft = await _draftService.getDraft('student_${student.id}');
    if (draft == null || !mounted) return;

    final restore = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Draft Found'),
        content: Text(
          'A saved draft for ${draft.studentName} from '
          '${_formatTimeAgo(draft.savedAt)} exists.\n\n'
          'Would you like to load it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Start Fresh'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Load Draft'),
          ),
        ],
      ),
    );

    if (restore == true) {
      setState(() {
        _selectedMeal = draft.selectedMeal;
        _selectedNap = draft.selectedNap;
        _selectedMood = draft.selectedMood;
        _selectedHealth = draft.selectedHealth;
        _setMessage(draft.messageToParent);

        if (draft.classroomName != null && _classrooms.isNotEmpty) {
          _selectedClassroom = _classrooms.firstWhere(
            (c) => c.classroomName == draft.classroomName,
            orElse: () => _selectedClassroom ?? _classrooms.first,
          );
        }
      });
      SnackbarUtils.showSuccess(context, 'Draft loaded');
    }
  }

  void _resetForm() {
    _selectedMeal = DailyReportOptions.defaultMeal;
    _selectedNap = DailyReportOptions.defaultNap;
    _selectedMood = DailyReportOptions.defaultMood;
    _selectedHealth = DailyReportOptions.defaultHealth;
    _selectedActivity = DailyReportOptions.defaultActivity;
    _selectedDiaper = DailyReportOptions.defaultDiaper;

    _mealNotesController.clear();
    _napNotesController.clear();
    _napDurationController.clear();
    _moodNotesController.clear();
    _activityNotesController.clear();
    _diaperNotesController.clear();
    _healthNotesController.clear();
    _specialNotesController.clear();

    _reminderBringClothes = false;
    _reminderClothesDetailsController.clear();
    _reminderBringToyBlanket = false;
    _reminderToyBlanketDetailsController.clear();
    _reminderUpcomingEvent = false;
    _reminderUpcomingEventDetailsController.clear();
    _reminderOther = false;
    _reminderOtherDetailsController.clear();

    _setMessage('');
  }

  void _scheduleAutoSave() {
    _hasUnsavedChanges = true;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      _saveAsDraft(silent: true);
    });
  }

  Future<void> _saveAsDraft({bool silent = false}) async {
    if (_selectedStudent == null || _selectedClassroom == null) return;

    final draft = DailyReportDraftModel(
      reportName: widget.report?.name,
      studentId: _selectedStudent!.id,
      studentName: _selectedStudent!.name,
      classroomName: _selectedClassroom!.classroomName,
      reportDate: DateTime.now().toIso8601String().split('T').first,
      selectedMeal: _selectedMeal,
      selectedNap: _selectedNap,
      selectedMood: _selectedMood,
      selectedHealth: _selectedHealth,
      messageToParent: _messageToParent,
      savedAt: DateTime.now(),
    );

    await _draftService.saveDraft(draft);
    _hasUnsavedChanges = false;

    if (!silent && mounted) {
      SnackbarUtils.showSuccess(
        context,
        'Draft saved for ${_selectedStudent!.name}',
      );
    }
  }

  Future<void> _deleteDraft() async {
    await _draftService.deleteDraft(_draftKey);
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.report != null ? 'Edit Daily Report' : 'New Daily Report',
          style: const TextStyle(fontWeight: FontWeight.w700),
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
          TextButton(
            onPressed: _isSaving ? null : _saveReport,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.report != null ? 'Update' : 'Save',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentSelector(theme, colorScheme),
              const SizedBox(height: 16),

              _buildClassroomSelector(theme, colorScheme),
              const SizedBox(height: 24),

              // ── Meals & Snacks ─────────────────────────
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Meals & Snacks',
                value: _selectedMeal,
                options: DailyReportOptions.meals,
                icon: Icons.restaurant_rounded,
                onChanged: (value) {
                  setState(() => _selectedMeal = value);
                  _scheduleAutoSave();
                },
              ),
              const SizedBox(height: 8),
              _buildNotesField(
                colorScheme: colorScheme,
                controller: _mealNotesController,
                hint: 'Meal notes (optional)...',
              ),
              const SizedBox(height: 20),

              // ── Nap Time ───────────────────────────────
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Nap Time',
                value: _selectedNap,
                options: DailyReportOptions.naps,
                icon: Icons.bed_rounded,
                onChanged: (value) {
                  setState(() => _selectedNap = value);
                  _scheduleAutoSave();
                },
              ),
              const SizedBox(height: 8),
              _buildNotesField(
                colorScheme: colorScheme,
                controller: _napDurationController,
                hint: 'Nap duration (e.g. 2 hours)...',
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              _buildNotesField(
                colorScheme: colorScheme,
                controller: _napNotesController,
                hint: 'Nap notes (optional)...',
              ),
              const SizedBox(height: 20),

              // ── Mood & Behavior ────────────────────────
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Mood & Behavior',
                value: _selectedMood,
                options: DailyReportOptions.moods,
                icon: Icons.emoji_emotions_rounded,
                onChanged: (value) {
                  setState(() => _selectedMood = value);
                  _scheduleAutoSave();
                },
              ),
              const SizedBox(height: 8),
              _buildNotesField(
                colorScheme: colorScheme,
                controller: _moodNotesController,
                hint: 'Mood notes (optional)...',
              ),
              const SizedBox(height: 20),

              // ── Learning & Play ────────────────────────
              _buildActivitySelector(theme, colorScheme),
              const SizedBox(height: 20),

              // ── Diaper / Toilet ────────────────────────
              _buildDiaperSelector(theme, colorScheme),
              const SizedBox(height: 20),

              // ── Health & Hygiene ───────────────────────
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Health & Hygiene',
                value: _selectedHealth,
                options: DailyReportOptions.healthChecks,
                icon: Icons.health_and_safety_rounded,
                onChanged: (value) {
                  setState(() => _selectedHealth = value);
                  _scheduleAutoSave();
                },
              ),
              const SizedBox(height: 8),
              _buildNotesField(
                colorScheme: colorScheme,
                controller: _healthNotesController,
                hint: 'Health notes (optional)...',
              ),
              const SizedBox(height: 24),

              // ── Reminders ──────────────────────────────
              _buildRemindersSection(theme, colorScheme),
              const SizedBox(height: 20),

              // ── Special notes ──────────────────────────
              _buildSectionLabel(
                theme,
                colorScheme,
                icon: Icons.sticky_note_2_outlined,
                label: 'Special Notes & Reminders',
              ),
              const SizedBox(height: 8),
              _buildNotesField(
                colorScheme: colorScheme,
                controller: _specialNotesController,
                hint: 'Anything else the parent should know...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ── Message to Parent ──────────────────────
              _buildMessageField(theme, colorScheme),
              const SizedBox(height: 32),

              _buildSaveDraftButton(theme, colorScheme),
              const SizedBox(height: 12),
              _buildSaveButton(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Section helpers
  // ═══════════════════════════════════════════════════════
  Widget _buildSectionLabel(
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField({
    required ColorScheme colorScheme,
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
      style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
      onChanged: (_) => _scheduleAutoSave(),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Option selector (single-select pills)
  // ═══════════════════════════════════════════════════════
  Widget _buildOptionSelector({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = value == option;

            return GestureDetector(
              onTap: _isSaving ? null : () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
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
                        size: 16,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      option,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Student selector
  // ═══════════════════════════════════════════════════════
  Widget _buildStudentSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Select Student',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoadingStudents)
          const Center(child: CircularProgressIndicator())
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Student>(
                value: _selectedStudent,
                hint: const Text('Select a student...'),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: theme.textTheme.bodyMedium,
                onChanged: _isSaving ? null : _onStudentChanged,
                items: _students.map((student) {
                  return DropdownMenuItem<Student>(
                    value: student,
                    child: Text(student.name),
                  );
                }).toList(),
              ),
            ),
          ),
        if (_selectedStudent != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedStudent!.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Classroom selector
  // ═══════════════════════════════════════════════════════
  Widget _buildClassroomSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.class_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Classroom',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isLoadingClassrooms)
          const Center(child: CircularProgressIndicator())
        else if (_classrooms.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'No classrooms available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _classrooms.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final classroom = _classrooms[index];
                final isSelected = _selectedClassroom == classroom;

                return GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () {
                          setState(() => _selectedClassroom = classroom);
                          _scheduleAutoSave();
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.class_rounded,
                          size: 16,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          classroom.classroomName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Learning & Play — single-select + notes
  // ═══════════════════════════════════════════════════════
  Widget _buildActivitySelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.toys_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Learning & Play Activities',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DailyReportOptions.activities.map((activity) {
            final isSelected = _selectedActivity == activity;
            return GestureDetector(
              onTap: _isSaving
                  ? null
                  : () {
                      setState(() => _selectedActivity = activity);
                      _scheduleAutoSave();
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildNotesField(
          colorScheme: colorScheme,
          controller: _activityNotesController,
          hint: 'Notes on activities...',
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Diaper / Toilet — single-select + notes
  // ═══════════════════════════════════════════════════════
  Widget _buildDiaperSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Diaper Changes / Toilet Training',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DailyReportOptions.diaperOptions.map((option) {
            final isSelected = _selectedDiaper == option;
            return GestureDetector(
              onTap: _isSaving
                  ? null
                  : () {
                      setState(() => _selectedDiaper = option);
                      _scheduleAutoSave();
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      option,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildNotesField(
          colorScheme: colorScheme,
          controller: _diaperNotesController,
          hint: 'Notes on diaper / toilet...',
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Reminders section
  // ═══════════════════════════════════════════════════════
  Widget _buildRemindersSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          theme,
          colorScheme,
          icon: Icons.notifications_active_rounded,
          label: 'Reminders',
        ),
        const SizedBox(height: 10),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Bring extra clothes',
          value: _reminderBringClothes,
          detailsController: _reminderClothesDetailsController,
          onChanged: (v) {
            setState(() => _reminderBringClothes = v);
            _scheduleAutoSave();
          },
        ),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Bring toy / blanket',
          value: _reminderBringToyBlanket,
          detailsController: _reminderToyBlanketDetailsController,
          onChanged: (v) {
            setState(() => _reminderBringToyBlanket = v);
            _scheduleAutoSave();
          },
        ),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Upcoming event',
          value: _reminderUpcomingEvent,
          detailsController: _reminderUpcomingEventDetailsController,
          onChanged: (v) {
            setState(() => _reminderUpcomingEvent = v);
            _scheduleAutoSave();
          },
        ),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Other reminder',
          value: _reminderOther,
          detailsController: _reminderOtherDetailsController,
          onChanged: (v) {
            setState(() => _reminderOther = v);
            _scheduleAutoSave();
          },
        ),
      ],
    );
  }

  Widget _buildReminderTile(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String title,
    required bool value,
    required TextEditingController detailsController,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: value,
            onChanged: _isSaving ? null : (v) => onChanged(v ?? false),
            title: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: colorScheme.primary,
          ),
          if (value)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextFormField(
                controller: detailsController,
                enabled: !_isSaving,
                maxLength: 140,
                decoration: InputDecoration(
                  hintText: 'Details (optional)...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.15),
                  isDense: true,
                  counterText: '',
                ),
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                onChanged: (_) => _scheduleAutoSave(),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Message to Parent
  // ═══════════════════════════════════════════════════════
  Widget _buildMessageField(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.message_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Message to Parent',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 4,
          enabled: !_isSaving,
          decoration: InputDecoration(
            hintText: 'Write a message to the parent...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.all(16),
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          style: TextStyle(color: colorScheme.onSurface),
          onChanged: (value) {
            _messageToParent = value;
            _scheduleAutoSave();
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Save buttons
  // ═══════════════════════════════════════════════════════
  Widget _buildSaveButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.report != null ? 'Update Report' : 'Submit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSaveDraftButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isSaving
            ? null
            : () async {
                if (_selectedStudent == null) {
                  SnackbarUtils.showError(context, 'Please select a student');
                  return;
                }
                if (_selectedClassroom == null) {
                  SnackbarUtils.showError(context, 'Please select a classroom');
                  return;
                }
                _autoSaveTimer?.cancel();
                await _saveAsDraft(silent: false);
              },
        icon: const Icon(Icons.save_outlined, size: 20),
        label: const Text(
          'Save Draft',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
