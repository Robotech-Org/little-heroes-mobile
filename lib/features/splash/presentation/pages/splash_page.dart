import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/core/widgets/little_heroes_loading.dart';

import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _isNavigated) return;

      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        _navigateToMain();
        return;
      }

      if (authState is AuthUnauthenticated) {
        _navigateBasedOnOnboarding();
        return;
      }

      if (authState is AuthInitial || authState is AuthLoading) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  void _navigateBasedOnOnboarding() {
    if (_isNavigated) return;
    _isNavigated = true;

    final isOnboardingCompleted = StorageService.instance
        .isOnboardingCompleted();

    if (isOnboardingCompleted) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  void _navigateToMain() {
    if (_isNavigated) return;
    _isNavigated = true;
    context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (_isNavigated) return;

        if (state is AuthAuthenticated) {
          _navigateToMain();
        } else if (state is AuthUnauthenticated) {
          _navigateBasedOnOnboarding();
        } else if (state is AuthError) {
          if (!_isNavigated) {
            _isNavigated = true;
            context.go(AppRoutes.login);
          }
        }
      },
      child: Scaffold(
        backgroundColor: colors.primary,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Center content ───────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo — smaller, quieter
                    _LogoMark(color: Colors.white),
                    const SizedBox(height: 28),

                    // App name
                    Text(
                      'Little Heroes',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      'Nurturing young minds',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom loader + version ──────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Column(
                  children: [
                    const LittleHeroesLoading(size: 28, message: ''),
                    const SizedBox(height: 24),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.35),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LOGO MARK — small, clean, single accent
// ═══════════════════════════════════════════════════════════════
class _LogoMark extends StatelessWidget {
  final Color color;
  const _LogoMark({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thin outer ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
          ),
          // Inner filled circle
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.shield_rounded, size: 32, color: color),
          ),
        ],
      ),
    );
  }
}
