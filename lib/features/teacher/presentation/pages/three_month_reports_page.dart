import 'package:flutter/material.dart';

import 'student_three_month_report_page.dart';

// ============================================================================
// STUDENT MODEL
// ============================================================================

class Student {
  final String id;
  final String name;
  final int age;
  final String classroom;
  final ReportStatus status;

  const Student({
    required this.id,
    required this.name,
    required this.age,
    required this.classroom,
    required this.status,
  });
}

enum ReportStatus { pending, inProgress, completed }

// ============================================================================
// STUDENT DATA
// ============================================================================

const List<Student> kStudents = [
  Student(
    id: '1',
    name: 'Abebe Bekele',
    age: 5,
    classroom: 'Class 4A',
    status: ReportStatus.pending,
  ),
  Student(
    id: '2',
    name: 'Sara Ahmed',
    age: 6,
    classroom: 'Class 4A',
    status: ReportStatus.inProgress,
  ),
  Student(
    id: '3',
    name: 'Daniel Thomas',
    age: 5,
    classroom: 'Class 4A',
    status: ReportStatus.completed,
  ),
  Student(
    id: '4',
    name: 'Hana Samuel',
    age: 6,
    classroom: 'Class 4A',
    status: ReportStatus.pending,
  ),
  Student(
    id: '5',
    name: 'Michael John',
    age: 5,
    classroom: 'Class 4A',
    status: ReportStatus.inProgress,
  ),
  Student(
    id: '6',
    name: 'Liya Tesfaye',
    age: 6,
    classroom: 'Class 4A',
    status: ReportStatus.completed,
  ),
  Student(
    id: '7',
    name: 'Samuel Girma',
    age: 5,
    classroom: 'Class 4B',
    status: ReportStatus.pending,
  ),
  Student(
    id: '8',
    name: 'Mimi Yohannes',
    age: 6,
    classroom: 'Class 4B',
    status: ReportStatus.inProgress,
  ),
];

// ============================================================================
// PAGE 1
// STUDENT LIST
// ============================================================================

class ThreeMonthReportsPage extends StatefulWidget {
  const ThreeMonthReportsPage({super.key});

  @override
  State<ThreeMonthReportsPage> createState() => _ThreeMonthReportsPageState();
}

class _ThreeMonthReportsPageState extends State<ThreeMonthReportsPage> {
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  List<Student> _filterStudents(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return kStudents;
    }

    return kStudents
        .where(
          (student) =>
              student.name.toLowerCase().contains(search) ||
              student.classroom.toLowerCase().contains(search),
        )
        .toList(growable: false);
  }

  // ========================================================================
  // OPEN STUDENT REPORT
  // ========================================================================

  void _openStudent(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentThreeMonthReportPage(student: student),
      ),
    );
  }

  // ========================================================================
  // CLEAR SEARCH
  // ========================================================================

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ====================================================================
      // APP BAR
      // ====================================================================
      appBar: AppBar(
        title: const Text(
          '3 Month Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // ====================================================================
      // BODY
      // ====================================================================
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            final students = _filterStudents(value.text);

            return CustomScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              slivers: [
                // ==========================================================
                // COLLAPSING HEADER
                // ==========================================================

                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: colors.surface,
                  surfaceTintColor: colors.surface,
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  snap: true,

                  expandedHeight: 205,

                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE
                          Text(
                            'Student Reports',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // DESCRIPTION
                          Text(
                            'Select a student to review their 3 month '
                            'development report.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // SEARCH
                          _SearchField(
                            controller: _searchController,
                            onClear: _clearSearch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==========================================================
                // STUDENT COUNT
                // ==========================================================

                // ==========================================================
                // EMPTY STATE
                // ==========================================================
                if (students.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyStudents(),
                  ),

                // ==========================================================
                // STUDENT LIST
                // ==========================================================
                if (students.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final student = students[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: StudentReportCard(
                            key: ValueKey(student.id),
                            student: student,
                            onTap: () => _openStudent(student),
                          ),
                        );
                      }, childCount: students.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH FIELD
// ============================================================================

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchField({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,

      decoration: InputDecoration(
        hintText: 'Search students...',
        prefixIcon: const Icon(Icons.search_rounded),

        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Clear search',
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded),
            );
          },
        ),

        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.55),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================================
// STUDENT CARD
// ============================================================================

class StudentReportCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentReportCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  String get _initial {
    final name = student.name.trim();

    if (name.isEmpty) {
      return '?';
    }

    return name.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),

          child: Row(
            children: [
              // ============================================================
              // AVATAR
              // ============================================================

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),

                alignment: Alignment.center,

                child: Text(
                  _initial,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ============================================================
              // STUDENT INFORMATION
              // ============================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          '${student.age} years',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Icon(
                          Icons.class_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),

                        const SizedBox(width: 4),

                        Flexible(
                          child: Text(
                            student.classroom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    ReportStatusBadge(status: student.status),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ============================================================
              // ARROW
              // ============================================================
              Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class ReportStatusBadge extends StatelessWidget {
  final ReportStatus status;

  const ReportStatusBadge({super.key, required this.status});

  String get label {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';

      case ReportStatus.inProgress:
        return 'In Progress';

      case ReportStatus.completed:
        return 'Completed';
    }
  }

  IconData get icon {
    switch (status) {
      case ReportStatus.pending:
        return Icons.schedule_rounded;

      case ReportStatus.inProgress:
        return Icons.edit_rounded;

      case ReportStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    late final Color background;
    late final Color foreground;

    switch (status) {
      case ReportStatus.pending:
        background = colors.tertiaryContainer;
        foreground = colors.onTertiaryContainer;
        break;

      case ReportStatus.inProgress:
        background = colors.secondaryContainer;
        foreground = colors.onSecondaryContainer;
        break;

      case ReportStatus.completed:
        background = colors.primaryContainer;
        foreground = colors.onPrimaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),

          const SizedBox(width: 5),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyStudents extends StatelessWidget {
  const _EmptyStudents();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,

              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.person_search_rounded,
                size: 34,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'No students found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Try searching with a different name or classroom.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
