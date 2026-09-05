import 'package:flutter/material.dart';

import 'three_month_reports_page.dart';

// ============================================================================
// DEVELOPMENT FRAMEWORK
// ============================================================================

class DevelopmentFramework {
  final String title;
  final String description;
  final IconData icon;

  const DevelopmentFramework({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// ============================================================================
// FRAMEWORK DATA
// ============================================================================

const List<DevelopmentFramework> kDevelopmentFrameworks = [
  DevelopmentFramework(
    title: 'Initiative & Planning',
    description: 'Shows initiative, planning skills, independence, and ability to organize activities.',
    icon: Icons.lightbulb_outline_rounded,
  ),
  DevelopmentFramework(
    title: 'Problem Solving & Mathematics',
    description:
        'Uses reasoning, mathematics, logic, and problem-solving strategies.',
    icon: Icons.calculate_outlined,
  ),
  DevelopmentFramework(
    title: 'Reflection',
    description: 'Reflects on experiences, actions, learning, and progress.',
    icon: Icons.psychology_outlined,
  ),
  DevelopmentFramework(
    title: 'Emotional Development',
    description: 'Recognizes, expresses, and manages emotions appropriately.',
    icon: Icons.favorite_outline_rounded,
  ),
  DevelopmentFramework(
    title: 'Communication',
    description: 'Communicates ideas, needs, thoughts, and experiences.',
    icon: Icons.chat_bubble_outline_rounded,
  ),
  DevelopmentFramework(
    title: 'Social Development',
    description: 'Builds relationships, cooperates, shares, and participates with others.',
    icon: Icons.groups_outlined,
  ),
  DevelopmentFramework(
    title: 'Health & Wellbeing',
    description:
        'Demonstrates healthy habits, hygiene, safety, and personal wellbeing.',
    icon: Icons.health_and_safety_outlined,
  ),
  DevelopmentFramework(
    title: 'Creativity & Expression',
    description: 'Uses creativity and different forms of expression to communicate ideas.',
    icon: Icons.palette_outlined,
  ),
];

// ============================================================================
// PAGE 2
// STUDENT 3 MONTH REPORT
// ============================================================================

class StudentThreeMonthReportPage extends StatefulWidget {
  final Student student;

  const StudentThreeMonthReportPage({super.key, required this.student});

  @override
  State<StudentThreeMonthReportPage> createState() =>
      _StudentThreeMonthReportPageState();
}

class _StudentThreeMonthReportPageState
    extends State<StudentThreeMonthReportPage> {
  late final List<int?> _levels;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _levels = List<int?>.filled(kDevelopmentFrameworks.length, null);
  }

  // ========================================================================
  // PROGRESS
  // ========================================================================

  int get _completed => _levels.whereType<int>().length;

  double get _progress {
    if (kDevelopmentFrameworks.isEmpty) {
      return 0;
    }

    return _completed / kDevelopmentFrameworks.length;
  }

  // ========================================================================
  // INITIAL
  // ========================================================================

  String get _studentInitial {
    final name = widget.student.name.trim();

    if (name.isEmpty) {
      return '?';
    }

    return name.characters.first.toUpperCase();
  }

  // ========================================================================
  // SELECT LEVEL
  // ========================================================================

  void _selectLevel(int index, int level) {
    if (_levels[index] == level) {
      return;
    }

    setState(() {
      _levels[index] = level;
    });
  }

  // ========================================================================
  // SAVE
  // ========================================================================

  Future<void> _saveReport() async {
    if (_isSaving) {
      return;
    }

    if (_completed < kDevelopmentFrameworks.length) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Please complete all frameworks '
              '($_completed/${kDevelopmentFrameworks.length}).',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    // TODO:
    // Replace with your repository/API call.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('3 Month Report updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ====================================================================
      // PAGE 2 APP BAR
      // ====================================================================
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,

        title: Text(
          '${widget.student.name}  Report',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // ====================================================================
      // PAGE 2 BODY
      // ====================================================================
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            // ================================================================
            // STUDENT INFORMATION
            // ================================================================

            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      color: colors.shadow.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // AVATAR
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _studentInitial,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // STUDENT DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '${widget.student.age} years • '
                            '${widget.student.classroom}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 8),

                          ReportStatusBadge(status: widget.student.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================================================================
            // PROGRESS
            // ================================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Development Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '$_completed/'
                            '${kDevelopmentFrameworks.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: colors.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================================================================
            // FRAMEWORK TITLE
            // ================================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Development Frameworks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // ================================================================
            // FRAMEWORKS
            // ================================================================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: kDevelopmentFrameworks.length,
                itemBuilder: (context, index) {
                  final framework = kDevelopmentFrameworks[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FrameworkCard(
                      key: ValueKey(framework.title),
                      framework: framework,
                      selectedLevel: _levels[index],
                      onLevelSelected: (level) {
                        _selectLevel(index, level);
                      },
                    ),
                  );
                },
              ),
            ),

            // ================================================================
            // SAVE
            // ================================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
              sliver: SliverToBoxAdapter(
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveReport,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save / Update Report',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FRAMEWORK CARD
// ============================================================================

class FrameworkCard extends StatelessWidget {
  final DevelopmentFramework framework;

  final int? selectedLevel;

  final ValueChanged<int> onLevelSelected;

  const FrameworkCard({
    super.key,
    required this.framework,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  String _levelDescription(int level) {
    switch (level) {
      case 1:
        return 'Beginning • Needs significant support';

      case 2:
        return 'Emerging • Developing with support';

      case 3:
        return 'Developing • Demonstrates the skill sometimes';

      case 4:
        return 'Proficient • Demonstrates the skill consistently';

      case 5:
        return 'Advanced • Demonstrates strong independence';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    final isSelected = selectedLevel != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.45)
              : colors.outlineVariant.withValues(alpha: 0.4),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: colors.shadow.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(framework.icon, color: colors.onPrimaryContainer),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      framework.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      framework.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Development Level',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selectedLevel != null)
                Text(
                  'Level $selectedLevel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: List.generate(5, (index) {
              final level = index + 1;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: level == 5 ? 0 : 8),
                  child: _LevelButton(
                    level: level,
                    selected: selectedLevel == level,
                    onTap: () => onLevelSelected(level),
                  ),
                ),
              );
            }),
          ),

          if (selectedLevel != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _levelDescription(selectedLevel!),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// LEVEL BUTTON
// ============================================================================

class _LevelButton extends StatelessWidget {
  final int level;
  final bool selected;
  final VoidCallback onTap;

  const _LevelButton({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Development level $level',
      child: Material(
        color: selected ? colors.primary : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
              ),
            ),
            child: Text(
              '$level',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: selected ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
