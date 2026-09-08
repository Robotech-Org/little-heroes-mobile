import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ShareWithParentsPage extends StatefulWidget {
  const ShareWithParentsPage({super.key});

  @override
  State<ShareWithParentsPage> createState() => _ShareWithParentsPageState();
}

class _ShareWithParentsPageState extends State<ShareWithParentsPage> {
  final TextEditingController _narrativeController = TextEditingController();

  // Student selection
  List<Student> _students = [];
  Student? _selectedStudent;
  bool _isLoadingStudents = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _narrativeController.dispose();
    super.dispose();
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
        if (_students.isNotEmpty) {
          _selectedStudent = _students.first;
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

  Future<void> _submitToAdmin() async {
    final narrative = _narrativeController.text.trim();

    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }

    if (narrative.isEmpty) {
      SnackbarUtils.showError(context, 'Please write a narrative report');
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

      // TODO: Implement actual API call to submit narrative report
      await Future.delayed(const Duration(seconds: 1));

      setState(() => _isSaving = false);

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Report submitted to Admin for ${_selectedStudent!.name}!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to submit: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '3 month compilation ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Selector
            _buildStudentSelector(theme, colors),
            const SizedBox(height: 24),

            // Show form only if student is selected
            if (_selectedStudent != null) ...[
              // Student Name Header
              Text(
                '${_selectedStudent!.name} — Term Summary',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Date Range
              Text(
                _getMonthRange(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Narrative Report
              Text(
                'Terms Summery',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Write the final narrative report sent to Admin for review.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _narrativeController,
                  minLines: 6,
                  maxLines: 12,
                  enabled: !_isSaving,
                  decoration: InputDecoration(
                    hintText: 'Write the final narrative report...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: TextStyle(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitToAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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
                      : const Text(
                          'Submit to Admin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_rounded, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              'Select Student',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoadingStudents)
          const Center(child: CircularProgressIndicator())
        else if (_students.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No students available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
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
                        setState(() {
                          _selectedStudent = value;
                          // Clear narrative when switching students
                          _narrativeController.clear();
                        });
                      },
                items: _students.map((student) {
                  return DropdownMenuItem<Student>(
                    value: student,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          student.ageRange,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
              color: colors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedStudent!.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getMonthRange() {
    final now = DateTime.now();
    final monthNames = [
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
    final currentMonth = monthNames[now.month - 1];

    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final startMonth = monthNames[threeMonthsAgo.month - 1];

    return '$startMonth – $currentMonth ${now.year}';
  }
}
