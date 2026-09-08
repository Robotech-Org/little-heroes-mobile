import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/dashboard_response_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/dashboard_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  TeacherInfo? _teacherInfo;
  ParentInfo? _parentInfo;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
        return;
      }

      final repository = di.sl<DashboardRepository>();
      final response = await repository.getDashboard();

      // Extract user info based on role
      if (response.data is TeacherData) {
        final teacherData = response.data as TeacherData;
        setState(() {
          _teacherInfo = teacherData.teacher;
          _isLoading = false;
        });
      } else if (response.data is ParentData) {
        final parentData = response.data as ParentData;
        setState(() {
          _parentInfo = parentData.parent;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      print('Failed to load user data: $e');
    }
  }

  String _roleName(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.parent:
        return 'Parent';
      case UserRole.adviser:
        return 'Adviser';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getUserName(UserRole role) {
    if (_teacherInfo != null) {
      return _teacherInfo!.firstName;
    } else if (_parentInfo != null) {
      return _parentInfo!.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserRole? role;

        if (state is AuthAuthenticated) {
          role = state.user.role;
        }

        final roleText = role != null ? _roleName(role) : 'User';
        final greeting = _getGreeting();
        final userName = role != null ? _getUserName(role) : '';

        return Container(
          padding: const EdgeInsets.fromLTRB(23, 20, 16, 18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.045),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==
              // PROFILE
              // ==
              Material(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    // You can open profile/settings here later.
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.person_rounded,
                      color: colors.onPrimaryContainer,
                      size: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ==
              // WELCOME INFORMATION
              // ==
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLoading
                          ? 'Loading...'
                          : 'Welcome${userName.isNotEmpty ? ', $userName' : ''}!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // ==
                    // ROLE CHIP
                    // ==
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          roleText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ==
              // NOTIFICATION BUTTON
              // ==
              _HeaderButton(
                icon: Icons.notifications_none_rounded,
                showBadge: true,
                onTap: () {
                  context.push(AppRoutes.notifications);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// HEADER BUTTON
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: colors.onSurfaceVariant, size: 22),
              ),
              // ==
              // NOTIFICATION BADGE
              // ==
              if (showBadge)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.surfaceContainerHighest,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
