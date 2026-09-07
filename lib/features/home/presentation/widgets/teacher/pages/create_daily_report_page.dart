import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
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

  // Student selection
  List<Student> _students = [];
  Student? _selectedStudent;
  bool _isLoadingStudents = true;

  // Report fields
  String _selectedMeal = 'Ate Well';
  String _selectedNap = 'Slept Well';
  String _selectedMood = 'Happy';
  String _selectedHealth = 'No Concerns';
  String _messageToParent = '';
  bool _isSaving = false;

  // Options
  final List<String> _mealOptions = ['Ate Well', 'Ate Some', 'Refused'];
  final List<String> _napOptions = ['Slept Well', 'Short Nap', 'Did Not Sleep'];
  final List<String> _moodOptions = [
    'Happy',
    'Playful',
    'Quiet',
    'Fussy',
    'Tired',
  ];
  final List<String> _healthOptions = [
    'No Concerns',
    'Runny Nose',
    'Cough',
    'Fever',
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    if (widget.report != null) {
      _populateFields(widget.report!);
    }
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
      });
    } catch (e) {
      setState(() => _isLoadingStudents = false);
      SnackbarUtils.showError(
        context,
        'Failed to load students: ${e.toString()}',
      );
    }
  }

  void _populateFields(DailyReportModel report) {
    // Find the student by name
    _selectedStudent = _students.firstWhere(
      (s) => s.name == report.studentName,
      orElse: () => Student(
        name: report.studentName,
        gender: '',
        dateOfBirth: '',
        ageRange: '',
        enrollmentStatus: '',
        creation: '',
        modified: '',
      ),
    );
    _selectedMeal = report.mealsAndSnacks;
    _selectedNap = report.napTime;
    _selectedMood = report.moodAndBehavior;
    _selectedHealth = report.healthAndHygiene;
    _messageToParent = report.dailyReportNotes;
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to save report');
        setState(() => _isSaving = false);
        return;
      }

      final data = {
        'student': _selectedStudent!.name,
        'student_name': _selectedStudent!.name,
        'student_classroom': _selectedStudent!.ageRange,
        'report_date': DateTime.now().toIso8601String().split('T').first,
        'meals_and_snacks': _selectedMeal,
        'nap_time': _selectedNap,
        'mood_and_behavior': _selectedMood,
        'health_and_hygiene': _selectedHealth,
        'daily_report_notes': _messageToParent,
        'daily_report_status': 'Saved',
        'recorded_by': authState.user.fullName,
      };

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

      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to save: ${e.toString()}');
    }
  }

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
              // Student Selector
              _buildStudentSelector(theme, colorScheme),
              const SizedBox(height: 24),

              // Meals & Snacks
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Meals & Snacks',
                value: _selectedMeal,
                options: _mealOptions,
                onChanged: (value) {
                  setState(() => _selectedMeal = value);
                },
              ),

              const SizedBox(height: 20),

              // Nap Time
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Nap Time',
                value: _selectedNap,
                options: _napOptions,
                onChanged: (value) {
                  setState(() => _selectedNap = value);
                },
              ),

              const SizedBox(height: 20),

              // Mood & Behavior
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Mood & Behavior',
                value: _selectedMood,
                options: _moodOptions,
                onChanged: (value) {
                  setState(() => _selectedMood = value);
                },
              ),

              const SizedBox(height: 20),

              // Health & Hygiene
              _buildOptionSelector(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Health & Hygiene',
                value: _selectedHealth,
                options: _healthOptions,
                onChanged: (value) {
                  setState(() => _selectedHealth = value);
                },
              ),
              // Message to Parent
              _buildMessageField(theme, colorScheme),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionSelector({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
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
                        : colorScheme.primary.withValues(alpha: 0.5),
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

  Widget _buildStudentSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Student',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
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
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() => _selectedStudent = value);
                      },
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

  Widget _buildMessageField(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message to Parent',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _messageToParent,
          maxLines: 4,
          enabled: !_isSaving,
          decoration: InputDecoration(
            hintText: 'Write a message to the parent...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) => _messageToParent = value,
        ),
      ],
    );
  }

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
                widget.report != null ? 'Update Report' : 'Save & Mark Done',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
