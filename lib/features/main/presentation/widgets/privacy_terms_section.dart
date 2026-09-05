import 'package:flutter/material.dart';

import '../pages/information_page.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class PrivacyTermsSection extends StatelessWidget {
  const PrivacyTermsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Privacy & Terms',
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how we protect your information',
            onTap: () => _openPrivacyPolicy(context),
          ),

          SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms of service',
            onTap: () => _openTermsAndConditions(context),
          ),

          SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About Little Heroes',
            subtitle: 'App information and version',
            showDivider: false,
            onTap: () => _openAbout(context),
          ),
        ],
      ),
    );
  }

  // PRIVACY POLICY

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InformationPage(
          title: 'Privacy Policy',
          subtitle: 'Your privacy and the protection of your personal information are important to Little Heroes.',
          icon: Icons.privacy_tip_outlined,
          sections: [
            InformationSection(
              heading: 'Information We Collect',
              content:
                  'Little Heroes may collect information necessary to provide educational and communication services. '
                  'This may include profile information, student-related information, messages, reports, and other information required for the proper functioning of the platform.',
            ),

            InformationSection(
              heading: 'How We Use Your Information',
              content: 'Your information is used to provide and improve our services, support communication between parents and educators, manage student activities, and maintain a safe and effective educational environment.',
            ),

            InformationSection(
              heading: 'Data Protection',
              content:
                  'We take appropriate measures to protect your personal information from unauthorized access, loss, misuse, or disclosure. '
                  'Access to sensitive information is limited to authorized users and personnel.',
            ),

            InformationSection(
              heading: 'Sharing Information',
              content: 'Little Heroes does not sell your personal information. Information may only be shared when necessary to provide our services or when required by applicable laws and regulations.',
            ),

            InformationSection(
              heading: 'Your Rights',
              content: 'You may request access to your personal information, request corrections, or contact the school administration regarding questions about how your information is managed.',
            ),

            InformationSection(
              heading: 'Policy Updates',
              content: 'This Privacy Policy may be updated from time to time. Continued use of the Little Heroes platform means you acknowledge and accept any updated policy.',
            ),
          ],
        ),
      ),
    );
  }

  // TERMS & CONDITIONS

  void _openTermsAndConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InformationPage(
          title: 'Terms & Conditions',
          subtitle: 'Please read these terms carefully before using the Little Heroes platform.',
          icon: Icons.description_outlined,
          sections: [
            InformationSection(
              heading: 'Acceptance of Terms',
              content: 'By accessing or using Little Heroes, you agree to follow these Terms and Conditions and use the platform responsibly.',
            ),

            InformationSection(
              heading: 'User Responsibilities',
              content: 'Users are responsible for maintaining accurate information, protecting their account credentials, and using the platform respectfully and appropriately.',
            ),

            InformationSection(
              heading: 'Appropriate Use',
              content: 'The platform must only be used for its intended educational and communication purposes. Users must not misuse the system, attempt unauthorized access, or disrupt platform services.',
            ),

            InformationSection(
              heading: 'Account Security',
              content: 'You are responsible for keeping your login credentials secure. If you believe your account has been accessed without permission, contact the appropriate administrator immediately.',
            ),

            InformationSection(
              heading: 'Content and Communication',
              content: 'Users are expected to communicate respectfully with teachers, parents, advisers, students, and administrators. Inappropriate or harmful content may result in restricted access to the platform.',
            ),

            InformationSection(
              heading: 'Changes to the Service',
              content: 'Little Heroes may update, modify, or improve features and services when necessary to maintain or improve the platform.',
            ),

            InformationSection(
              heading: 'Termination of Access',
              content: 'Access to the platform may be restricted or terminated if a user violates these Terms and Conditions or school policies.',
            ),
          ],
        ),
      ),
    );
  }

  // ABOUT

  void _openAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InformationPage(
          title: 'About Little Heroes',
          subtitle: 'A platform built to strengthen communication and collaboration in early childhood education.',
          icon: Icons.auto_awesome_rounded,
          sections: [
            InformationSection(
              heading: 'Little Heroes',
              content: 'Little Heroes is a digital platform designed to connect parents, teachers, advisers, and students in one simple and secure environment.',
            ),

            InformationSection(
              heading: 'Our Mission',
              content: 'Our mission is to improve communication between families and educators while supporting the growth, learning, and development of every child.',
            ),

            InformationSection(
              heading: 'Key Features',
              content: 'Little Heroes provides student information, daily reports, communication tools, notifications, progress tracking, and other educational features.',
            ),

            InformationSection(
              heading: 'Application Version',
              content: 'Version 1.0.0',
            ),

            InformationSection(
              heading: 'Support',
              content: 'For questions, technical issues, or feedback, please contact your school administrator or the Little Heroes support team.',
            ),
          ],
        ),
      ),
    );
  }
}
