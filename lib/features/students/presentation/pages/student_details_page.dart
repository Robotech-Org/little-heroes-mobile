import 'package:flutter/material.dart';

import '../../domain/entities/student.dart';

class StudentDetailsPage extends StatelessWidget {
  final Student student;

  const StudentDetailsPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),

        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,

        elevation: 0,

        surfaceTintColor: Colors.transparent,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        children: [
          // PROFILE HEADER

          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),

              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),

            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,

                      backgroundColor: colorScheme.primaryContainer,

                      child: Text(
                        student.initials,

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                    if (student.isActive)
                      Positioned(
                        right: 2,
                        bottom: 3,

                        child: Container(
                          width: 16,
                          height: 16,

                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  student.name,

                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${student.grade} • ${student.className}',

                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: student.isActive
                        ? Colors.green.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    student.isActive ? 'Active' : 'Offline',

                    style: TextStyle(
                      color: student.isActive
                          ? Colors.green
                          : colorScheme.onSurfaceVariant,

                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QUICK STATS
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Attendance',
                  value: student.attendance,
                  icon: Icons.calendar_month_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _StatCard(
                  title: 'Progress',
                  value: student.academicProgress,
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // PERSONAL INFORMATION
          _SectionTitle(title: 'Personal Information'),

          const SizedBox(height: 10),

          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'Date of birth',
                value: student.dateOfBirth,
              ),

              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Age',
                value: student.age,
              ),

              _InfoRow(
                icon: Icons.wc_outlined,
                label: 'Gender',
                value: student.gender,
              ),

              _InfoRow(
                icon: Icons.favorite_outline_rounded,
                label: 'Favorite subject',
                value: student.favoriteSubject,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // PARENT INFORMATION
          _SectionTitle(title: 'Parent / Guardian'),

          const SizedBox(height: 10),

          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Name',
                value: student.parentName,
              ),

              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: student.parentPhone,
              ),

              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: student.email,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // RECENT ACTIVITY
          _SectionTitle(title: 'Recent Activity'),

          const SizedBox(height: 10),

          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.history_rounded,
                label: 'Last activity',
                value: student.lastActivity,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// STAT CARD

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),

          const SizedBox(height: 10),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,

            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// SECTION TITLE

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,

      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

// INFO CARD

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Column(children: children),
    );
  }
}

// INFO ROW

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, size: 19, color: colorScheme.onPrimaryContainer),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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
