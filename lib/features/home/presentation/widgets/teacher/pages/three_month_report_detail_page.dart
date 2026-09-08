// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
// import 'package:little_heroes_mobile/features/home/data/models/assessment_model.dart';
// import 'package:little_heroes_mobile/features/home/data/models/competency_model.dart';
// import 'package:little_heroes_mobile/features/home/data/models/level_model.dart';
// import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
// import 'package:little_heroes_mobile/features/home/domain/repositories/competency_repository.dart';
// import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
// import 'package:little_heroes_mobile/injection_container.dart' as di;

// class ThreeMonthReportDetailPage extends StatefulWidget {
//   final String reportName;

//   const ThreeMonthReportDetailPage({super.key, required this.reportName});

//   @override
//   State<ThreeMonthReportDetailPage> createState() =>
//       _ThreeMonthReportDetailPageState();
// }

// class _ThreeMonthReportDetailPageState
//     extends State<ThreeMonthReportDetailPage> {
//   ThreeMonthReportModel? _report;
//   bool _isLoading = true;
//   bool _isError = false;
//   bool _isEditing = false;
//   bool _isUpdating = false;
//   String _errorMessage = '';

//   // Editable fields
//   late String _editableStatus;
//   late List<AssessmentModel> _editableAssessments;

//   // Competency data from API
//   List<CompetencyModel> _competencies = [];
//   bool _isLoadingCompetencies = true;

//   // Status options
//   final List<String> _statusOptions = [
//     'Draft',
//     'Saved',
//     'Submitted',
//     'Reviewed',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await Future.wait([_loadCompetencies(), _loadReport()]);
//   }

//   Future<void> _loadCompetencies() async {
//     try {
//       final competencyRepository = di.sl<CompetencyRepository>();
//       final response = await competencyRepository.getCompetencies(
//         page: 1,
//         pageSize: 100,
//       );
//       setState(() {
//         _competencies = response.items;
//         _isLoadingCompetencies = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingCompetencies = false;
//       });
//       print('Failed to load competencies: $e');
//     }
//   }

//   Future<void> _loadReport() async {
//     setState(() {
//       _isLoading = true;
//       _isError = false;
//     });

//     try {
//       final authState = context.read<AuthBloc>().state;
//       if (authState is! AuthAuthenticated) {
//         setState(() {
//           _isLoading = false;
//           _isError = true;
//           _errorMessage = 'Please login to view report';
//         });
//         return;
//       }

//       final repository = di.sl<ThreeMonthReportRepository>();
//       final report = await repository.getThreeMonthReport(widget.reportName);

//       // Map the assessments with competency data from API
//       final mappedAssessments = report.assessments.map((assessment) {
//         String competencyCode = assessment.competency;
//         String domain = assessment.domain;
//         String competencyTitle = assessment.competencyTitle;

//         // Try to find the competency from API data
//         final competency = _competencies.firstWhere(
//           (c) =>
//               c.competencyCode == assessment.competency ||
//               c.name == assessment.competency ||
//               c.title == assessment.competencyTitle,
//           orElse: () => CompetencyModel(
//             name: assessment.competency,
//             domain: assessment.domain,
//             domainTitle: '',
//             competencyCode: assessment.competency,
//             title: assessment.competencyTitle,
//             sequence: 0,
//             maxLevel: 5,
//             isActive: 1,
//             creation: '',
//             modified: '',
//             levels: [],
//           ),
//         );

//         // Use the competency code from API
//         competencyCode = competency.competencyCode;
//         domain = competency.domain;
//         competencyTitle = competency.title;

//         // Get the level description if available
//         String? levelDescription;
//         final level = competency.levels.firstWhere(
//           (l) => l.level == assessment.levelAchieved,
//           orElse: () => LevelModel(level: 0, description: ''),
//         );
//         if (level.description.isNotEmpty) {
//           levelDescription = level.description;
//         }

//         return AssessmentModel(
//           name: assessment.name,
//           domain: domain,
//           competency: competencyCode,
//           competencyTitle: competencyTitle,
//           levelAchieved: assessment.levelAchieved,
//           levelDescription: levelDescription ?? assessment.levelDescription,
//           notes: assessment.notes,
//         );
//       }).toList();

//       setState(() {
//         _report = report;
//         _editableStatus = report.status;
//         _editableAssessments = List.from(mappedAssessments);
//         _isLoading = false;
//         _isEditing = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _isError = true;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   Future<void> _updateReport() async {
//     if (_report == null) return;

//     setState(() => _isUpdating = true);

//     try {
//       final repository = di.sl<ThreeMonthReportRepository>();

//       // Filter assessments that have a level selected (levelAchieved >= 0)
//       final assessedItems = _editableAssessments
//           .where((e) => e.levelAchieved >= 0)
//           .toList();

//       // Map assessments with proper row indices (starting from 1)
//       final assessmentsData = assessedItems.asMap().entries.map((entry) {
//         final index = entry.key;
//         final assessment = entry.value;

//         // Find the competency from API data
//         final competency = _competencies.firstWhere(
//           (c) => c.competencyCode == assessment.competency,
//           orElse: () => CompetencyModel(
//             name: assessment.competency,
//             domain: assessment.domain,
//             domainTitle: '',
//             competencyCode: assessment.competency,
//             title: assessment.competencyTitle,
//             sequence: 0,
//             maxLevel: 5,
//             isActive: 1,
//             creation: '',
//             modified: '',
//             levels: [],
//           ),
//         );

//         final assessmentData = {
//           'competency': competency.competencyCode,
//           'level_achieved': assessment.levelAchieved,
//           'notes': assessment.notes ?? '',
//           'domain': competency.domain,
//           'competency_title': competency.title,
//           'idx': index + 1,
//         };

//         // Add the name field if it exists (for updating existing records)
//         if (assessment.name.isNotEmpty) {
//           assessmentData['name'] = assessment.name;
//         }

//         return assessmentData;
//       }).toList();

//       // Prepare the data for update
//       final data = {'status': _editableStatus, 'assessments': assessmentsData};

//       print('📤 Sending update data:');
//       print('Status: ${_editableStatus}');
//       print('Assessments count: ${assessmentsData.length}');
//       assessmentsData.asMap().forEach((idx, item) {
//         print(
//           '  Row ${idx + 1}: ${item['competency']} - Level ${item['level_achieved']} - Name: ${item['name'] ?? 'NEW'}',
//         );
//       });

//       final updatedReport = await repository.updateThreeMonthReport(
//         reportName: widget.reportName,
//         data: data,
//       );

//       setState(() {
//         _report = updatedReport;
//         _editableStatus = updatedReport.status;
//         _editableAssessments = List.from(updatedReport.assessments);
//         _isEditing = false;
//         _isUpdating = false;
//       });

//       SnackbarUtils.showSuccess(context, 'Report updated successfully!');
//     } catch (e) {
//       print('❌ Update error: $e');
//       setState(() => _isUpdating = false);
//       SnackbarUtils.showError(
//         context,
//         'Failed to update report: ${e.toString()}',
//       );
//     }
//   }

//   void _toggleEdit() {
//     if (_isEditing) {
//       // Cancel edit - revert changes
//       setState(() {
//         _isEditing = false;
//         if (_report != null) {
//           _editableStatus = _report!.status;
//           _editableAssessments = List.from(_report!.assessments);
//         }
//       });
//     } else {
//       setState(() => _isEditing = true);
//     }
//   }

//   void _showLevelSelector(BuildContext context, int index) {
//     final assessment = _editableAssessments[index];

//     // Find the competency from API data
//     final competency = _competencies.firstWhere(
//       (c) =>
//           c.competencyCode == assessment.competency ||
//           c.title == assessment.competencyTitle,
//       orElse: () => CompetencyModel(
//         name: assessment.competency,
//         domain: assessment.domain,
//         domainTitle: '',
//         competencyCode: assessment.competency,
//         title: assessment.competencyTitle,
//         sequence: 0,
//         maxLevel: 5,
//         isActive: 1,
//         creation: '',
//         modified: '',
//         levels: [],
//       ),
//     );

//     if (competency.levels.isEmpty) {
//       SnackbarUtils.showError(
//         context,
//         'No levels available for this competency',
//       );
//       return;
//     }

//     // Sort levels by level number
//     final levels = competency.levels.toList()
//       ..sort((a, b) => a.level.compareTo(b.level));

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Select Level',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 competency.title,
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 250,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: levels.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 12),
//                   itemBuilder: (context, levelIndex) {
//                     final level = levels[levelIndex];
//                     final isSelected = level.level == assessment.levelAchieved;

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _editableAssessments[index] = AssessmentModel(
//                             name: assessment.name,
//                             domain: competency.domain,
//                             competency: competency.competencyCode,
//                             competencyTitle: competency.title,
//                             levelAchieved: level.level,
//                             levelDescription: level.description,
//                             notes: assessment.notes,
//                           );
//                         });
//                         Navigator.pop(context);
//                         SnackbarUtils.showSuccess(
//                           context,
//                           'Level ${level.level} selected for ${competency.title}',
//                         );
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         width: 140,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Theme.of(context).colorScheme.primaryContainer
//                               : Theme.of(context).colorScheme.surfaceVariant
//                                     .withValues(alpha: 0.3),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: isSelected
//                                 ? Theme.of(context).colorScheme.primary
//                                 : Colors.transparent,
//                             width: 2.5,
//                           ),
//                           boxShadow: isSelected
//                               ? [
//                                   BoxShadow(
//                                     color: Theme.of(context).colorScheme.primary
//                                         .withValues(alpha: 0.2),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Theme.of(context).colorScheme.primary
//                                           .withValues(alpha: 0.2)
//                                     : Colors.transparent,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '${level.level}',
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.w800,
//                                     color: isSelected
//                                         ? Theme.of(context).colorScheme.primary
//                                         : Theme.of(context)
//                                               .colorScheme
//                                               .onSurfaceVariant,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               level.description,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected
//                                     ? Theme.of(context)
//                                           .colorScheme
//                                           .onPrimaryContainer
//                                     : Theme.of(context)
//                                           .colorScheme
//                                           .onSurfaceVariant,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text(
//           '3 Month Assessment',
//           style: const TextStyle(fontWeight: FontWeight.w700),
//         ),
//         backgroundColor: colorScheme.surface,
//         foregroundColor: colorScheme.onSurface,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           if (_report != null && !_isEditing) ...[
//             IconButton(
//               icon: const Icon(Icons.edit_rounded),
//               onPressed: _toggleEdit,
//               tooltip: 'Edit Report',
//             ),
//           ],
//           if (_isEditing) ...[
//             TextButton(
//               onPressed: _isUpdating ? null : _toggleEdit,
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: _isUpdating ? null : _updateReport,
//               child: _isUpdating
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : const Text(
//                       'Save',
//                       style: TextStyle(fontWeight: FontWeight.w700),
//                     ),
//             ),
//           ],
//         ],
//       ),
//       body: _buildBody(theme, colorScheme),
//     );
//   }

//   Widget _buildStudentNameCard(ThemeData theme, ColorScheme colorScheme) {
//     final name = _report!.studentName;

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
//         boxShadow: [
//           BoxShadow(
//             color: colorScheme.shadow.withValues(alpha: 0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.person_outline_rounded,
//             color: colorScheme.primary,
//             size: 22,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text.rich(
//               TextSpan(
//                 text: 'student ',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: name,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w700,
//                       color: colorScheme.primary,
//                       fontSize: 17,
//                     ),
//                   ),
//                 ],
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           Icon(
//             Icons.chevron_right_rounded,
//             color: colorScheme.primary.withValues(alpha: 0.3),
//             size: 20,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
//     if (_isLoading || _isLoadingCompetencies) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_isError) {
//       return _buildErrorWidget(theme, colorScheme);
//     }

//     if (_report == null) {
//       return _buildEmptyWidget(theme, colorScheme);
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       physics: const BouncingScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildStudentNameCard(theme, colorScheme),
//           const SizedBox(height: 16),

//           // Development Frameworks - ALL Competencies
//           _buildDevelopmentFrameworks(theme, colorScheme),
//           const SizedBox(height: 20),

//           // Save/Update Button (when editing)
//           if (_isEditing) _buildUpdateButton(theme, colorScheme),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD UPDATE BUTTON
//   // ============================================================

//   Widget _buildUpdateButton(ThemeData theme, ColorScheme colorScheme) {
//     return SizedBox(
//       width: double.infinity,
//       height: 54,
//       child: ElevatedButton(
//         onPressed: _isUpdating ? null : _updateReport,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: _isUpdating
//             ? const SizedBox(
//                 height: 24,
//                 width: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   color: Colors.white,
//                 ),
//               )
//             : const Text(
//                 'Save Changes',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD ERROR WIDGET
//   // ============================================================

//   Widget _buildErrorWidget(ThemeData theme, ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               size: 64,
//               color: colorScheme.error,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to load report',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadReport,
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 backgroundColor: colorScheme.primary,
//                 foregroundColor: colorScheme.onPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD EMPTY WIDGET
//   // ============================================================

//   Widget _buildEmptyWidget(ThemeData theme, ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.description_outlined,
//               size: 64,
//               color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Report not found',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'The report you\'re looking for does not exist.',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDevelopmentFrameworks(ThemeData theme, ColorScheme colorScheme) {
//     final assessments = _isEditing
//         ? _editableAssessments
//         : _report!.assessments;

//     // If no competencies, show a message
//     if (_competencies.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: colorScheme.outline.withValues(alpha: 0.08),
//           ),
//         ),
//         child: Center(
//           child: Text(
//             'No framework competencies available',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurfaceVariant,
//             ),
//           ),
//         ),
//       );
//     }

//     // If no assessments, show empty state
//     if (assessments.isEmpty && !_isEditing) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: colorScheme.outline.withValues(alpha: 0.08),
//           ),
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.assessment_outlined,
//                 size: 48,
//                 color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'No assessments added yet',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               if (_isEditing) ...[
//                 const SizedBox(height: 12),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Add a new assessment
//                     _addNewAssessment();
//                   },
//                   icon: const Icon(Icons.add_rounded),
//                   label: const Text('Add Assessment'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.primary,
//                     foregroundColor: colorScheme.onPrimary,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Development Frameworks',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w700,
//               color: colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ..._competencies.asMap().entries.map((entry) {
//             final index = entry.key;
//             final competency = entry.value;

//             // Find if this competency has an assessment
//             final existingAssessmentIndex = assessments.indexWhere(
//               (a) => a.competency == competency.competencyCode,
//             );

//             final hasAssessment = existingAssessmentIndex >= 0;
//             final existingAssessment = hasAssessment
//                 ? assessments[existingAssessmentIndex]
//                 : AssessmentModel(
//                     name: '',
//                     domain: competency.domain,
//                     competency: competency.competencyCode,
//                     competencyTitle: competency.title,
//                     levelAchieved: -1,
//                     notes: '',
//                   );

//             final level = hasAssessment && existingAssessment.levelAchieved >= 0
//                 ? competency.levels.firstWhere(
//                     (l) => l.level == existingAssessment.levelAchieved,
//                     orElse: () => LevelModel(level: 0, description: ''),
//                   )
//                 : null;

//             return _buildFrameworkCard(
//               theme,
//               colorScheme,
//               competency,
//               existingAssessment,
//               level,
//               hasAssessment && existingAssessment.levelAchieved >= 0,
//               hasAssessment ? existingAssessmentIndex : -1,
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   // Add this helper method
//   void _addNewAssessment() {
//     setState(() {
//       _editableAssessments.add(
//         AssessmentModel(
//           name: '',
//           domain: 'Approaches to Learning',
//           competency: 'A',
//           competencyTitle: 'Initiative and Planning',
//           levelAchieved: 0,
//           notes: '',
//         ),
//       );
//     });
//     // Show level selector for the newly added assessment
//     Future.delayed(const Duration(milliseconds: 100), () {
//       _showLevelSelector(context, _editableAssessments.length - 1);
//     });
//   }

//   Widget _buildFrameworkCard(
//     ThemeData theme,
//     ColorScheme colorScheme,
//     CompetencyModel competency,
//     AssessmentModel assessment,
//     LevelModel? level,
//     bool hasLevel,
//     int index,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: hasLevel
//               ? colorScheme.primary.withValues(alpha: 0.15)
//               : colorScheme.outline.withValues(alpha: 0.08),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       competency.title,
//                       style: theme.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     Text(
//                       competency.domain,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Text(
//                 'Development Level',
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               if (hasLevel && level != null)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: colorScheme.primaryContainer.withValues(alpha: 0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'Level ${level.level}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               ...List.generate(5, (levelIndex) {
//                 final levelNumber = levelIndex + 1;
//                 final isSelected =
//                     hasLevel && level != null && level.level == levelNumber;

//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: _isEditing
//                         ? () {
//                             int currentIndex = index;

//                             if (currentIndex < 0) {
//                               setState(() {
//                                 _editableAssessments.add(
//                                   AssessmentModel(
//                                     name: '',
//                                     domain: competency.domain,
//                                     competency: competency.competencyCode,
//                                     competencyTitle: competency.title,
//                                     levelAchieved: levelNumber,
//                                     notes: '',
//                                   ),
//                                 );
//                               });
//                               SnackbarUtils.showSuccess(
//                                 context,
//                                 'Level $levelNumber selected for ${competency.title}',
//                               );
//                             } else {
//                               setState(() {
//                                 _editableAssessments[currentIndex] =
//                                     AssessmentModel(
//                                       name: _editableAssessments[currentIndex]
//                                           .name,
//                                       domain: competency.domain,
//                                       competency: competency.competencyCode,
//                                       competencyTitle: competency.title,
//                                       levelAchieved: levelNumber,
//                                       notes:
//                                           _editableAssessments[currentIndex]
//                                               .notes ??
//                                           '',
//                                     );
//                               });
//                               SnackbarUtils.showSuccess(
//                                 context,
//                                 'Level $levelNumber selected for ${competency.title}',
//                               );
//                             }
//                           }
//                         : null,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 2),
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? colorScheme.primary
//                             : (_isEditing
//                                   ? colorScheme.surfaceVariant.withValues(
//                                       alpha: 0.3,
//                                     )
//                                   : Colors.transparent),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '$levelNumber',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: isSelected
//                                 ? FontWeight.w800
//                                 : FontWeight.w400,
//                             color: isSelected
//                                 ? colorScheme.onPrimary
//                                 : (_isEditing
//                                       ? colorScheme.onSurface
//                                       : colorScheme.onSurfaceVariant),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//           const SizedBox(height: 4),
//           if (hasLevel && level != null)
//             Text(
//               level.description,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//                 fontSize: 11,
//               ),
//             ),
//           if (!hasLevel && !_isEditing)
//             Text(
//               'Not assessed yet',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//                 fontStyle: FontStyle.italic,
//                 fontSize: 11,
//               ),
//             ),
//           if (hasLevel &&
//               assessment.notes != null &&
//               assessment.notes!.isNotEmpty) ...[
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   Icons.note_outlined,
//                   size: 12,
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(
//                     assessment.notes!,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: colorScheme.onSurfaceVariant,
//                       fontSize: 11,
//                       fontStyle: FontStyle.italic,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

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
  bool _showAllDomains = true; // Default to show all

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
    _loadData();
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
      setState(() {
        _competencies = response.items;
        _isLoadingCompetencies = false;
        // Set default selected domain if available
        if (_competencies.isNotEmpty) {
          _selectedDomain = _competencies.first.domain;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCompetencies = false;
      });
      print('Failed to load competencies: $e');
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
        String competencyCode = assessment.competency;
        String domain = assessment.domain;
        String competencyTitle = assessment.competencyTitle;

        // Try to find the competency from API data
        final competency = _competencies.firstWhere(
          (c) =>
              c.competencyCode == assessment.competency ||
              c.name == assessment.competency ||
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

        // Use the competency code from API
        competencyCode = competency.competencyCode;
        domain = competency.domain;
        competencyTitle = competency.title;

        // Get the level description if available
        String? levelDescription;
        final level = competency.levels.firstWhere(
          (l) => l.level == assessment.levelAchieved,
          orElse: () => LevelModel(level: 0, description: ''),
        );
        if (level.description.isNotEmpty) {
          levelDescription = level.description;
        }

        return AssessmentModel(
          name: assessment.name,
          domain: domain,
          competency: competencyCode,
          competencyTitle: competencyTitle,
          levelAchieved: assessment.levelAchieved,
          levelDescription: levelDescription ?? assessment.levelDescription,
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

        // Find the competency from API data
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

        final assessmentData = {
          'competency': competency.competencyCode,
          'level_achieved': assessment.levelAchieved,
          'notes': assessment.notes ?? '',
          'domain': competency.domain,
          'competency_title': competency.title,
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

    // Find the competency from API data
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

    // Sort levels by level number
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
                        SnackbarUtils.showSuccess(
                          context,
                          'Level ${level.level} selected for ${competency.title}',
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
        title: Text(
          '3 Month Assessment',
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

  Widget _buildStudentNameCard(ThemeData theme, ColorScheme colorScheme) {
    final name = _report!.studentName;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                text: 'student ',
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
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.primary.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading || _isLoadingCompetencies) {
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
          _buildStudentNameCard(theme, colorScheme),
          const SizedBox(height: 16),

          // Domain Dropdown Selector
          _buildDomainSelector(theme, colorScheme),
          const SizedBox(height: 16),

          // Development Frameworks - Filtered by selected domain
          _buildDevelopmentFrameworks(theme, colorScheme),
          const SizedBox(height: 20),

          // Save/Update Button (when editing)
          if (_isEditing) _buildUpdateButton(theme, colorScheme),
        ],
      ),
    );
  }

  // ============================================================
  // DOMAIN DROPDOWN SELECTOR
  // ============================================================

  Widget _buildDomainSelector(ThemeData theme, ColorScheme colorScheme) {
    // Get unique domains from competencies
    final domains = _competencies.map((c) => c.domain).toSet().toList()..sort();

    if (domains.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
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
            // Option to show all domains
            DropdownMenuItem<String>(
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
            // Individual domains
            ...domains.map((domain) {
              // Count competencies in this domain
              final count = _competencies
                  .where((c) => c.domain == domain)
                  .length;
              // Count assessed in this domain
              final assessed = _editableAssessments
                  .where((a) => a.domain == domain && a.levelAchieved >= 0)
                  .length;

              return DropdownMenuItem<String>(
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
          onChanged: (String? newValue) {
            setState(() {
              _selectedDomain = newValue;
            });
          },
        ),
      ),
    );
  }

  // Helper to get domain icon
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

  // ============================================================
  // BUILD UPDATE BUTTON
  // ============================================================

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

  // ============================================================
  // BUILD ERROR WIDGET
  // ============================================================

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

  // ============================================================
  // BUILD EMPTY WIDGET
  // ============================================================

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

  // ============================================================
  // BUILD DEVELOPMENT FRAMEWORKS - FILTERED BY DOMAIN
  // ============================================================

  Widget _buildDevelopmentFrameworks(ThemeData theme, ColorScheme colorScheme) {
    final assessments = _isEditing
        ? _editableAssessments
        : _report!.assessments;

    // If no competencies, show a message
    if (_competencies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.08),
          ),
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

    // Filter competencies by selected domain
    List<CompetencyModel> filteredCompetencies;
    if (_selectedDomain == null) {
      // Show all competencies
      filteredCompetencies = _competencies;
    } else {
      // Show only competencies from selected domain
      filteredCompetencies = _competencies
          .where((c) => c.domain == _selectedDomain)
          .toList();
    }

    // Sort by sequence
    filteredCompetencies.sort((a, b) => a.sequence.compareTo(b.sequence));

    // If no competencies in selected domain
    if (filteredCompetencies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No competencies in this domain',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show domain header if a specific domain is selected
    final showDomainHeader = _selectedDomain != null;

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
          // Domain header when a specific domain is selected
          if (showDomainHeader) ...[
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${filteredCompetencies.length} competencies • ${_getAssessedCount(_selectedDomain!, assessments)} assessed',
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

          // Competency cards
          ...filteredCompetencies.asMap().entries.map((entry) {
            final index = entry.key;
            final competency = entry.value;

            // Find if this competency has an assessment
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
          }).toList(),
        ],
      ),
    );
  }

  // Helper to get assessed count for a domain
  int _getAssessedCount(String domain, List<AssessmentModel> assessments) {
    return assessments
        .where((a) => a.domain == domain && a.levelAchieved >= 0)
        .length;
  }

  // ============================================================
  // ADD NEW ASSESSMENT FOR SPECIFIC DOMAIN
  // ============================================================

  void _addNewAssessmentForDomain(String domain) {
    // Get unassessed competencies from this domain
    final unassessedCompetencies = _competencies.where((c) {
      return c.domain == domain &&
          !_editableAssessments.any((a) => a.competency == c.competencyCode);
    }).toList();

    if (unassessedCompetencies.isEmpty) {
      SnackbarUtils.showError(
        context,
        'All competencies in this domain are already assessed',
      );
      return;
    }

    // Show dialog to select a competency
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assessment'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a competency from $_selectedDomain:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: unassessedCompetencies.length,
                    itemBuilder: (context, index) {
                      final competency = unassessedCompetencies[index];

                      return ListTile(
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              competency.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        title: Text(competency.title),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _editableAssessments.add(
                              AssessmentModel(
                                name: '',
                                domain: competency.domain,
                                competency: competency.competencyCode,
                                competencyTitle: competency.title,
                                levelAchieved: 0,
                                notes: '',
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
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD FRAMEWORK CARD (Competency Card)
  // ============================================================

  Widget _buildFrameworkCard(
    ThemeData theme,
    ColorScheme colorScheme,
    CompetencyModel competency,
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
                              color: colorScheme.onSurface,
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
              // Level selector button (editable)
              GestureDetector(
                onTap: _isEditing
                    ? () {
                        int currentIndex = index;
                        if (currentIndex < 0) {
                          setState(() {
                            _editableAssessments.add(
                              AssessmentModel(
                                name: '',
                                domain: competency.domain,
                                competency: competency.competencyCode,
                                competencyTitle: competency.title,
                                levelAchieved: 0,
                                notes: '',
                              ),
                            );
                          });
                          // _showLevelSelector(
                          //   context,
                          //   _editableAssessments.length - 1,
                          // );
                        } else {
                          // _showLevelSelector(context, currentIndex);
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
                      width: 1,
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
          // Level indicators (showing all 5 levels)
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
                                    domain: competency.domain,
                                    competency: competency.competencyCode,
                                    competencyTitle: competency.title,
                                    levelAchieved: levelNumber,
                                    notes: '',
                                  ),
                                );
                              });
                              SnackbarUtils.showSuccess(
                                context,
                                'Level $levelNumber selected for ${competency.title}',
                              );
                            } else {
                              // Find the actual level model for this level number
                              final selectedLevel = competency.levels
                                  .firstWhere(
                                    (l) => l.level == levelNumber,
                                    orElse: () => LevelModel(
                                      level: levelNumber,
                                      description: '',
                                    ),
                                  );

                              setState(() {
                                _editableAssessments[currentIndex] =
                                    AssessmentModel(
                                      name: _editableAssessments[currentIndex]
                                          .name,
                                      domain: competency.domain,
                                      competency: competency.competencyCode,
                                      competencyTitle: competency.title,
                                      levelAchieved: levelNumber,
                                      levelDescription:
                                          selectedLevel.description,
                                      notes:
                                          _editableAssessments[currentIndex]
                                              .notes ??
                                          '',
                                    );
                              });
                              SnackbarUtils.showSuccess(
                                context,
                                'Level $levelNumber selected for ${competency.title}',
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
          if (hasLevel && level != null)
            Text(
              level.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
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
          // Notes input (editable)
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                // initialValue: assessment.notes ?? '',
                decoration: InputDecoration(
                  hintText: 'Add notes...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                onChanged: (value) {
                  final currentIndex = index;
                  if (currentIndex >= 0 &&
                      currentIndex < _editableAssessments.length) {
                    setState(() {
                      _editableAssessments[currentIndex] = AssessmentModel(
                        name: _editableAssessments[currentIndex].name,
                        domain: competency.domain,
                        competency: competency.competencyCode,
                        competencyTitle: competency.title,
                        levelAchieved:
                            _editableAssessments[currentIndex].levelAchieved,
                        levelDescription:
                            _editableAssessments[currentIndex].levelDescription,
                        notes: value,
                      );
                    });
                  }
                },
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              ),
            ),
          // Display notes (read-only)
          if (!_isEditing &&
              assessment.notes != null &&
              assessment.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      assessment.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGACY ADD NEW ASSESSMENT (kept for compatibility)
  // ============================================================

  void _addNewAssessment() {
    // Show a dialog to select a domain first
    final domains = _competencies.map((c) => c.domain).toSet().toList()..sort();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Domain'),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: ListView.builder(
              itemCount: domains.length,
              itemBuilder: (context, index) {
                final domain = domains[index];
                final count = _competencies
                    .where((c) => c.domain == domain)
                    .length;
                final assessed = _editableAssessments
                    .where((a) => a.domain == domain && a.levelAchieved >= 0)
                    .length;

                return ListTile(
                  leading: Icon(
                    _getDomainIcon(domain),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(domain),
                  subtitle: Text('$assessed/$count assessed'),
                  onTap: () {
                    Navigator.pop(context);
                    _addNewAssessmentForDomain(domain);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
