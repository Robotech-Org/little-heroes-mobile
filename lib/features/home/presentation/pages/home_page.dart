import 'package:flutter/material.dart';

import '../../../../core/constants/user_role.dart';
import 'adviser_home_page.dart';
import 'parent_home_page.dart';
import 'teacher_home_page.dart';

class HomePage extends StatelessWidget {
  final UserRole role;

  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.teacher:
        return const TeacherHomePage();

      case UserRole.parent:
        return const ParentHomePage();

      case UserRole.adviser:
        return const AdviserHomePage();
    }
  }
}
