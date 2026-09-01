import 'package:flutter/material.dart';

import '../../domain/entities/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;

  const StudentCard({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        child: Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),

          child: Row(
            children: [
              // ============================================================
              // AVATAR
              // ============================================================

              Stack(
                children: [
                  CircleAvatar(
                    radius: 27,

                    backgroundColor: colorScheme.primaryContainer,

                    child: Text(
                      student.initials,

                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  if (student.isActive)
                    Positioned(
                      right: 0,
                      bottom: 1,

                      child: Container(
                        width: 13,
                        height: 13,

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
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          student.grade,

                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),

                          child: Text(
                            '•',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            student.className,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      student.lastActivity,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ============================================================
              // ARROW
              // ============================================================
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
