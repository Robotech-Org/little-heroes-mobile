import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';

import 'attendance_action_bar.dart';
import 'attendance_action_grid_card.dart';

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ══════════════════════════════════════════════
        // Row 1: two grid cards
        // ══════════════════════════════════════════════
        Row(
          children: [
            Expanded(
              child: AttendanceActionGridCard(
                title: 'Gate Scanner',
                description: 'Scan QR cards',
                icon: Icons.qr_code_scanner_rounded,
                onTap: () => context.push(AppRoutes.gateAttendance),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AttendanceActionGridCard(
                title: 'Attendance List',
                description: 'Scanned today',
                icon: Icons.list_alt_rounded,
                onTap: () => context.push(AppRoutes.attendanceList),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ══════════════════════════════════════════════
        // Row 2: full-width Punch In
        // ══════════════════════════════════════════════
        AttendanceActionBar(
          label: 'Punch In',
          subtitle: 'Mark arrived students as in class',
          icon: Icons.login_rounded,
          background: colors.primary,
          foreground: colors.onPrimary,
          onTap: () => context.push(AppRoutes.classroomPunchIn),
        ),

        const SizedBox(height: 10),

        // ══════════════════════════════════════════════
        // Row 3: full-width Punch Out
        // ══════════════════════════════════════════════
        AttendanceActionBar(
          label: 'Punch Out',
          subtitle: 'Mark in-class students as left',
          icon: Icons.logout_rounded,
          background: colors.secondary,
          foreground: colors.onSecondary,
          onTap: () => context.push(AppRoutes.classroomPunchOut),
        ),
      ],
    );
  }
}
