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
    // Add a small delay to ensure Bloc is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _isNavigated) return;

      // Check current auth state first
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        _navigateToMain();
        return;
      }

      if (authState is AuthUnauthenticated) {
        _navigateBasedOnOnboarding();
        return;
      }

      // If auth state is initial or loading, trigger check
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
          // On error, go to login
          if (!_isNavigated) {
            _isNavigated = true;
            context.go(AppRoutes.login);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primary,
                colors.primary.withValues(alpha: 0.7),
                colors.primary.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero Icon/Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // App Name
                const Text(
                  'Little Heroes',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Nurturing Young Minds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),

                // Loading Animation
                const LittleHeroesLoading(
                  size: 60,
                  message: 'Preparing your experience...',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
