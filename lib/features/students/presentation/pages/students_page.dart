import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/students/presentation/pages/student_details_page.dart';

import '../../data/datasources/student_mock_data_source.dart';
import '../../domain/entities/student.dart';
import '../widgets/student_card.dart';
import '../widgets/student_search.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final StudentMockDataSource _dataSource = const StudentMockDataSource();

  final TextEditingController _searchController = TextEditingController();

  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // LOAD STUDENTS

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    final students = await _dataSource.getStudents();

    if (!mounted) {
      return;
    }

    setState(() {
      _allStudents = students;
      _filteredStudents = students;
      _isLoading = false;
    });
  }

  // SEARCH

  void _searchStudents(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      setState(() {
        _filteredStudents = _allStudents;
      });

      return;
    }

    final results = _allStudents.where((student) {
      return student.name.toLowerCase().contains(value) ||
          student.grade.toLowerCase().contains(value) ||
          student.className.toLowerCase().contains(value);
    }).toList();

    setState(() {
      _filteredStudents = results;
    });
  }

  // OPEN STUDENT

  void _openStudent(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudentDetailsPage(student: student)),
    );
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Students',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),

        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,

        elevation: 0,

        surfaceTintColor: Colors.transparent,
      ),

      body: RefreshIndicator(
        onRefresh: _loadStudents,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),

          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

          children: [
            // ==
            // HEADER
            // ==

            Text(
              'Students',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Find and manage your students.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            // ==
            // SEARCH
            // ==
            StudentSearch(
              controller: _searchController,
              onChanged: _searchStudents,
            ),

            const SizedBox(height: 20),

            // ==
            // STUDENT COUNT
            // ==
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Student List',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    '${_filteredStudents.length}',

                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==
            // LOADING
            // ==
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 70),

                child: Center(child: CircularProgressIndicator()),
              )
            // ==
            // EMPTY SEARCH RESULT
            // ==
            else if (_filteredStudents.isEmpty)
              _EmptyStudents(searchQuery: _searchController.text)
            // ==
            // STUDENT LIST
            // ==
            else
              ..._filteredStudents.map((student) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  child: StudentCard(
                    student: student,

                    onTap: () {
                      _openStudent(student);
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// EMPTY STUDENTS

class _EmptyStudents extends StatelessWidget {
  final String searchQuery;

  const _EmptyStudents({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasSearch = searchQuery.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),

      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),

            child: Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,

              size: 34,

              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            hasSearch ? 'No students found' : 'No students yet',

            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            hasSearch
                ? 'Try searching with another name or class.'
                : 'Students will appear here.',

            textAlign: TextAlign.center,

            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
