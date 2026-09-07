import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/framework_domain_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/framework_domain_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateLessonPlanPage extends StatefulWidget {
  const CreateLessonPlanPage({super.key});

  @override
  State<CreateLessonPlanPage> createState() => _CreateLessonPlanPageState();
}

class _CreateLessonPlanPageState extends State<CreateLessonPlanPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _materialsController = TextEditingController();

  // Dropdown selections
  FrameworkDomainModel? _selectedDomain;
  String _selectedType = 'Daily';
  String _selectedStatus = 'Draft';

  // Data
  List<FrameworkDomainModel> _domains = [];
  bool _isLoadingDomains = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDomains();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _objectiveController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  Future<void> _loadDomains() async {
    setState(() => _isLoadingDomains = true);

    try {
      final repository = di.sl<FrameworkDomainRepository>();
      final response = await repository.getFrameworkDomains(
        page: 1,
        pageSize: 100,
      );

      setState(() {
        _domains = response.items;
        _isLoadingDomains = false;
      });
    } catch (e) {
      setState(() => _isLoadingDomains = false);
      SnackbarUtils.showError(
        context,
        'Failed to load domains: ${e.toString()}',
      );
    }
  }

  Future<void> _saveLessonPlan({required bool isDraft}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDomain == null) {
      SnackbarUtils.showError(context, 'Please select a framework domain');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to save lesson plan');
        setState(() => _isSaving = false);
        return;
      }

      // Build the payload
      final data = {
        'lesson_plan_teacher': authState.user.fullName,
        'lesson_plan_classroom': 'THE DISCOVERERS Room A',
        'lesson_plan_type': _selectedType,
        'lesson_plan_status': isDraft ? 'Draft' : _selectedStatus,
        'lesson_plan_title_of_lesson': _titleController.text.trim(),
        'lesson_plan_objective': _objectiveController.text.trim(),
        'lesson_plan_materials': _materialsController.text.trim(),
        'lesson_plan_subject': _selectedDomain?.domainTitle ?? '',
        'framework_domain': _selectedDomain?.name ?? '',
        'lesson_plan_date': DateTime.now().toIso8601String().split('T').first,
        'lesson_plan_week_start': _getWeekStart()
            .toIso8601String()
            .split('T')
            .first,
      };

      // TODO: Call repository to create lesson plan
      // final repository = di.sl<LessonPlanRepository>();
      // await repository.createLessonPlan(data);

      setState(() => _isSaving = false);

      SnackbarUtils.showSuccess(
        context,
        isDraft
            ? 'Lesson plan saved as draft!'
            : 'Lesson plan submitted successfully!',
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      SnackbarUtils.showError(context, 'Failed to save: ${e.toString()}');
    }
  }

  DateTime _getWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return now.subtract(Duration(days: weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'New Lesson Entry',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Monthly Theme
              _buildThemeCard(theme, colorScheme),
              const SizedBox(height: 20),

              // Framework Domain Selection
              _buildDomainSelector(theme, colorScheme),
              const SizedBox(height: 20),

              // Title
              _buildTextField(
                controller: _titleController,
                label: 'Title of the Lesson',
                hint: 'Enter lesson title...',
                maxLines: 1,
              ),
              const SizedBox(height: 16),

              // Objective
              _buildTextField(
                controller: _objectiveController,
                label: 'Objective',
                hint: 'Enter learning objective...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Materials Needed
              _buildTextField(
                controller: _materialsController,
                label: 'Materials Needed',
                hint: 'List materials required...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Monthly Theme',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All About Me & My World',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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

  Widget _buildDomainSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Framework Domain',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        if (_isLoadingDomains)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_domains.isEmpty)
          const Text('No framework domains available')
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _domains.map((domain) {
                final isSelected = _selectedDomain?.name == domain.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDomain = domain;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surface,

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.5),
                      ),

                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      domain.domainTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _getShortDomainName(String fullName) {
    // Shorten long names for display in grid
    if (fullName.length > 18) {
      final words = fullName.split(' ');
      if (words.length > 2) {
        return '${words[0]} ${words[1]}';
      }
      return fullName.substring(0, 16) + '...';
    }
    return fullName;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
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
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => _saveLessonPlan(isDraft: true),
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
              'Save Draft',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : () => _saveLessonPlan(isDraft: false),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit to Admin',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
