import 'package:flutter/material.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/features/main/presentation/pages/information_page.dart';

class PrivacySection extends StatelessWidget {
  final bool isDark;

  const PrivacySection({super.key, required this.isDark});

  // ══════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InformationPage(
          title: 'Privacy Policy',
          subtitle:
              'Your school controls your information. The Little Heroes mobile app is a secure portal to access what your school has shared with you.',
          icon: Icons.privacy_tip_outlined,
          sections: [
            InformationSection(
              heading: 'Overview',
              content:
                  'Little Heroes is a school communication platform. The mobile application does '
                  'not independently collect, store, or sell personal information. All accounts, '
                  'student records, reports, and educational content are created and maintained '
                  'by your school\'s administration through the Little Heroes school system.',
            ),
            InformationSection(
              heading: 'Who Controls Your Information',
              content:
                  'Your school administration is the data controller. They are responsible for '
                  'creating user accounts, entering student information, and deciding what data is '
                  'shared through the platform. The mobile app only displays information that your '
                  'school has entered and authorised you to see.',
            ),
            InformationSection(
              heading: 'Account Creation & Access',
              content:
                  'Accounts for parents, teachers, and administrators are created by your school '
                  'administrator. You do not register yourself through the mobile app. Your login '
                  'credentials are provided to you by your school. If your account needs to be '
                  'created, modified, or deleted, please contact your school administrator.',
            ),
            InformationSection(
              heading: 'Information We Do Not Collect',
              content:
                  'The Little Heroes mobile app does not directly collect personal information '
                  'such as your name, address, phone number, or device identifiers for advertising '
                  'or marketing purposes. We do not track your activity across other apps or '
                  'websites. We do not sell or rent personal information to third parties.',
            ),
            InformationSection(
              heading: 'Information Displayed in the App',
              content:
                  'The app displays information that your school administrator has entered, '
                  'including student profiles, daily reports, attendance, messages, and progress '
                  'records. Access to this information is restricted based on the role assigned to '
                  'your account by your school.',
            ),
            InformationSection(
              heading: 'Payments',
              content:
                  'If your school enables in-app payment features, all payments processed through '
                  'the Little Heroes app are for school-related services, such as school fees, '
                  'activity charges, meals, or other educational services provided by your school. '
                  'These payments are for real-world services and are not for access to digital '
                  'content or app features. Payment information is processed securely by '
                  'school-approved payment providers. Little Heroes does not store your card '
                  'details. Payment records are managed by your school administrator.',
            ),
            InformationSection(
              heading: 'Data Protection',
              content:
                  'Little Heroes uses industry-standard security measures to protect the '
                  'information stored on its platform. Access to sensitive information is '
                  'restricted to authorised users and personnel. Your school administrator controls '
                  'which users can view which information.',
            ),
            InformationSection(
              heading: 'Sharing Information',
              content:
                  'Little Heroes does not sell personal information. Information is only shared '
                  'with your school administration and, where applicable, with the payment provider '
                  'processing school-related payments on your behalf. Information may be disclosed '
                  'if required by law or to protect the safety of students and staff.',
            ),
            InformationSection(
              heading: 'Your Rights',
              content:
                  'To access, correct, or delete your personal information, or to request deletion '
                  'of your account, please contact your school administrator. Your school is '
                  'responsible for managing your data and handling all such requests. Little Heroes '
                  'will support your school in fulfilling these requests.',
            ),
            InformationSection(
              heading: 'Data Deletion',
              content:
                  'Account deletion and personal data removal are managed by your school '
                  'administrator. If you wish to have your account or your child\'s information '
                  'removed, please contact your school administrator. Once your school requests '
                  'deletion, Little Heroes will permanently remove the associated data from its '
                  'systems within a reasonable time.',
            ),
            InformationSection(
              heading: 'Children\'s Privacy',
              content:
                  'Student information is entered and controlled by your school. The app does not '
                  'allow students to create accounts independently. Parents and guardians receive '
                  'access to their children\'s information only through accounts created by their '
                  'school administrator.',
            ),
            InformationSection(
              heading: 'Policy Updates',
              content:
                  'This Privacy Policy may be updated from time to time to reflect changes in the '
                  'platform or legal requirements. Continued use of the Little Heroes app after '
                  'updates means you acknowledge and accept the revised policy.',
            ),
          ],
        ),
      ),
    );
  }

  void _openTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InformationPage(
          title: 'Terms & Conditions',
          subtitle:
              'Please read these terms carefully before using the Little Heroes app. Your school administrator manages your account and access.',
          icon: Icons.description_outlined,
          sections: [
            InformationSection(
              heading: 'Acceptance of Terms',
              content:
                  'By accessing or using the Little Heroes mobile application, you agree to these '
                  'Terms and Conditions. If you do not agree, please discontinue use of the app.',
            ),
            InformationSection(
              heading: 'Account Creation',
              content:
                  'Accounts are created by your school administrator. You do not register through '
                  'the mobile app. You will receive login credentials from your school. Teachers, '
                  'parents, and administrators are responsible for using the credentials provided '
                  'to them by their school.',
            ),
            InformationSection(
              heading: 'User Responsibilities',
              content:
                  'You are responsible for protecting the login credentials provided to you by your '
                  'school, using the platform respectfully, and ensuring the information you share '
                  'through the app is accurate and appropriate.',
            ),
            InformationSection(
              heading: 'Appropriate Use',
              content:
                  'The platform must be used only for educational and school-communication '
                  'purposes. Users must not misuse the system, attempt unauthorised access, or '
                  'disrupt platform services.',
            ),
            InformationSection(
              heading: 'Account Security',
              content:
                  'You are responsible for keeping your login credentials secure. If you believe '
                  'your account has been compromised, or if you need a password reset, contact your '
                  'school administrator immediately. Account security and password resets are '
                  'handled by your school.',
            ),
            InformationSection(
              heading: 'Payments',
              content:
                  'If your school enables in-app payment features, all payments made through the '
                  'Little Heroes app are for school-related services, such as school fees, '
                  'activity charges, meals, or other real-world educational services provided by '
                  'your school. These payments are not for access to the app or digital content. '
                  'Payment processing is handled by school-approved payment providers. Little '
                  'Heroes does not store card details. For questions about charges, refunds, or '
                  'billing, please contact your school administrator.',
            ),
            InformationSection(
              heading: 'Content and Communication',
              content:
                  'Users are expected to communicate respectfully with teachers, parents, '
                  'advisers, students, and administrators. Inappropriate or harmful content may '
                  'result in restricted access at the discretion of your school.',
            ),
            InformationSection(
              heading: 'Changes to the Service',
              content:
                  'Little Heroes may update, modify, or improve features and services when '
                  'necessary to maintain or improve the platform. Changes will be communicated '
                  'through your school where appropriate.',
            ),
            InformationSection(
              heading: 'Termination of Access',
              content:
                  'Access to the platform is managed by your school administrator. Your school may '
                  'restrict or terminate access if you violate these Terms and Conditions or school '
                  'policies.',
            ),
          ],
        ),
      ),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InformationPage(
          title: 'About Little Heroes',
          subtitle:
              'A platform built to strengthen communication between schools and families in early childhood education.',
          icon: Icons.auto_awesome_rounded,
          sections: [
            InformationSection(
              heading: 'Little Heroes',
              content:
                  'Little Heroes is a school communication platform designed to connect parents, '
                  'teachers, advisers, and administrators in one secure environment. The platform '
                  'is provided to you through your school.',
            ),
            InformationSection(
              heading: 'Our Mission',
              content:
                  'Our mission is to improve communication between families and educators while '
                  'supporting the growth, learning, and development of every child.',
            ),
            InformationSection(
              heading: 'Key Features',
              content:
                  'Little Heroes provides student information, daily reports, attendance records, '
                  'messages, photo galleries, progress tracking, and school-related payment '
                  'options where enabled by your school.',
            ),
            InformationSection(
              heading: 'How to Get an Account',
              content:
                  'Accounts are created by your school administrator. Please contact your school '
                  'if you need access. Account creation, password resets, and deletion requests '
                  'are all handled through your school.',
            ),
            InformationSection(
              heading: 'Application Version',
              content: 'Version 1.0.0',
            ),
            InformationSection(
              heading: 'Support',
              content:
                  'For questions, technical issues, or feedback, please contact your school '
                  'administrator or the Little Heroes support team.',
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          _row(
            context,
            colorScheme: colorScheme,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how your information is protected',
            onTap: () => _openPrivacyPolicy(context),
          ),
          Divider(height: 1, indent: 72, color: dividerColor),
          _row(
            context,
            colorScheme: colorScheme,
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms of service',
            onTap: () => _openTerms(context),
          ),
          Divider(height: 1, indent: 72, color: dividerColor),
          _row(
            context,
            colorScheme: colorScheme,
            icon: Icons.info_outline_rounded,
            title: 'About Little Heroes',
            subtitle: 'App information and version',
            onTap: () => _openAbout(context),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext ctx, {
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}