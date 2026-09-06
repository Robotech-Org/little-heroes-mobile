

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';

import 'change_password_dialog.dart';
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

          // Change Password - Moved here under Security
          SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            showDivider: false,
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD DIALOG
  // ============================================================

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const ChangePasswordDialog();
      },
    );
  }
}
