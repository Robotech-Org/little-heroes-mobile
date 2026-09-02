import 'package:flutter/material.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<_Student> _students = [
    _Student(
      id: '1',
      name: 'Abel Tesfaye',
      className: 'Grade 4A',
      avatar: 'AT',
    ),
    _Student(
      id: '2',
      name: 'Sara Mohammed',
      className: 'Grade 4A',
      avatar: 'SM',
    ),
    _Student(
      id: '3',
      name: 'Daniel Bekele',
      className: 'Grade 4A',
      avatar: 'DB',
    ),
    _Student(id: '4', name: 'Hana Alemu', className: 'Grade 4A', avatar: 'HA'),
    _Student(
      id: '5',
      name: 'Samuel Girma',
      className: 'Grade 4B',
      avatar: 'SG',
    ),
    _Student(
      id: '6',
      name: 'Marta Kebede',
      className: 'Grade 4B',
      avatar: 'MK',
    ),
    _Student(
      id: '7',
      name: 'Noah Yohannes',
      className: 'Grade 4B',
      avatar: 'NY',
    ),
    _Student(
      id: '8',
      name: 'Liya Tadesse',
      className: 'Grade 4B',
      avatar: 'LT',
    ),
  ];

  String _searchQuery = '';

  List<_Student> get _filteredStudents {
    if (_searchQuery.trim().isEmpty) {
      return _students;
    }

    final query = _searchQuery.toLowerCase();

    return _students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.className.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStudentReport(_Student student) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _StudentDailyReportSheet(
          student: student,
          onSaved: () {
            setState(() {
              student.hasReport = true;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daily Report',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ============================================================
          // HEADER
          // ============================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Students',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                // ======================================================
                // SEARCH
                // ======================================================
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: .4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: .4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ============================================================
          // STUDENT LIST
          // ============================================================
          Expanded(
            child: _filteredStudents.isEmpty
                ? _EmptyStudents()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                    itemCount: _filteredStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];

                      return _StudentCard(
                        student: student,
                        onTap: () => _openStudentReport(student),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STUDENT
// ============================================================================

class _Student {
  final String id;
  final String name;
  final String className;
  final String avatar;

  bool hasReport;

  _Student({
    required this.id,
    required this.name,
    required this.className,
    required this.avatar,
    this.hasReport = false,
  });
}

// ============================================================================
// STUDENT CARD
// ============================================================================

class _StudentCard extends StatelessWidget {
  final _Student student;
  final VoidCallback onTap;

  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .35),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  student.avatar,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              // Student information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.className,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick status
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _MiniStatus(
                            icon: Icons.restaurant_outlined,
                            label: 'Meals',
                          ),
                          const SizedBox(width: 5),
                          _MiniStatus(
                            icon: Icons.bedtime_outlined,
                            label: 'Nap',
                          ),
                          const SizedBox(width: 5),
                          _MiniStatus(icon: Icons.mood_outlined, label: 'Mood'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                children: [
                  if (student.hasReport)
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.primary,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: colors.outline,
                      size: 20,
                    ),
                  const SizedBox(height: 5),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MINI STATUS
// ============================================================================

class _MiniStatus extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniStatus({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STUDENTS
// ============================================================================

class _EmptyStudents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 50,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'No students found',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another student name',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STUDENT DAILY REPORT SHEET
// ============================================================================

class _StudentDailyReportSheet extends StatefulWidget {
  final _Student student;
  final VoidCallback onSaved;

  const _StudentDailyReportSheet({
    required this.student,
    required this.onSaved,
  });

  @override
  State<_StudentDailyReportSheet> createState() =>
      _StudentDailyReportSheetState();
}

class _StudentDailyReportSheetState extends State<_StudentDailyReportSheet> {
  final Map<String, Set<String>> _selected = {};

  final Map<String, List<String>> _options = {
    'Meals': [
      'Breakfast',
      'Lunch',
      'Snack',
      'Ate well',
      'Ate partially',
      'Did not eat',
    ],
    'Nap': ['Slept well', 'Short nap', 'Did not sleep', 'Restless'],
    'Mood': ['Happy', 'Calm', 'Excited', 'Sad', 'Tired', 'Anxious'],
    'Behaviour': [
      'Friendly',
      'Cooperative',
      'Active',
      'Quiet',
      'Distracted',
      'Needs support',
    ],
    'Health': ['Healthy', 'Feeling unwell', 'Fever', 'Cough', 'Medication'],
    'Hygiene': ['Clean', 'Hand washing', 'Toilet routine', 'Needs assistance'],
    'Other': [
      'Participated well',
      'Outdoor activity',
      'Creative activity',
      'Parent follow-up',
    ],
  };

  @override
  void initState() {
    super.initState();

    for (final category in _options.keys) {
      _selected[category] = {};
    }
  }

  void _toggle(String category, String value) {
    setState(() {
      final values = _selected[category]!;

      if (values.contains(value)) {
        values.remove(value);
      } else {
        values.add(value);
      }
    });
  }

  void _save() {
    widget.onSaved();

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daily report saved for ${widget.student.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: .92,
      minChildSize: .65,
      maxChildSize: .96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ============================================================
              // HANDLE
              // ============================================================

              const SizedBox(height: 10),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // ============================================================
              // HEADER
              // ============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.student.avatar,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.student.className} • Today',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              Divider(color: colors.outlineVariant.withValues(alpha: .4)),

              // ============================================================
              // REPORT OPTIONS
              // ============================================================
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  children: [
                    Text(
                      'Daily wellbeing',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select all that apply to this student.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),

                    ..._options.entries.map(
                      (entry) => _ReportCategory(
                        title: entry.key,
                        options: entry.value,
                        selected: _selected[entry.key]!,
                        onToggle: (value) {
                          _toggle(entry.key, value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // SAVE BUTTON
              // ============================================================
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: .08),
                      blurRadius: 15,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Save Daily Report',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// REPORT CATEGORY
// ============================================================================

class _ReportCategory extends StatelessWidget {
  final String title;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ReportCategory({
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  IconData get icon {
    switch (title) {
      case 'Meals':
        return Icons.restaurant_rounded;
      case 'Nap':
        return Icons.bedtime_rounded;
      case 'Mood':
        return Icons.mood_rounded;
      case 'Behaviour':
        return Icons.psychology_alt_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Hygiene':
        return Icons.clean_hands_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: colors.primary),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              if (selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${selected.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 9),

          // Horizontal scrolling options
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selected.contains(option);

                return FilterChip(
                  selected: isSelected,
                  label: Text(option),
                  avatar: isSelected
                      ? const Icon(Icons.check_rounded, size: 16)
                      : null,
                  onSelected: (_) {
                    onToggle(option);
                  },
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
