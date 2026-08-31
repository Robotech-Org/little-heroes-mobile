import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/main/presentation/pages/main_page.dart';

import '../../domain/entities/user_role.dart';

class StudentsPage extends StatelessWidget {
  final UserRole role;

  const StudentsPage({super.key, required this.role});

  bool get isParent {
    return role == UserRole.parent;
  }

  String get pageTitle {
    return isParent ? 'My Children' : 'Students';
  }

  String get description {
    switch (role) {
      case UserRole.teacher:
        return 'Manage and follow your students.';

      case UserRole.parent:
        return 'Monitor your children and their progress.';

      case UserRole.advisor:
        return 'Support and follow your students.';
    }
  }

  IconData get pageIcon {
    return isParent ? Icons.child_care_rounded : Icons.people_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),

        backgroundColor: colorScheme.surface,

        foregroundColor: colorScheme.onSurface,

        elevation: 0,

        surfaceTintColor: Colors.transparent,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  pageIcon,
                  size: 45,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                pageTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
