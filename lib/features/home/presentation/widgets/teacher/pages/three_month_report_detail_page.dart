import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/frameworks/learning_framework.dart';
import 'package:little_heroes_mobile/features/home/data/models/assessment_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/framework_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ThreeMonthReportDetailPage extends StatefulWidget {
  final String reportName;

  const ThreeMonthReportDetailPage({super.key, required this.reportName});

  @override
  State<ThreeMonthReportDetailPage> createState() =>
      _ThreeMonthReportDetailPageState();
}

class _ThreeMonthReportDetailPageState
    extends State<ThreeMonthReportDetailPage> {
  ThreeMonthReportModel? _report;
  bool _isLoading = true;
  bool _isError = false;
  bool _isEditing = false;
  bool _isUpdating = false;
  String _errorMessage = '';

  // Editable fields
  late String _editableStatus;
  late List<AssessmentModel> _editableAssessments;

  // Status options
  final List<String> _statusOptions = [
    'Draft',
    'Saved',
    'Submitted',
    'Reviewed',
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
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

      final repository = di.sl<ThreeMonthReportRepository>();
      final report = await repository.getThreeMonthReport(widget.reportName);

      // Map the competencies to framework codes
      final mappedAssessments = report.assessments.map((assessment) {
        // Try to find the correct competency code
        String competencyCode = assessment.competency;

        // Check if competency is a name that needs mapping
        final category = LearningFramework.getAllCategories().firstWhere(
          (cat) =>
              cat.name == assessment.competency ||
              cat.code == assessment.competency,
          orElse: () => CategoryModel(
            id: '',
            name: assessment.competency,
            code: assessment.competency,
            description: '',
            levels: [],
          ),
        );

        // If we found a matching category, use its code
        if (category.code.isNotEmpty) {
          competencyCode = category.code;
        }

        return AssessmentModel(
          name: assessment.name,
          domain: assessment.domain,
          competency: competencyCode,
          competencyTitle: assessment.competencyTitle,
          levelAchieved: assessment.levelAchieved,
          notes: assessment.notes,
        );
      }).toList();

      setState(() {
        _report = report;
        _editableStatus = report.status;
        _editableAssessments = List.from(mappedAssessments);
        _isLoading = false;
        _isEditing = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateReport() async {
    if (_report == null) return;

    setState(() => _isUpdating = true);

    try {
      final repository = di.sl<ThreeMonthReportRepository>();

      // Filter assessments that have a level selected (levelAchieved >= 0)
      final assessedItems = _editableAssessments
          .where((e) => e.levelAchieved >= 0)
          .toList();

      // Map assessments with proper row indices (starting from 1)
      final assessmentsData = assessedItems.asMap().entries.map((entry) {
        final index = entry.key;
        final assessment = entry.value;

        // IMPORTANT: Convert framework code to server competency
        // If assessment.competency is "AL1", convert to "Initiative and Planning"
        // If assessment.competency is "AL2", convert to "Problem Solving with Materials"
        final serverCompetency = LearningFramework.getServerCompetency(
          assessment.competency,
        );

        // Get the server domain
        final serverDomain =
            serverCompetency; // Use the competency as domain for now

        final assessmentData = {
          'competency': serverCompetency, // Send the server-compatible value
          'level_achieved': assessment.levelAchieved,
          'notes': assessment.notes ?? '',
          'domain': serverDomain,
          'competency_title': serverCompetency,
          'idx': index + 1,
        };

        // Add the name field if it exists (for updating existing records)
        if (assessment.name.isNotEmpty) {
          assessmentData['name'] = assessment.name;
        }

        return assessmentData;
      }).toList();

      // Prepare the data for update
      final data = {'status': _editableStatus, 'assessments': assessmentsData};

      print('📤 Sending update data:');
      print('Status: ${_editableStatus}');
      print('Assessments count: ${assessmentsData.length}');
      assessmentsData.asMap().forEach((idx, item) {
        print(
          '  Row ${idx + 1}: ${item['competency']} - Level ${item['level_achieved']} - Name: ${item['name'] ?? 'NEW'}',
        );
      });

      final updatedReport = await repository.updateThreeMonthReport(
        reportName: widget.reportName,
        data: data,
      );

      setState(() {
        _report = updatedReport;
        _editableStatus = updatedReport.status;
        _editableAssessments = List.from(updatedReport.assessments);
        _isEditing = false;
        _isUpdating = false;
      });

      SnackbarUtils.showSuccess(context, 'Report updated successfully!');
    } catch (e) {
      print('❌ Update error: $e');
      setState(() => _isUpdating = false);
      SnackbarUtils.showError(
        context,
        'Failed to update report: ${e.toString()}',
      );
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Cancel edit - revert changes
      setState(() {
        _isEditing = false;
        if (_report != null) {
          _editableStatus = _report!.status;
          _editableAssessments = List.from(_report!.assessments);
        }
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _showLevelSelector(BuildContext context, int index) {
    final assessment = _editableAssessments[index];

    // Find the category by code or name
    CategoryModel? category = LearningFramework.getCategoryByCode(
      assessment.competency,
    );
    if (category == null) {
      category = LearningFramework.getCategoryByName(
        assessment.competencyTitle,
      );
    }

    // Early return if category is still null
    if (category == null) {
      SnackbarUtils.showError(context, 'Category not found');
      return;
    }

    // Now category is guaranteed to be non-null
    final nonNullCategory = category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                nonNullCategory.name, // Now safe to use
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: nonNullCategory.levels.length, // Now safe
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, levelIndex) {
                    final level = nonNullCategory.levels[levelIndex];
                    final isSelected = level.level == assessment.levelAchieved;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _editableAssessments[index] = AssessmentModel(
                            name: assessment.name,
                            domain: nonNullCategory.name,
                            competency: nonNullCategory.code,
                            competencyTitle: nonNullCategory.name,
                            levelAchieved: level.level,
                            notes: assessment.notes,
                          );
                        });
                        Navigator.pop(context);
                        SnackbarUtils.showSuccess(
                          context,
                          'Level ${level.level} selected for ${nonNullCategory.name}',
                        );
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
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.2)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
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
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              level.indicator ?? '',
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
                            const SizedBox(height: 4),
                            Text(
                              level.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withValues(alpha: 0.7)
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '3 Month Report',
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
        actions: [
          if (_report != null && !_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: _toggleEdit,
              tooltip: 'Edit Report',
            ),
          ],
          if (_isEditing) ...[
            TextButton(
              onPressed: _isUpdating ? null : _toggleEdit,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isUpdating ? null : _updateReport,
              child: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ],
      ),
      body: _buildBody(theme, colorScheme),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return _buildErrorWidget(theme, colorScheme);
    }

    if (_report == null) {
      return _buildEmptyWidget(theme, colorScheme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(theme, colorScheme),
          const SizedBox(height: 16),

          // Student Info
          _buildStudentInfo(theme, colorScheme),
          const SizedBox(height: 16),

          // Status Section
          _buildStatusSection(theme, colorScheme),
          const SizedBox(height: 16),

          // Development Progress
          _buildDevelopmentProgress(theme, colorScheme),
          const SizedBox(height: 16),

          // Development Frameworks - ALL 8 Categories
          _buildDevelopmentFrameworks(theme, colorScheme),
          const SizedBox(height: 20),

          // Save/Update Button (when editing)
          if (_isEditing) _buildUpdateButton(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(_report!.status, colorScheme);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
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
                    Text(
                      '${_report!.month} ${_report!.year}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 Month Assessment Report',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _report!.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(_report!.reportDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _report!.teacher,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Editing Mode',
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
      ),
    );
  }

  Widget _buildStudentInfo(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.5),
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(_report!.studentName),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _report!.studentName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _report!.classroom,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_report!.assessments.length}/8',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _editableStatus,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        onChanged: _isUpdating
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _editableStatus = value);
                                }
                              },
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status, colorScheme),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(status),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getStatusColor(_report!.status, colorScheme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _report!.status,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentProgress(ThemeData theme, ColorScheme colorScheme) {
    final total = 8;
    final completed = _report!.assessments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$completed/$total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Development Progress',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completed / total,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed of $total completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    if (!_isEditing)
                      Text(
                        '${(completed / total * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentFrameworks(ThemeData theme, ColorScheme colorScheme) {
    // Get ALL 8 categories from the framework
    final allCategories = LearningFramework.getAllCategories();
    final assessments = _isEditing
        ? _editableAssessments
        : _report!.assessments;

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
          Text(
            'Development Frameworks',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...allCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            // Find if this category has an assessment
            final existingAssessmentIndex = assessments.indexWhere(
              (a) => a.competency == category.code,
            );

            final hasAssessment = existingAssessmentIndex >= 0;
            final existingAssessment = hasAssessment
                ? assessments[existingAssessmentIndex]
                : AssessmentModel(
                    name: '',
                    domain: category.name,
                    competency: category.code,
                    competencyTitle: category.name,
                    levelAchieved: -1,
                    notes: '',
                  );

            final level = hasAssessment && existingAssessment.levelAchieved >= 0
                ? category.levels.firstWhere(
                    (l) => l.level == existingAssessment.levelAchieved,
                    orElse: () => category.levels.first,
                  )
                : null;

            return _buildFrameworkCard(
              theme,
              colorScheme,
              category,
              existingAssessment,
              level,
              hasAssessment && existingAssessment.levelAchieved >= 0,
              hasAssessment ? existingAssessmentIndex : -1,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFrameworkCard(
    ThemeData theme,
    ColorScheme colorScheme,
    CategoryModel category,
    AssessmentModel assessment,
    LevelModel? level,
    bool hasLevel,
    int index,
  ) {
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
                    Text(
                      category.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      category.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isEditing)
                IconButton(
                  icon: Icon(
                    hasLevel ? Icons.edit_rounded : Icons.add_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    // Get the next available row index
                    final nextRowIndex =
                        _editableAssessments
                            .where((e) => e.levelAchieved >= 0)
                            .length +
                        1;

                    // If not in list, add a new assessment
                    if (index < 0) {
                      setState(() {
                        _editableAssessments.add(
                          AssessmentModel(
                            name: '',
                            domain: category.name,
                            competency: category.code,
                            competencyTitle: category.name,
                            levelAchieved: 0,
                            notes: '',
                            // No idx here - it will be added when saving
                          ),
                        );
                      });
                      // Show level selector for the newly added assessment
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _showLevelSelector(
                          context,
                          _editableAssessments.length - 1,
                        );
                      });
                    } else {
                      // Show level selector for existing assessment
                      _showLevelSelector(context, index);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Development Level Row - Like the image
          Row(
            children: [
              Text(
                'Development Level',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              if (hasLevel && level != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Level ${level.level}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Level numbers 1-5 (like the image) - FIXED: Always clickable in edit mode
          Row(
            children: [
              ...List.generate(5, (levelIndex) {
                final levelNumber = levelIndex + 1;
                final isSelected =
                    hasLevel && level != null && level.level == levelNumber;

                return Expanded(
                  child: GestureDetector(
                    onTap: _isEditing
                        ? () {
                            int currentIndex = index;

                            if (currentIndex < 0) {
                              setState(() {
                                _editableAssessments.add(
                                  AssessmentModel(
                                    name: '',
                                    domain: category.name,
                                    competency: category.code, // Use the code
                                    competencyTitle: category.name,
                                    levelAchieved: levelNumber,
                                    notes: '',
                                  ),
                                );
                              });
                              SnackbarUtils.showSuccess(
                                context,
                                'Level $levelNumber selected for ${category.name}',
                              );
                            } else {
                              setState(() {
                                _editableAssessments[currentIndex] =
                                    AssessmentModel(
                                      name: _editableAssessments[currentIndex]
                                          .name,
                                      domain: category.name,
                                      competency: category.code, // Use the code
                                      competencyTitle: category.name,
                                      levelAchieved: levelNumber,
                                      notes:
                                          _editableAssessments[currentIndex]
                                              .notes ??
                                          '',
                                    );
                              });
                              SnackbarUtils.showSuccess(
                                context,
                                'Level $levelNumber selected for ${category.name}',
                              );
                            }
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : (_isEditing
                                  ? colorScheme.surfaceVariant.withValues(
                                      alpha: 0.3,
                                    )
                                  : Colors.transparent),
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
                                : (_isEditing
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          // Level description
          if (hasLevel && level != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    level.indicator ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (hasLevel && level != null)
            Text(
              level.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (!hasLevel && !_isEditing)
            Text(
              'Not assessed yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          if (hasLevel &&
              assessment.notes != null &&
              assessment.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    assessment.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpdateButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUpdating
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colorScheme) {
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
              'Failed to load report',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Report not found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The report you\'re looking for does not exist.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green;
      case 'saved':
        return colorScheme.primary;
      case 'draft':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      case 'reviewed':
        return Colors.blue;
      default:
        return colorScheme.primary;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}
