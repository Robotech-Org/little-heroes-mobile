import 'package:flutter/material.dart';

// ============================================================================
// WEEKLY PLAN MODEL
// ============================================================================

class WeeklyPlan {
  final String id;
  final DateTime date;
  final String title;
  // final String domain;
  final String subDomain;
  final String target;
  final String objective;
  final String materials;
  final String status;

  const WeeklyPlan({
    required this.id,
    required this.date,
    required this.title,
    // required this.domain,
    required this.subDomain,
    required this.target,
    required this.objective,
    required this.materials,
    required this.status,
  });
}

// ============================================================================
// WEEKLY PLANS PAGE
// ============================================================================

class WeeklyPlansPage extends StatefulWidget {
  const WeeklyPlansPage({super.key});

  @override
  State<WeeklyPlansPage> createState() => _WeeklyPlansPageState();
}

class _WeeklyPlansPageState extends State<WeeklyPlansPage> {
  final List<WeeklyPlan> _plans = [
    WeeklyPlan(
      id: '1',
      date: DateTime(2026, 9, 6),
      title: 'Getting to Know Myself',
      // domain: 'All About Me / My World',
      subDomain: 'Self Identity',
      target: 'Recognize personal information',
      objective: 'Children will talk about themselves and identify their name.',
      materials: 'Pictures, name cards, mirror',
      status: 'Approved',
    ),
    WeeklyPlan(
      id: '2',
      date: DateTime(2026, 9, 7),
      title: 'My Family',
      // domain: 'All About Me / My World',
      subDomain: 'Family and Relationships',
      target: 'Identify family members',
      objective:
          'Children will identify and talk about members of their family.',
      materials: 'Family pictures, drawing paper',
      status: 'Pending Approval',
    ),
    WeeklyPlan(
      id: '3',
      date: DateTime(2026, 9, 8),
      title: 'My Favorite Things',
      // domain: 'All About Me / My World',
      subDomain: 'Personal Preferences',
      target: 'Express preferences',
      objective: 'Children will express their likes and dislikes.',
      materials: 'Picture cards, crayons',
      status: 'Draft',
    ),
  ];

  // ==========================================================================
  // ADD PLAN
  // ==========================================================================

  void _addPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddWeeklyPlanPage(
          onSave: (plan) {
            setState(() {
              _plans.insert(0, plan);
            });
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // DATE
  // ==========================================================================

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Plans',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          Text(
            'Weekly Lesson Planner',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Plan lessons and submit them to the admin for approval.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 22),

          ..._plans.map(
            (plan) => _WeeklyPlanCard(plan: plan, dayName: _dayName(plan.date)),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPlan,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Weekly Plan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ============================================================================
// WEEKLY PLAN CARD
// ============================================================================

class _WeeklyPlanCard extends StatelessWidget {
  final WeeklyPlan plan;
  final String dayName;

  const _WeeklyPlanCard({required this.plan, required this.dayName});

  Color _statusColor(ColorScheme colors) {
    switch (plan.status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending Approval':
        return Colors.orange;
      default:
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(colors);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================================================================
          // DAY / DATE
          // ================================================================

          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${plan.date.day}',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ================================================================
          // PLAN INFORMATION
          // ================================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        plan.status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                const SizedBox(height: 3),

                Text(
                  plan.subDomain,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  plan.objective,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ADD WEEKLY PLAN PAGE
// ============================================================================

class AddWeeklyPlanPage extends StatefulWidget {
  final ValueChanged<WeeklyPlan> onSave;

  const AddWeeklyPlanPage({super.key, required this.onSave});

  @override
  State<AddWeeklyPlanPage> createState() => _AddWeeklyPlanPageState();
}

class _AddWeeklyPlanPageState extends State<AddWeeklyPlanPage> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _materialsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String _domain = 'All About Me / My World';
  String _subDomain = 'Self Identity';

  final List<String> _domains = [
    'All About Me / My World',
    'Communication & Language',
    'Physical Development',
    'Social & Emotional Development',
    'Cognitive Development',
    'Creative Development',
    'Early Mathematics',
    'Understanding the World',
  ];

  final Map<String, List<String>> _subDomains = {
    'All About Me / My World': [
      'Self Identity',
      'Family and Relationships',
      'Personal Preferences',
      'My Body',
    ],
    'Communication & Language': [
      'Listening',
      'Speaking',
      'Story Telling',
      'Early Literacy',
    ],
    'Physical Development': [
      'Gross Motor',
      'Fine Motor',
      'Health and Movement',
    ],
    'Social & Emotional Development': [
      'Self Awareness',
      'Relationships',
      'Emotional Regulation',
    ],
    'Cognitive Development': ['Problem Solving', 'Memory', 'Exploration'],
    'Creative Development': ['Art', 'Music', 'Drama'],
    'Early Mathematics': ['Numbers', 'Shapes', 'Measurement'],
    'Understanding the World': ['Nature', 'Community', 'Environment'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _objectiveController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // SAVE
  // ==========================================================================

  void _save(String status) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the lesson title.')),
      );
      return;
    }

    final plan = WeeklyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      title: _titleController.text.trim(),
      // domain: _domain,
      subDomain: _subDomain,
      target: _targetController.text.trim(),
      objective: _objectiveController.text.trim(),
      materials: _materialsController.text.trim(),
      status: status,
    );

    widget.onSave(plan);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'Draft'
              ? 'Weekly plan saved as draft.'
              : 'Weekly plan submitted to admin.',
        ),
      ),
    );
  }

  // ==========================================================================
  // DATE
  // ==========================================================================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final subDomains = _subDomains[_domain] ?? [];

    if (!subDomains.contains(_subDomain) && subDomains.isNotEmpty) {
      _subDomain = subDomains.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Weekly Plan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          // ================================================================
          // DATE
          // ================================================================

          _SectionTitle(
            title: 'Lesson Day',
            subtitle: 'Select the day for this lesson.',
          ),

          const SizedBox(height: 10),

          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ================================================================
          // FRAMEWORK DOMAIN
          // ================================================================
          _SectionTitle(
            title: 'Framework Domain',
            subtitle: 'Select the learning framework domain.',
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: _domain,
            isExpanded: true,
            decoration: _inputDecoration(context, Icons.category_outlined),
            items: _domains.map((domain) {
              return DropdownMenuItem(
                value: domain,
                child: Text(domain, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _domain = value;
                _subDomain = _subDomains[value]!.first;
              });
            },
          ),

          const SizedBox(height: 18),

          // ================================================================
          // SUB DOMAIN
          // ================================================================
          _SectionTitle(
            title: 'Framework Sub-domain',
            subtitle: 'Select the specific learning area.',
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: subDomains.isEmpty ? null : _subDomain,
            isExpanded: true,
            decoration: _inputDecoration(context, Icons.account_tree_outlined),
            items: subDomains.map((subDomain) {
              return DropdownMenuItem(
                value: subDomain,
                child: Text(subDomain, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _subDomain = value;
                });
              }
            },
          ),

          const SizedBox(height: 18),

          // ================================================================
          // TARGET
          // ================================================================
          _SectionTitle(
            title: 'Framework Target',
            subtitle: 'What should the child work toward?',
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _targetController,
            decoration: _inputDecoration(
              context,
              Icons.flag_outlined,
              hint: 'Example: Recognize personal information',
            ),
          ),

          const SizedBox(height: 22),

          // ================================================================
          // LESSON TITLE
          // ================================================================
          _SectionTitle(
            title: 'Lesson Title',
            subtitle: 'Give the lesson a clear title.',
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _titleController,
            decoration: _inputDecoration(
              context,
              Icons.menu_book_outlined,
              hint: 'Example: Getting to Know Myself',
            ),
          ),

          const SizedBox(height: 22),

          // ================================================================
          // OBJECTIVE
          // ================================================================
          _SectionTitle(
            title: 'Objective of the Lesson',
            subtitle: 'What should children learn or achieve?',
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _objectiveController,
            minLines: 4,
            maxLines: 6,
            decoration: _inputDecoration(
              context,
              Icons.lightbulb_outline_rounded,
              hint: 'Write the lesson objective...',
            ),
          ),

          const SizedBox(height: 22),

          // ================================================================
          // MATERIALS
          // ================================================================
          _SectionTitle(
            title: 'Materials Needed',
            subtitle: 'List the materials required for the lesson.',
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _materialsController,
            minLines: 3,
            maxLines: 5,
            decoration: _inputDecoration(
              context,
              Icons.inventory_2_outlined,
              hint: 'Example: Pictures, crayons, books...',
            ),
          ),

          const SizedBox(height: 28),

          // ================================================================
          // ACTION BUTTONS
          // ================================================================
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _save('Draft'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save Draft',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton(
                  onPressed: () => _save('Pending Approval'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Submit to Admin',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT DECORATION
  // ==========================================================================

  InputDecoration _inputDecoration(
    BuildContext context,
    IconData icon, {
    String? hint,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: .5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
