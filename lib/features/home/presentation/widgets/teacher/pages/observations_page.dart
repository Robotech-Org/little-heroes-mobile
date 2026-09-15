// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
// import 'package:little_heroes_mobile/features/home/data/models/observation_model.dart';
// import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
// import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
// import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
// import 'package:little_heroes_mobile/injection_container.dart' as di;

// import 'add_observation_page.dart';

// class ObservationsPage extends StatefulWidget {
//   const ObservationsPage({super.key});

//   @override
//   State<ObservationsPage> createState() => _ObservationsPageState();
// }

// class _ObservationsPageState extends State<ObservationsPage> {
//   List<ObservationModel> _observations = [];
//   List<Student> _students = [];
//   List<Student> _filteredStudents = [];
//   bool _isLoading = true;
//   bool _isError = false;
//   String _errorMessage = '';
//   int _currentPage = 1;
//   int _totalPages = 0;
//   int _totalObservations = 0;
//   final int _pageSize = 20;

//   // Search
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
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
//           _errorMessage = 'Please login to view observations';
//         });
//         return;
//       }

//       // Load students first
//       final studentRepository = di.sl<StudentRepository>();
//       final studentResponse = await studentRepository.getStudents(
//         page: 1,
//         pageSize: 100,
//       );
//       _students = studentResponse.items;
//       _filteredStudents = _students;

//       // Load observations
//       final observationRepository = di.sl<ObservationRepository>();
//       final response = await observationRepository.getObservations(
//         page: _currentPage,
//         pageSize: _pageSize,
//       );

//       setState(() {
//         _observations = response.items;
//         _totalObservations = response.total;
//         _totalPages = (response.total / response.pageSize).ceil();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _isError = true;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   void _filterStudents(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredStudents = _students;
//       } else {
//         _filteredStudents = _students.where((student) {
//           return student.name.toLowerCase().contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }

//   int _observationCount(Student student) {
//     return _observations.where((item) => item.student == student.id).length;
//   }

//   void _openObservationForm(Student student) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//             AddObservationPage(student: student, onSave: () => _loadData()),
//       ),
//     );
//   }

//   void _opennewObservationForm() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddObservationPage(onSave: () => _loadData()),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Observations',
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
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _loadData,
//             tooltip: 'Refresh',
//           ),
//           IconButton(
//             icon: const Icon(Icons.add_rounded),
//             onPressed: _opennewObservationForm,
//             tooltip: 'Add Observation',
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadData,
//         child: _buildContent(theme, colorScheme),
//       ),
//     );
//   }

//   Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
//     if (_isLoading) {
//       return _buildSkeletonLoading(theme, colorScheme);
//     }

//     if (_isError) {
//       return _buildErrorWidget(theme, colorScheme);
//     }

//     if (_students.isEmpty) {
//       return _buildEmptyWidget(theme, colorScheme);
//     }

//     return Column(
//       children: [
//         // Search Bar
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
//           child: _buildSearchBar(theme, colorScheme),
//         ),
//         // Stats
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Row(
//             children: [
//               const Spacer(),
//               if (_searchController.text.isNotEmpty)
//                 Text(
//                   '${_filteredStudents.length} of ${_students.length}',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//                     fontSize: 11,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         // Student List
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
//             physics: const BouncingScrollPhysics(),
//             children: [
//               ..._filteredStudents.map(
//                 (student) => _StudentCard(
//                   student: student,
//                   count: _observationCount(student),
//                   onTap: () => _openObservationForm(student),
//                   colorScheme: colorScheme,
//                   theme: theme,
//                 ),
//               ),
//               if (_filteredStudents.isEmpty)
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       children: [
//                         Icon(
//                           Icons.search_off_rounded,
//                           size: 48,
//                           color: colorScheme.onSurfaceVariant.withValues(
//                             alpha: 0.5,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           'No students found',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.onSurfaceVariant,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
//     return TextField(
//       controller: _searchController,
//       onChanged: _filterStudents,
//       decoration: InputDecoration(
//         hintText: 'Search students...',
//         prefixIcon: Icon(
//           Icons.search_rounded,
//           color: colorScheme.onSurfaceVariant,
//         ),
//         suffixIcon: _searchController.text.isNotEmpty
//             ? IconButton(
//                 icon: Icon(
//                   Icons.clear_rounded,
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//                 onPressed: () {
//                   _searchController.clear();
//                   _filterStudents('');
//                 },
//               )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: colorScheme.outline.withValues(alpha: 0.2),
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: colorScheme.outline.withValues(alpha: 0.2),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: colorScheme.primary),
//         ),
//         filled: true,
//         fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
//         contentPadding: const EdgeInsets.symmetric(vertical: 4),
//       ),
//     );
//   }

//   // ============================================================
//   // SKELETON LOADING
//   // ============================================================

//   Widget _buildSkeletonLoading(ThemeData theme, ColorScheme colorScheme) {
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         // Search bar skeleton
//         Container(
//           height: 48,
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         const SizedBox(height: 12),
//         // Stats skeleton
//         _buildSkeletonLine(width: 120, height: 14),
//         const SizedBox(height: 12),
//         // Student cards skeletons
//         ...List.generate(5, (index) {
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: colorScheme.surface,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(
//                 color: colorScheme.outline.withValues(alpha: 0.08),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 54,
//                   height: 54,
//                   decoration: BoxDecoration(
//                     color: colorScheme.surfaceVariant,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSkeletonLine(width: 120, height: 18),
//                       const SizedBox(height: 4),
//                       _buildSkeletonLine(width: 80, height: 14),
//                       const SizedBox(height: 6),
//                       _buildSkeletonLine(width: 100, height: 20),
//                     ],
//                   ),
//                 ),
//                 _buildSkeletonLine(width: 24, height: 24),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildSkeletonLine({double? width, double height = 16}) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }

//   // ============================================================
//   // ERROR WIDGET
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
//               'Failed to load data',
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
//               onPressed: _loadData,
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
//   // EMPTY WIDGET
//   // ============================================================

//   Widget _buildEmptyWidget(ThemeData theme, ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.people_outline_rounded,
//               size: 64,
//               color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Students Found',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: colorScheme.onSurface,
//               ),
//             ),

//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _opennewObservationForm,
//               icon: const Icon(Icons.add_rounded),
//               label: const Text('Add Observation'),
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
// }

// // ============================================================
// // STUDENT CARD
// // ============================================================

// class _StudentCard extends StatelessWidget {
//   final Student student;
//   final int count;
//   final VoidCallback onTap;
//   final ColorScheme colorScheme;
//   final ThemeData theme;

//   const _StudentCard({
//     required this.student,
//     required this.count,
//     required this.onTap,
//     required this.colorScheme,
//     required this.theme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final name = student.name.trim();
//     final initial = name.isEmpty ? '?' : name[0].toUpperCase();

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//         side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.08)),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 width: 54,
//                 height: 54,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       colorScheme.primaryContainer,
//                       colorScheme.primaryContainer.withValues(alpha: 0.5),
//                     ],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   initial,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: colorScheme.onPrimaryContainer,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       student.name,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       student.ageRange,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: colorScheme.primaryContainer.withValues(
//                           alpha: 0.1,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '$count ${count == 1 ? 'observation' : 'observations'}',
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right_rounded,
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/observation_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/observation_detail_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/student_observations_page.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'add_observation_page.dart';

class ObservationsPage extends StatefulWidget {
  const ObservationsPage({super.key});

  @override
  State<ObservationsPage> createState() => _ObservationsPageState();
}

class _ObservationsPageState extends State<ObservationsPage> {
  List<ObservationModel> _observations = [];
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalObservations = 0;
  final int _pageSize = 20;

  // Search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
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
          _errorMessage = 'Please login to view observations';
        });
        return;
      }

      // Load students first
      final studentRepository = di.sl<StudentRepository>();
      final studentResponse = await studentRepository.getStudents(
        page: 1,
        pageSize: 100,
      );
      _students = studentResponse.items;
      _filteredStudents = _students;

      // Load observations
      final observationRepository = di.sl<ObservationRepository>();
      final response = await observationRepository.getObservations(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _observations = response.items;
        _totalObservations = response.total;
        _totalPages = (response.total / response.pageSize).ceil();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          return student.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  int _observationCount(Student student) {
    return _observations.where((item) => item.student == student.id).length;
  }

  void _openObservationForm(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentObservationsPage(student: student),
      ),
    ).then((_) => _loadData());
  }

  void _opennewObservationForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddObservationPage(onSave: () => _loadData()),
      ),
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
          'Observations',
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _opennewObservationForm,
            tooltip: 'Add Observation',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildContent(theme, colorScheme),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return _buildSkeletonLoading(theme, colorScheme);
    }

    if (_isError) {
      return _buildErrorWidget(theme, colorScheme);
    }

    if (_students.isEmpty && _observations.isEmpty) {
      return _buildEmptyWidget(theme, colorScheme);
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: _buildSearchBar(theme, colorScheme),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Spacer(),
              if (_searchController.text.isNotEmpty)
                Text(
                  '${_filteredStudents.length} of ${_students.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Scrollable body: recent observations + student list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── Recent observations section ─────────────────

              // ── Student list section header ─────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Select a student',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Student cards ───────────────────────────────
              ..._filteredStudents.map(
                (student) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _StudentCard(
                    student: student,
                    count: _observationCount(student),
                    onTap: () => _openObservationForm(student),
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                ),
              ),

              // ── Empty search result ─────────────────────────
              if (_filteredStudents.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No students found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      onChanged: _filterStudents,
      decoration: InputDecoration(
        hintText: 'Search students...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  _searchController.clear();
                  _filterStudents('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  // ============================================================
  // SKELETON LOADING
  // ============================================================

  Widget _buildSkeletonLoading(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Search bar skeleton
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 20),

        // "Recent observations" header skeleton
        _buildSkeletonLine(width: 160, height: 14),
        const SizedBox(height: 12),

        // Recent observation tiles skeletons
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                // Thumbnail skeleton
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: 140, height: 14),
                      const SizedBox(height: 6),
                      _buildSkeletonLine(width: 100, height: 12),
                      const SizedBox(height: 6),
                      _buildSkeletonLine(width: 180, height: 12),
                    ],
                  ),
                ),
                _buildSkeletonLine(width: 16, height: 16),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),

        // "Select a student" header skeleton
        _buildSkeletonLine(width: 140, height: 14),
        const SizedBox(height: 12),

        // Student cards skeletons
        ...List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: 120, height: 18),
                      const SizedBox(height: 4),
                      _buildSkeletonLine(width: 80, height: 14),
                      const SizedBox(height: 6),
                      _buildSkeletonLine(width: 100, height: 20),
                    ],
                  ),
                ),
                _buildSkeletonLine(width: 24, height: 24),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSkeletonLine({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ============================================================
  // ERROR WIDGET
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
              'Failed to load data',
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
              onPressed: _loadData,
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
  // EMPTY WIDGET
  // ============================================================

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Students Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _opennewObservationForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Observation'),
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
}

// ============================================================
// STUDENT CARD
// ============================================================

class _StudentCard extends StatelessWidget {
  final Student student;
  final int count;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _StudentCard({
    required this.student,
    required this.count,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final name = student.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  initial,
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
                      student.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.ageRange,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'observation' : 'observations'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
