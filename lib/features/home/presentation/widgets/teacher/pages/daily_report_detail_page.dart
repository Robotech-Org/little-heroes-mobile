// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
// import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
// import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
// import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
// import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
// import 'package:little_heroes_mobile/injection_container.dart' as di;

// class DailyReportDetailPage extends StatefulWidget {
//   final String reportName;

//   const DailyReportDetailPage({super.key, required this.reportName});

//   @override
//   State<DailyReportDetailPage> createState() => _DailyReportDetailPageState();
// }

// class _DailyReportDetailPageState extends State<DailyReportDetailPage> {
//   final _formKey = GlobalKey<FormState>();

//   DailyReportModel? _report;
//   bool _isLoading = true;
//   bool _isError = false;
//   bool _isEditing = false;
//   bool _isUpdating = false;
//   String _errorMessage = '';

//   // Student selection
//   List<Student> _students = [];
//   Student? _selectedStudent;
//   bool _isLoadingStudents = true;

//   // Editable fields
//   String _selectedMeal = 'Ate All';
//   String _selectedNap = 'Slept Well (1-2+ Hours)';
//   String _selectedMood = 'Happy & Engaged';
//   String _selectedHealth = 'Good / Normal';
//   String _messageToParent = '';

//   // Updated options from JSON
//   final List<String> _mealOptions = [
//     'Ate All',
//     'Ate Most',
//     'Ate Some',
//     'Ate Very Little',
//     'Refused / Did Not Eat',
//     'Not Applicable',
//   ];

//   final List<String> _napOptions = [
//     'Slept Well (1-2+ Hours)',
//     'Short Nap (<1 Hour)',
//     'Rest Only (No Sleep)',
//     'Did Not Sleep',
//     'Not Applicable',
//   ];

//   final List<String> _moodOptions = [
//     'Happy & Engaged',
//     'Calm & Content',
//     'Energetic & Playful',
//     'Fussy / Crying',
//     'Tired / Sensitive',
//     'Challenging / Needed Support',
//   ];

//   final List<String> _healthOptions = [
//     'Good / Normal',
//     'Potty / Diaper Normal',
//     'Medication Administered',
//     'Minor Symptoms (Runny nose/Cough)',
//     'Needs Monitoring / Parent Contact',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await Future.wait([_loadStudents(), _loadReport()]);
//   }

//   Future<void> _loadStudents() async {
//     setState(() => _isLoadingStudents = true);

//     try {
//       final authState = context.read<AuthBloc>().state;
//       if (authState is! AuthAuthenticated) {
//         setState(() => _isLoadingStudents = false);
//         return;
//       }

//       final repository = di.sl<StudentRepository>();
//       final response = await repository.getStudents(page: 1, pageSize: 100);

//       print("=== STUDENT RESPONSE ===");
//       print("Number of students: ${response.items.length}");

//       for (var i = 0; i < response.items.length; i++) {
//         final student = response.items[i];
//         print("Student $i: ");
//         print("  - ID: ${student.id}");
//         print("  - Name: ${student.name}");
//         print("---");
//       }

//       setState(() {
//         _students = response.items;
//         _isLoadingStudents = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingStudents = false);
//       print('Failed to load students: $e');
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

//       final repository = di.sl<DailyReportRepository>();
//       final report = await repository.getDailyReport(widget.reportName);

//       setState(() {
//         _report = report;
//         _isLoading = false;
//         _populateFields(report);
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _isError = true;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   void _populateFields(DailyReportModel report) {
//     // Find the student by name
//     _selectedStudent = _students.firstWhere(
//       (s) => s.name == report.studentName,
//       orElse: () => Student(
//         id: report.name ?? '',
//         name: report.studentName,
//         gender: '',
//         dateOfBirth: '',
//         ageRange: '',
//         enrollmentStatus: '',
//         creation: '',
//         modified: '',
//       ),
//     );

//     // Map old values to new values if needed
//     _selectedMeal = _mapMealValue(report.mealsAndSnacks);
//     _selectedNap = _mapNapValue(report.napTime);
//     _selectedMood = _mapMoodValue(report.moodAndBehavior);
//     _selectedHealth = _mapHealthValue(report.healthAndHygiene);
//     _messageToParent = report.dailyReportNotes;
//   }

//   // Helper methods to map old values to new ones
//   String _mapMealValue(String value) {
//     final mapping = {
//       'Ate Well': 'Ate All',
//       'Ate Most': 'Ate Most',
//       'Ate Some': 'Ate Some',
//       'Ate Very Little': 'Ate Very Little',
//       'Refused': 'Refused / Did Not Eat',
//       'Not Applicable': 'Not Applicable',
//     };
//     if (_mealOptions.contains(value)) return value;
//     return mapping[value] ?? 'Ate All';
//   }

//   String _mapNapValue(String value) {
//     final mapping = {
//       'Slept Well': 'Slept Well (1-2+ Hours)',
//       'Short Nap': 'Short Nap (<1 Hour)',
//       'Rest Only': 'Rest Only (No Sleep)',
//       'Did Not Sleep': 'Did Not Sleep',
//       'Not Applicable': 'Not Applicable',
//     };
//     if (_napOptions.contains(value)) return value;
//     return mapping[value] ?? 'Slept Well (1-2+ Hours)';
//   }

//   String _mapMoodValue(String value) {
//     final mapping = {
//       'Happy': 'Happy & Engaged',
//       'Playful': 'Energetic & Playful',
//       'Quiet': 'Calm & Content',
//       'Fussy': 'Fussy / Crying',
//       'Tired': 'Tired / Sensitive',
//       'Challenging': 'Challenging / Needed Support',
//     };
//     if (_moodOptions.contains(value)) return value;
//     return mapping[value] ?? 'Happy & Engaged';
//   }

//   String _mapHealthValue(String value) {
//     final mapping = {
//       'No Concerns': 'Good / Normal',
//       'Runny Nose': 'Minor Symptoms (Runny nose/Cough)',
//       'Cough': 'Minor Symptoms (Runny nose/Cough)',
//       'Fever': 'Needs Monitoring / Parent Contact',
//       'Good': 'Good / Normal',
//       'Normal': 'Good / Normal',
//     };
//     if (_healthOptions.contains(value)) return value;
//     return mapping[value] ?? 'Good / Normal';
//   }

//   void _toggleEdit() {
//     if (_isEditing) {
//       // Cancel edit - revert changes
//       setState(() {
//         _isEditing = false;
//         if (_report != null) {
//           _populateFields(_report!);
//         }
//       });
//     } else {
//       setState(() => _isEditing = true);
//     }
//   }

//   Future<void> _updateReport() async {
//     if (_selectedStudent == null) {
//       SnackbarUtils.showError(context, 'Please select a student');
//       return;
//     }

//     setState(() => _isUpdating = true);

//     try {
//       final authState = context.read<AuthBloc>().state;
//       if (authState is! AuthAuthenticated) {
//         SnackbarUtils.showError(context, 'Please login to update report');
//         setState(() => _isUpdating = false);
//         return;
//       }

//       // Get the current date in the expected format
//       final now = DateTime.now();
//       final reportDate =
//           '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

//       final data = {
//         'student': _selectedStudent!.id,
//         'student_name': _selectedStudent!.name,
//         // 'student_classroom': "THE DISCOVERERS Room A",
//         'student_classroom': _report?.studentClassroom ?? '', // ← use existing

//         'report_date': reportDate,
//         'meals_and_snacks': _selectedMeal,
//         'nap_time': _selectedNap,
//         'mood_and_behavior': _selectedMood,
//         'health_and_hygiene': _selectedHealth,
//         'daily_report_notes': _messageToParent,
//         'daily_report_status': 'Saved',
//         'recorded_by': authState.user.fullName,
//       };

//       print("Updating report...");
//       print(data.toString());

//       final repository = di.sl<DailyReportRepository>();

//       await repository.updateDailyReport(
//         reportName: widget.reportName,
//         data: data,
//       );

//       setState(() {
//         _isEditing = false;
//         _isUpdating = false;
//       });

//       SnackbarUtils.showSuccess(context, 'Report updated successfully!');

//       // Reload the report to show updated values
//       await _loadReport();
//     } catch (e) {
//       setState(() => _isUpdating = false);
//       SnackbarUtils.showError(context, 'Failed to update: ${e.toString()}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Daily Report',
//           style: TextStyle(fontWeight: FontWeight.w700),
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
//                       'Update',
//                       style: TextStyle(fontWeight: FontWeight.w700),
//                     ),
//             ),
//           ],
//         ],
//       ),
//       body: _buildBody(theme, colorScheme),
//     );
//   }

//   Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
//     if (_isLoading || _isLoadingStudents) {
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
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Student Selector (editable in edit mode)
//             _buildStudentSelector(theme, colorScheme),
//             const SizedBox(height: 24),

//             // Meals & Snacks
//             _buildOptionSelector(
//               theme: theme,
//               colorScheme: colorScheme,
//               label: 'Meals & Snacks',
//               value: _selectedMeal,
//               options: _mealOptions,
//               icon: Icons.restaurant_rounded,
//               enabled: _isEditing,
//               onChanged: (value) {
//                 setState(() => _selectedMeal = value);
//               },
//             ),

//             const SizedBox(height: 20),

//             // Nap Time
//             _buildOptionSelector(
//               theme: theme,
//               colorScheme: colorScheme,
//               label: 'Nap Time',
//               value: _selectedNap,
//               options: _napOptions,
//               icon: Icons.bed_rounded,
//               enabled: _isEditing,
//               onChanged: (value) {
//                 setState(() => _selectedNap = value);
//               },
//             ),

//             const SizedBox(height: 20),

//             // Mood & Behavior
//             _buildOptionSelector(
//               theme: theme,
//               colorScheme: colorScheme,
//               label: 'Mood & Behavior',
//               value: _selectedMood,
//               options: _moodOptions,
//               icon: Icons.emoji_emotions_rounded,
//               enabled: _isEditing,
//               onChanged: (value) {
//                 setState(() => _selectedMood = value);
//               },
//             ),

//             const SizedBox(height: 20),

//             // Health & Hygiene
//             _buildOptionSelector(
//               theme: theme,
//               colorScheme: colorScheme,
//               label: 'Health & Hygiene',
//               value: _selectedHealth,
//               options: _healthOptions,
//               icon: Icons.health_and_safety_rounded,
//               enabled: _isEditing,
//               onChanged: (value) {
//                 setState(() => _selectedHealth = value);
//               },
//             ),

//             const SizedBox(height: 20),

//             // Message to Parent
//             _buildMessageField(theme, colorScheme),
//             const SizedBox(height: 32),

//             // Update Button
//             if (_isEditing) _buildUpdateButton(theme, colorScheme),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionSelector({
//     required ThemeData theme,
//     required ColorScheme colorScheme,
//     required String label,
//     required String value,
//     required List<String> options,
//     required ValueChanged<String> onChanged,
//     IconData? icon,
//     bool enabled = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             if (icon != null) ...[
//               Icon(icon, size: 20, color: colorScheme.primary),
//               const SizedBox(width: 8),
//             ],
//             Text(
//               label,
//               style: theme.textTheme.titleSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: options.map((option) {
//             final isSelected = value == option;

//             return GestureDetector(
//               onTap: enabled && !_isUpdating ? () => onChanged(option) : null,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected ? colorScheme.primary : colorScheme.surface,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isSelected
//                         ? colorScheme.primary
//                         : colorScheme.primary.withValues(alpha: 0.3),
//                     width: 1.5,
//                   ),
//                   boxShadow: isSelected
//                       ? [
//                           BoxShadow(
//                             color: colorScheme.primary.withValues(alpha: 0.2),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ]
//                       : null,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (isSelected) ...[
//                       Icon(
//                         Icons.check_rounded,
//                         size: 16,
//                         color: colorScheme.onPrimary,
//                       ),
//                       const SizedBox(width: 5),
//                     ],
//                     Text(
//                       option,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: isSelected
//                             ? colorScheme.onPrimary
//                             : colorScheme.onSurface,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildStudentSelector(ThemeData theme, ColorScheme colorScheme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Student name display as a row
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: colorScheme.outline.withValues(alpha: 0.08),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     _selectedStudent?.initials ?? '?',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _selectedStudent?.name ?? 'No student selected',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     if (_selectedStudent != null) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         _selectedStudent!.statusText,
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: _selectedStudent!.isActive
//                               ? Colors.green
//                               : colorScheme.onSurfaceVariant,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               // Show a small indicator
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withValues(alpha: 0.08),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _selectedStudent?.isActive == true ? 'Active' : 'Inactive',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: _selectedStudent?.isActive == true
//                         ? Colors.green
//                         : colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMessageField(ThemeData theme, ColorScheme colorScheme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.message_rounded, size: 20, color: colorScheme.primary),
//             const SizedBox(width: 8),
//             Text(
//               'Message to Parent',
//               style: theme.textTheme.titleSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           initialValue: _messageToParent,
//           maxLines: 4,
//           enabled: _isEditing && !_isUpdating,
//           decoration: InputDecoration(
//             hintText: 'Write a message to the parent...',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: _isEditing
//                 ? colorScheme.surfaceVariant.withValues(alpha: 0.3)
//                 : colorScheme.surfaceVariant.withValues(alpha: 0.1),
//             contentPadding: const EdgeInsets.all(16),
//             hintStyle: TextStyle(
//               color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: colorScheme.outline.withValues(alpha: 0.1),
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: colorScheme.primary),
//             ),
//           ),
//           style: TextStyle(color: colorScheme.onSurface),
//           onChanged: (value) => _messageToParent = value,
//         ),
//       ],
//     );
//   }

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
//           elevation: 2,
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
//                 'Update Report',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//       ),
//     );
//   }

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
// }

// lib/features/home/presentation/widgets/teacher/pages/daily_report_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/constants/daily_report_options.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class DailyReportDetailPage extends StatefulWidget {
  final String reportName;

  const DailyReportDetailPage({super.key, required this.reportName});

  @override
  State<DailyReportDetailPage> createState() => _DailyReportDetailPageState();
}

class _DailyReportDetailPageState extends State<DailyReportDetailPage> {
  final _formKey = GlobalKey<FormState>();

  DailyReportModel? _report;
  bool _isLoading = true;
  bool _isError = false;
  bool _isEditing = false;
  bool _isUpdating = false;
  String _errorMessage = '';

  // ── Student ────────────────────────────────────────────
  List<Student> _students = [];
  Student? _selectedStudent;
  bool _isLoadingStudents = true;

  // ── Editable state (mirrors form) ──────────────────────
  String _selectedMeal = DailyReportOptions.defaultMeal;
  String _selectedNap = DailyReportOptions.defaultNap;
  String _selectedMood = DailyReportOptions.defaultMood;
  String _selectedHealth = DailyReportOptions.defaultHealth;
  String _selectedActivity = DailyReportOptions.defaultActivity;
  String _selectedDiaper = DailyReportOptions.defaultDiaper;
  String _messageToParent = '';

  // Notes controllers
  final _mealNotesController = TextEditingController();
  final _napNotesController = TextEditingController();
  final _napDurationController = TextEditingController();
  final _moodNotesController = TextEditingController();
  final _activityNotesController = TextEditingController();
  final _diaperNotesController = TextEditingController();
  final _healthNotesController = TextEditingController();
  final _specialNotesController = TextEditingController();
  final _messageController = TextEditingController();

  // Reminders
  bool _reminderBringClothes = false;
  final _reminderClothesDetailsController = TextEditingController();
  bool _reminderBringToyBlanket = false;
  final _reminderToyBlanketDetailsController = TextEditingController();
  bool _reminderUpcomingEvent = false;
  final _reminderUpcomingEventDetailsController = TextEditingController();
  bool _reminderOther = false;
  final _reminderOtherDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _mealNotesController.dispose();
    _napNotesController.dispose();
    _napDurationController.dispose();
    _moodNotesController.dispose();
    _activityNotesController.dispose();
    _diaperNotesController.dispose();
    _healthNotesController.dispose();
    _specialNotesController.dispose();
    _messageController.dispose();
    _reminderClothesDetailsController.dispose();
    _reminderToyBlanketDetailsController.dispose();
    _reminderUpcomingEventDetailsController.dispose();
    _reminderOtherDetailsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadStudents(), _loadReport()]);
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

      final repository = di.sl<DailyReportRepository>();
      final report = await repository.getDailyReport(widget.reportName);

      setState(() {
        _report = report;
        _isLoading = false;
        _populateFields(report);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _populateFields(DailyReportModel report) {
    _selectedStudent = _students.firstWhere(
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

    // Selections
    _selectedMeal = _mapMealValue(report.mealsAndSnacks);
    _selectedNap = _mapNapValue(report.napTime);
    _selectedMood = _mapMoodValue(report.moodAndBehavior);
    _selectedHealth = _mapHealthValue(report.healthAndHygiene);
    _selectedActivity = report.learningAndPlayActivities.isNotEmpty
        ? report.learningAndPlayActivities
        : DailyReportOptions.defaultActivity;
    _selectedDiaper = report.diaperToiletTraining.isNotEmpty
        ? report.diaperToiletTraining
        : DailyReportOptions.defaultDiaper;

    // Notes
    _mealNotesController.text = report.mealsAndSnacksNotes;
    _napNotesController.text = report.napTimeNotes;
    _napDurationController.text = report.napDuration;
    _moodNotesController.text = report.moodAndBehaviorNotes;
    _activityNotesController.text = report.learningAndPlayActivitiesNotes;
    _diaperNotesController.text = report.diaperToiletTrainingNotes;
    _healthNotesController.text = report.healthCheckNotes;
    _specialNotesController.text = report.specialNotesAndReminders;

    // Message
    _messageToParent = report.dailyReportNotes;
    _messageController.text = report.dailyReportNotes;

    // Reminders
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
  }

  // ═══════════════════════════════════════════════════════
  // Value mappers
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
  // Edit toggle
  // ═══════════════════════════════════════════════════════
  void _toggleEdit() {
    if (_isEditing) {
      setState(() {
        _isEditing = false;
        if (_report != null) _populateFields(_report!);
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  // ═══════════════════════════════════════════════════════
  // Update report
  // ═══════════════════════════════════════════════════════
  Future<void> _updateReport() async {
    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to update report');
        setState(() => _isUpdating = false);
        return;
      }

      final data = <String, dynamic>{
        'student': _selectedStudent!.id,
        'student_classroom': _report?.studentClassroom ?? '',
        'report_date': _report?.reportDate ?? _todayString(),
        'daily_report_status': _report?.dailyReportStatus ?? 'Saved',

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

        // ── Health ──────────────────────────────────────
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

      final repository = di.sl<DailyReportRepository>();
      await repository.updateDailyReport(
        reportName: widget.reportName,
        data: data,
      );

      setState(() {
        _isEditing = false;
        _isUpdating = false;
      });

      SnackbarUtils.showSuccess(context, 'Report updated successfully!');
      await _loadReport();
    } catch (e) {
      setState(() => _isUpdating = false);
      SnackbarUtils.showError(context, 'Failed to update: ${e.toString()}');
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
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
        title: const Text(
          'Daily Report',
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
                      'Update',
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
    if (_isLoading || _isLoadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) return _buildErrorWidget(theme, colorScheme);
    if (_report == null) return _buildEmptyWidget(theme, colorScheme);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentCard(theme, colorScheme),
            const SizedBox(height: 24),

            _buildReportMeta(theme, colorScheme),
            const SizedBox(height: 24),

            // ── Meals & Snacks ─────────────────────────
            _buildOptionSelector(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Meals & Snacks',
              value: _selectedMeal,
              options: DailyReportOptions.meals,
              icon: Icons.restaurant_rounded,
              enabled: _isEditing,
              onChanged: (v) => setState(() => _selectedMeal = v),
            ),
            const SizedBox(height: 8),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _mealNotesController,
              hint: 'Meal notes...',
            ),
            const SizedBox(height: 20),

            // ── Nap ────────────────────────────────────
            _buildOptionSelector(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Nap Time',
              value: _selectedNap,
              options: DailyReportOptions.naps,
              icon: Icons.bed_rounded,
              enabled: _isEditing,
              onChanged: (v) => setState(() => _selectedNap = v),
            ),
            const SizedBox(height: 8),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _napDurationController,
              hint: 'Nap duration...',
              maxLines: 1,
            ),
            const SizedBox(height: 6),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _napNotesController,
              hint: 'Nap notes...',
            ),
            const SizedBox(height: 20),

            // ── Mood ───────────────────────────────────
            _buildOptionSelector(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Mood & Behavior',
              value: _selectedMood,
              options: DailyReportOptions.moods,
              icon: Icons.emoji_emotions_rounded,
              enabled: _isEditing,
              onChanged: (v) => setState(() => _selectedMood = v),
            ),
            const SizedBox(height: 8),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _moodNotesController,
              hint: 'Mood notes...',
            ),
            const SizedBox(height: 20),

            // ── Learning & Play ────────────────────────
            _buildOptionSelector(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Learning & Play Activities',
              value: _selectedActivity,
              options: DailyReportOptions.activities,
              icon: Icons.toys_rounded,
              enabled: _isEditing,
              onChanged: (v) => setState(() => _selectedActivity = v),
            ),
            const SizedBox(height: 8),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _activityNotesController,
              hint: 'Activity notes...',
            ),
            const SizedBox(height: 20),

            // ── Diaper / Toilet ────────────────────────
            _buildOptionSelector(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Diaper Changes / Toilet Training',
              value: _selectedDiaper,
              options: DailyReportOptions.diaperOptions,
              icon: Icons.child_care_rounded,
              enabled: _isEditing,
              onChanged: (v) => setState(() => _selectedDiaper = v),
            ),
            const SizedBox(height: 8),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _diaperNotesController,
              hint: 'Diaper / toilet notes...',
            ),
            const SizedBox(height: 20),

            // ── Health ─────────────────────────────────
            _buildOptionSelector(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Health & Hygiene',
              value: _selectedHealth,
              options: DailyReportOptions.healthChecks,
              icon: Icons.health_and_safety_rounded,
              enabled: _isEditing,
              onChanged: (v) => setState(() => _selectedHealth = v),
            ),
            const SizedBox(height: 8),
            _buildNotesField(
              colorScheme: colorScheme,
              controller: _healthNotesController,
              hint: 'Health notes...',
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
              hint: 'Additional notes...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // ── Message to Parent ──────────────────────
            _buildMessageField(theme, colorScheme),
            const SizedBox(height: 32),

            if (_isEditing) _buildUpdateButton(theme, colorScheme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Report meta — status, date, recorded-by
  // ═══════════════════════════════════════════════════════
  Widget _buildReportMeta(ThemeData theme, ColorScheme colorScheme) {
    final report = _report!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                report.reportDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              _statusChip(theme, colorScheme, report.dailyReportStatus),
            ],
          ),
          if (report.recordedBy.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recorded by ${report.recordedBy}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(ThemeData theme, ColorScheme colorScheme, String status) {
    final isSaved = status.toLowerCase() == 'saved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSaved
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isSaved ? Colors.green.shade700 : Colors.orange.shade800,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Section label
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

  // ═══════════════════════════════════════════════════════
  // Notes field — read-only unless editing
  // ═══════════════════════════════════════════════════════
  Widget _buildNotesField({
    required ColorScheme colorScheme,
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
  }) {
    // In view mode: hide if empty
    if (!_isEditing && controller.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return TextFormField(
      controller: controller,
      enabled: _isEditing && !_isUpdating,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _isEditing
            ? colorScheme.surfaceVariant.withValues(alpha: 0.15)
            : colorScheme.surfaceVariant.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
      style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Option selector — pills, read-only when not editing
  // ═══════════════════════════════════════════════════════
  Widget _buildOptionSelector({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    IconData? icon,
    bool enabled = true,
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
        if (!enabled)
          // Read-only mode: show only the selected value as a chip
          _readOnlyValueChip(theme, colorScheme, value)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = value == option;
              return GestureDetector(
                onTap: _isUpdating ? null : () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
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
      ],
    );
  }

  Widget _readOnlyValueChip(
    ThemeData theme,
    ColorScheme colorScheme,
    String value,
  ) {
    if (value.trim().isEmpty) {
      return Text(
        '—',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
          fontSize: 13,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Student card
  // ═══════════════════════════════════════════════════════
  Widget _buildStudentCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _selectedStudent?.initials ?? '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
                  _selectedStudent?.name ?? 'No student selected',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_selectedStudent != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _selectedStudent!.statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _selectedStudent!.isActive
                          ? Colors.green
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedStudent?.isActive == true ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _selectedStudent?.isActive == true
                    ? Colors.green
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Reminders — read-only view / editable checkboxes
  // ═══════════════════════════════════════════════════════
  Widget _buildRemindersSection(ThemeData theme, ColorScheme colorScheme) {
    final anyReminders =
        _reminderBringClothes ||
        _reminderBringToyBlanket ||
        _reminderUpcomingEvent ||
        _reminderOther;

    if (!_isEditing && !anyReminders) return const SizedBox.shrink();

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
          onChanged: (v) => setState(() => _reminderBringClothes = v),
        ),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Bring toy / blanket',
          value: _reminderBringToyBlanket,
          detailsController: _reminderToyBlanketDetailsController,
          onChanged: (v) => setState(() => _reminderBringToyBlanket = v),
        ),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Upcoming event',
          value: _reminderUpcomingEvent,
          detailsController: _reminderUpcomingEventDetailsController,
          onChanged: (v) => setState(() => _reminderUpcomingEvent = v),
        ),
        _buildReminderTile(
          theme,
          colorScheme,
          title: 'Other',
          value: _reminderOther,
          detailsController: _reminderOtherDetailsController,
          onChanged: (v) => setState(() => _reminderOther = v),
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
    // In read-only mode, only show enabled reminders
    if (!_isEditing && !value) return const SizedBox.shrink();

    final details = detailsController.text.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: _isEditing
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: _isEditing
          ? Column(
              children: [
                CheckboxListTile(
                  value: value,
                  onChanged: _isUpdating ? null : (v) => onChanged(v ?? false),
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
                      enabled: !_isUpdating,
                      maxLength: 140,
                      decoration: InputDecoration(
                        hintText: 'Details (optional)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withValues(
                          alpha: 0.15,
                        ),
                        isDense: true,
                        counterText: '',
                      ),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          details,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
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
    final hasContent = _messageToParent.trim().isNotEmpty;
    if (!_isEditing && !hasContent) return const SizedBox.shrink();

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
          enabled: _isEditing && !_isUpdating,
          decoration: InputDecoration(
            hintText: 'Write a message to the parent...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: _isEditing
                ? colorScheme.surfaceVariant.withValues(alpha: 0.3)
                : colorScheme.surfaceVariant.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(color: colorScheme.onSurface),
          onChanged: (value) => _messageToParent = value,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // Update button
  // ═══════════════════════════════════════════════════════
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
          elevation: 2,
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
                'Update Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // Error / Empty
  // ═══════════════════════════════════════════════════════
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
}
