import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import 'student_details_page.dart';
import '../widgets/student_card.dart';
import '../widgets/student_search.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalStudents = 0;
  final int _pageSize = 20;

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

  Future<void> _loadStudents({int page = 1}) async {
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
          _errorMessage = 'Please login to view students';
        });
        return;
      }

      final role = authState.user.role;
      if (role != UserRole.teacher && role != UserRole.adviser) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'You do not have permission to view students';
        });
        return;
      }

      final repository = di.sl<StudentRepository>();
      final response = await repository.getStudents(
        page: page,
        pageSize: _pageSize,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      setState(() {
        _allStudents = response.items;
        _filteredStudents = response.items;
        _totalStudents = response.total;
        _totalPages = (response.total / response.pageSize).ceil();
        _currentPage = response.page;
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

  void _searchStudents(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      setState(() {
        _filteredStudents = _allStudents;
      });
      return;
    }

    final results = _allStudents.where((student) {
      return student.name.toLowerCase().contains(value);
    }).toList();

    setState(() {
      _filteredStudents = results;
    });
  }

  void _openStudent(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudentDetailsPage(student: student)),
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
          'Students',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadStudents(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadStudents(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            // Search
            StudentSearch(
              controller: _searchController,
              onChanged: _searchStudents,
              onClear: () {
                _searchController.clear();
                setState(() {
                  _filteredStudents = _allStudents;
                });
              },
            ),
            const SizedBox(height: 5),

            // Student Count

            // Loading
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Center(child: CircularProgressIndicator()),
              )
            // Error
            else if (_isError)
              _buildErrorWidget(theme, colorScheme)
            // Empty
            else if (_filteredStudents.isEmpty)
              _EmptyStudents(searchQuery: _searchController.text)
            // Student List
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

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 50, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load students',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _loadStudents(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch
                ? 'Try searching with another name.'
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
