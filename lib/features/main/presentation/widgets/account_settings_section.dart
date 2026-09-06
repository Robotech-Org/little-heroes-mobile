import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/features/main/presentation/widgets/change_password_dialog.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/router/app_routes.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class AccountSettingsSection extends StatelessWidget {
  final UserRole? role;
  final String? phoneNumber;

  final VoidCallback? onProfileTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onLinkedChildrenTap;
  final VoidCallback? onSecurityTap;

  const AccountSettingsSection({
    super.key,
    required this.role,
    required this.phoneNumber,
    this.onProfileTap,
    this.onContactTap,
    this.onLinkedChildrenTap,
    this.onSecurityTap,
  });

  @override
  Widget build(BuildContext context) {
    final isParent = role == UserRole.parent;

    return SettingsSection(
      title: 'Account',
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            subtitle: 'Manage your profile',
            onTap: onProfileTap ?? () {},
          ),

          SettingsTile(
            icon: Icons.phone_outlined,
            title: 'Contact Details',
            subtitle: phoneNumber ?? 'Not available',
            onTap: onContactTap ?? () {},
          ),

          if (isParent)
            SettingsTile(
              icon: Icons.child_care_outlined,
              title: 'Linked Children',
              subtitle: '2 children',
              onTap: onLinkedChildrenTap ?? () {},
            ),

          // Change Password - Navigate to full page
          SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            showDivider: false,
            onTap: () {
              // Navigate to Change Password Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
