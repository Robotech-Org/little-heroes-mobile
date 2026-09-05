import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';

class RoleDashboard extends StatelessWidget {
  final UserRole role;

  const RoleDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.teacher:
        return const _TeacherDashboard();

      case UserRole.parent:
        return const _ParentDashboard();

      case UserRole.adviser:
        return const _adviserDashboard();
    }
  }
}



class _TeacherDashboard extends StatelessWidget {
  const _TeacherDashboard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardBanner(
      title: 'Your Classroom',
      description: 'Manage your students, classes, assignments and attendance.',
      icon: Icons.school_rounded,
    );
  }
}



class _ParentDashboard extends StatelessWidget {
  const _ParentDashboard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardBanner(
      title: 'Your Child',
      description:
          'Stay connected with your child\'s learning and school activities.',
      icon: Icons.family_restroom_rounded,
    );
  }
}



class _adviserDashboard extends StatelessWidget {
  const _adviserDashboard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardBanner(
      title: 'Your Dashboard',
      description: 'Support students, teachers and families from one place.',
      icon: Icons.support_agent_rounded,
    );
  }
}



class _DashboardBanner extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _DashboardBanner({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          // 
          // TEXT
          // 

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // 
          // ICON
          // 
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}
