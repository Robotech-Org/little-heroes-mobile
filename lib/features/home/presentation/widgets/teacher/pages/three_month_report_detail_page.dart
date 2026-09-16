import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/assessment_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/competency_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/level_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/competency_repository.dart';
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

  // Competency data from API
  List<CompetencyModel> _competencies = [];
  bool _isLoadingCompetencies = true;

  // Selected domain for dropdown
  String? _selectedDomain;

  // Note controllers — one per assessment row, keyed by competency code
  final Map<String, TextEditingController> _noteControllers = {};

  final List<String> _statusOptions = [
    'Draft',
    'Saved',
    'Submitted',
    'Reviewed',
  ];

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
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadCompetencies(), _loadReport()]);
  }

  Future<void> _loadCompetencies() async {
    try {
      final competencyRepository = di.sl<CompetencyRepository>();
      final response = await competencyRepository.getCompetencies(
        page: 1,
        pageSize: 100,
      );
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
      debugPrint('Failed to load competencies: $e');
    }
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

      // Map the assessments with competency data from API
      final mappedAssessments = report.assessments.map((assessment) {
        // Look up competency metadata (title, domain)
        final competency = _competencies.firstWhere(
          (c) =>
              c.competencyCode == assessment.competency ||
              c.title == assessment.competencyTitle,
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

        // Try to resolve level description from the competency levels
        String? levelDescription = assessment.levelDescription;
        if (levelDescription == null || levelDescription.isEmpty) {
          final level = competency.levels.firstWhere(
            (l) => l.level == assessment.levelAchieved,
            orElse: () => LevelModel(level: 0, description: ''),
          );
          if (level.description.isNotEmpty) {
            levelDescription = level.description;
          }
        }

        return AssessmentModel(
          name: assessment.name,
          domain: competency.domain,
          competency: competency.competencyCode,
          competencyTitle: competency.title,
          levelAchieved: assessment.levelAchieved,
          levelDescription: levelDescription,
          notes: assessment.notes ?? '', // ✅ keep real notes
        );
      }).toList();

      // Seed note controllers from the loaded assessments
      _noteControllers.clear();
      for (final a in mappedAssessments) {
        _noteControllers[a.competency] = TextEditingController(
          text: a.notes ?? '',
        );
      }

      if (!mounted) return;
      setState(() {
        _report = report;
        _editableStatus = report.status;
        _editableAssessments = List.from(mappedAssessments);
        _isLoading = false;
        _isEditing = false;
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

  Future<void> _updateReport() async {
    if (_report == null) return;

    setState(() => _isUpdating = true);

    try {
      final repository = di.sl<ThreeMonthReportRepository>();

      final assessedItems = _editableAssessments
          .where((e) => e.levelAchieved >= 0)
          .toList();

      final assessmentsData = assessedItems.asMap().entries.map((entry) {
        final index = entry.key;
        final assessment = entry.value;

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

        // ✅ Pull the note from the controller (source of truth while editing)
        final noteText =
            _noteControllers[competency.competencyCode]?.text ??
            assessment.notes ??
            '';

        final assessmentData = {
          'competency': competency.competencyCode,
          'level_achieved': assessment.levelAchieved,
          'notes': noteText,
          'domain': competency.domain,
          'competency_title': competency.title,
          'idx': index + 1,
        };

        if (assessment.name.isNotEmpty) {
          assessmentData['name'] = assessment.name;
        }

        return assessmentData;
      }).toList();

      final data = {'status': _editableStatus, 'assessments': assessmentsData};

      final updatedReport = await repository.updateThreeMonthReport(
        reportName: widget.reportName,
        data: data,
      );

      if (!mounted) return;
      setState(() {
        _report = updatedReport;
        _editableStatus = updatedReport.status;
        _editableAssessments = List.from(updatedReport.assessments);
        _isEditing = false;
        _isUpdating = false;
      });

      SnackbarUtils.showSuccess(context, 'Report updated successfully!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      SnackbarUtils.showError(
        context,
        'Failed to update report: ${e.toString()}',
      );
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      setState(() {
        _isEditing = false;
        if (_report != null) {
          _editableStatus = _report!.status;
          _editableAssessments = List.from(_report!.assessments);
          // Reset controllers to server values
          for (final a in _editableAssessments) {
            _noteControllers[a.competency]?.text = a.notes ?? '';
          }
        }
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _showLevelSelector(BuildContext context, int index) {
    final assessment = _editableAssessments[index];

    final competency = _competencies.firstWhere(
      (c) =>
          c.competencyCode == assessment.competency ||
          c.title == assessment.competencyTitle,
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
      SnackbarUtils.showError(
        context,
        'No levels available for this competency',
      );
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
                  itemBuilder: (context, levelIndex) {
                    final level = levels[levelIndex];
                    final isSelected = level.level == assessment.levelAchieved;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _editableAssessments[index] = AssessmentModel(
                            name: assessment.name,
                            domain: competency.domain,
                            competency: competency.competencyCode,
                            competencyTitle: competency.title,
                            levelAchieved: level.level,
                            levelDescription: level.description,
                            notes: assessment.notes,
                          );
                        });
                        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '3 Month Assessment',
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
          if (_report != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: _toggleEdit,
              tooltip: 'Edit Report',
            ),
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

  Widget _buildStudentNameCard(ThemeData theme, ColorScheme colorScheme) {
    final name = _report!.studentName;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Student  ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading || _isLoadingCompetencies) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) return _buildErrorWidget(theme, colorScheme);
    if (_report == null) return _buildEmptyWidget(theme, colorScheme);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentNameCard(theme, colorScheme),
          const SizedBox(height: 16),
          _buildDomainSelector(theme, colorScheme),
          const SizedBox(height: 16),
          _buildDevelopmentFrameworks(theme, colorScheme),
          const SizedBox(height: 20),
          if (_isEditing) _buildUpdateButton(theme, colorScheme),
        ],
      ),
    );
  }

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
              final assessed = _editableAssessments
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentFrameworks(ThemeData theme, ColorScheme colorScheme) {
    final assessments = _isEditing
        ? _editableAssessments
        : _report!.assessments;

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

    // Filter by selected domain
    List<CompetencyModel> filteredCompetencies;
    if (_selectedDomain == null) {
      filteredCompetencies = _competencies;
    } else {
      filteredCompetencies = _competencies
          .where((c) => c.domain == _selectedDomain)
          .toList();
    }
    filteredCompetencies.sort((a, b) => a.sequence.compareTo(b.sequence));

    if (filteredCompetencies.isEmpty) {
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
                        '${filteredCompetencies.length} competencies • '
                        '${_getAssessedCount(_selectedDomain!, assessments)} assessed',
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
          ...filteredCompetencies.map((competency) {
            final existingAssessmentIndex = assessments.indexWhere(
              (a) => a.competency == competency.competencyCode,
            );

            final hasAssessment = existingAssessmentIndex >= 0;
            final existingAssessment = hasAssessment
                ? assessments[existingAssessmentIndex]
                : AssessmentModel(
                    name: '',
                    domain: competency.domain,
                    competency: competency.competencyCode,
                    competencyTitle: competency.title,
                    levelAchieved: -1,
                    notes: '',
                  );

            final level = hasAssessment && existingAssessment.levelAchieved >= 0
                ? competency.levels.firstWhere(
                    (l) => l.level == existingAssessment.levelAchieved,
                    orElse: () => LevelModel(level: 0, description: ''),
                  )
                : null;

            return _buildFrameworkCard(
              theme,
              colorScheme,
              competency,
              existingAssessment,
              level,
              hasAssessment && existingAssessment.levelAchieved >= 0,
              hasAssessment ? existingAssessmentIndex : -1,
            );
          }),
        ],
      ),
    );
  }

  int _getAssessedCount(String domain, List<AssessmentModel> assessments) {
    return assessments
        .where((a) => a.domain == domain && a.levelAchieved >= 0)
        .length;
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
    // Use the controller for the current note text
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
          // ── Header row (competency + level chip) ────────────────
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
                onTap: _isEditing
                    ? () {
                        if (index < 0) {
                          setState(() {
                            _editableAssessments.add(
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
                      }
                    : null,
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
                      if (_isEditing)
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

          // ── Level 1..5 selector ─────────────────────────────────
          Row(
            children: List.generate(5, (i) {
              final levelNumber = i + 1;
              final isSelected =
                  hasLevel && level != null && level.level == levelNumber;
              return Expanded(
                child: GestureDetector(
                  onTap: _isEditing
                      ? () {
                          if (index < 0) {
                            setState(() {
                              _editableAssessments.add(
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
                              orElse: () => LevelModel(
                                level: levelNumber,
                                description: '',
                              ),
                            );
                            setState(() {
                              _editableAssessments[index] = AssessmentModel(
                                name: _editableAssessments[index].name,
                                domain: competency.domain,
                                competency: competency.competencyCode,
                                competencyTitle: competency.title,
                                levelAchieved: levelNumber,
                                levelDescription: selectedLevel.description,
                                notes: controller.text,
                              );
                            });
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
          ),

          // ── Level description text ─────────────────────────────
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
          if (!hasLevel && !_isEditing) ...[
            const SizedBox(height: 4),
            Text(
              'Not assessed yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],

          // ── EDIT MODE: notes input ─────────────────────────────
          if (_isEditing) ...[
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
                // Keep _editableAssessments in sync so the save flow picks it up
                if (index >= 0 && index < _editableAssessments.length) {
                  final prev = _editableAssessments[index];
                  _editableAssessments[index] = AssessmentModel(
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

          // ── READ MODE: show note if present ────────────────────
          if (!_isEditing) ...[
            Builder(
              builder: (_) {
                final noteText = controller.text.trim();
                if (noteText.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            noteText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
