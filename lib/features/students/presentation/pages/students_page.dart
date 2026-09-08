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
  bool _isRefreshing = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalStudents = 0;
  final int _pageSize = 20;

  // Cache
  List<Student>? _cachedStudents;
  DateTime? _lastCacheTime;
  String? _cachedSearchQuery;
  static const Duration _cacheDuration = Duration(minutes: 5);

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

  Future<void> _loadStudents({int page = 1, bool useCache = true}) async {
    final searchQuery = _searchController.text.trim();

    // Check cache for the same search query
    if (useCache &&
        _cachedStudents != null &&
        _lastCacheTime != null &&
        _cachedSearchQuery == searchQuery) {
      final cacheAge = DateTime.now().difference(_lastCacheTime!);
      if (cacheAge < _cacheDuration) {
        setState(() {
          _allStudents = _cachedStudents!;
          _filteredStudents = _cachedStudents!;
          _isLoading = false;
          _isError = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = _cachedStudents == null;
      _isRefreshing = _cachedStudents != null;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Please login to view students';
        });
        return;
      }

      final role = authState.user.role;
      if (role != UserRole.teacher && role != UserRole.adviser) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'You do not have permission to view students';
        });
        return;
      }

      final repository = di.sl<StudentRepository>();
      final response = await repository.getStudents(
        page: page,
        pageSize: _pageSize,
        search: searchQuery.isEmpty ? null : searchQuery,
      );

      setState(() {
        _allStudents = response.items;
        _filteredStudents = response.items;
        _cachedStudents = response.items;
        _cachedSearchQuery = searchQuery;
        _lastCacheTime = DateTime.now();
        _totalStudents = response.total;
        _totalPages = (response.total / response.pageSize).ceil();
        _currentPage = response.page;
        _isLoading = false;
        _isRefreshing = false;
        _isError = false;
      });
    } catch (e) {
      // Use cached data if available
      if (_cachedStudents != null && _cachedSearchQuery == searchQuery) {
        setState(() {
          _allStudents = _cachedStudents!;
          _filteredStudents = _cachedStudents!;
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
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
            onPressed: () => _loadStudents(useCache: false),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadStudents(useCache: false),
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

    return ListView(
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

        // Stats + Last Updated
        // _buildStats(theme, colorScheme),

        // Empty State
        if (_filteredStudents.isEmpty)
          _EmptyStudents(searchQuery: _searchController.text)
        else
          // Student List
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
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredStudents.length} students',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_lastCacheTime != null)
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_formatTime(_lastCacheTime!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  // ============================================================
  // SKELETON LOADING
  // ============================================================

  Widget _buildSkeletonLoading(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        // Search bar skeleton
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        // Stats skeleton
        _buildSkeletonLine(width: 120, height: 14),
        const SizedBox(height: 12),
        // Student cards skeletons
        ...List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: 140, height: 18),
                      const SizedBox(height: 4),
                      _buildSkeletonLine(width: 100, height: 14),
                      const SizedBox(height: 6),
                      _buildSkeletonLine(width: 80, height: 16),
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
              size: 50,
              color: colorScheme.error,
            ),
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
              onPressed: () => _loadStudents(useCache: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STUDENTS
// ============================================================

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
