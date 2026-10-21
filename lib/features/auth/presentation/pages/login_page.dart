import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/widgets/app_button.dart';
import 'package:little_heroes_mobile/core/widgets/app_scaffold.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/country_picker.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/password_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  Country _selectedCountry = countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required';
    if (phone.length < 7) return 'Enter a valid phone number';
    return null;
  }

  void _login() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) return;

    final phoneNumber =
        '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(
      LoginRequested(phoneNumber: phoneNumber, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // if (state is AuthAuthenticated) {
        //   HapticFeedback.mediumImpact();
        //   debugPrint('🚀 AUTHENTICATED → going to ${AppRoutes.main}');
        //   context.go(AppRoutes.main);
        //   return;
        // }

        if (state is AuthAuthenticated) {
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod(
            'TextInput.hide',
          ); // iOS specific
          HapticFeedback.mediumImpact();
          context.go(AppRoutes.main);
          return;
        }

        if (state is OtpSent) {
          HapticFeedback.mediumImpact();
          context.push(
            AppRoutes.otpVerification,
            extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
          );
          return;
        }

        if (state is AuthError) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AppScaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // ── Soft background gradient ──────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          isDark
                              ? AppColors.darkBackground
                              : AppColors.lightSurface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Blue glow — top-left ──────────────────
              Positioned(
                top: -120,
                left: -80,
                child: IgnorePointer(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (isDark ? AppColors.primaryLight : AppColors.primary)
                              .withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Yellow accent glow — bottom-right ─────
              Positioned(
                bottom: -140,
                right: -100,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withValues(
                            alpha: isDark ? 0.10 : 0.16,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final hPad = constraints.maxWidth > 600 ? 48.0 : 24.0;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 24),

                                  // ── Brand wordmark (no icon) ─
                                  const _BrandHeader(),

                                  const SizedBox(height: 40),

                                  // ── Welcome heading ───────
                                  _WelcomeHeading(colors: colors),

                                  const SizedBox(height: 10),
                                  Text(
                                    'Sign in with your phone number and '
                                    'password to continue.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      height: 1.55,
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // ── Phone label ───────────
                                  _FieldLabel(
                                    text: 'PHONE NUMBER',
                                    colorScheme: colors,
                                  ),
                                  const SizedBox(height: 10),
                                  PhoneNumberField(
                                    controller: _phoneController,
                                    selectedCountry: _selectedCountry,
                                    onCountryChanged: (country) {
                                      HapticFeedback.selectionClick();
                                      setState(
                                        () => _selectedCountry = country,
                                      );
                                    },
                                    validator: _validatePhone,
                                  ),

                                  const SizedBox(height: 20),
                                  PasswordField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    hintText: 'Enter your password',
                                    onSubmitted: _login,
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Login button ──────────
                                  AppButton(
                                    text: 'Login',
                                    onPressed: isLoading ? null : _login,
                                    isLoading: isLoading,
                                    height: 56,
                                    borderRadius: 14,
                                    backgroundColor: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                    foregroundColor: isDark
                                        ? AppColors.darkBackground
                                        : AppColors.white,
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Footer ────────────────
                                  const _TermsFooter(),

                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND HEADER — gradient wordmark + accent bar (no icon)
// ═══════════════════════════════════════════════════════════════
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final startColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final endColor = isDark ? AppColors.primary : AppColors.primaryDark;

    return Column(
      children: [
        // Gradient wordmark
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [startColor, endColor],
          ).createShader(bounds),
          child: Text(
            'Little Heroes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              // white text → becomes gradient via the shader
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Accent bar — yellow → blue pill
        Container(
          height: 4,
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.accent,
                isDark ? AppColors.primary : AppColors.primaryDark,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WELCOME HEADING — "Welcome back." with accent period
// ═══════════════════════════════════════════════════════════════
class _WelcomeHeading extends StatelessWidget {
  final ColorScheme colors;
  const _WelcomeHeading({required this.colors});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.15,
    );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'Welcome back'),
          TextSpan(
            text: '.',
            style: baseStyle?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FIELD LABEL — uppercase, letter-spaced, primary-tinted
// ═══════════════════════════════════════════════════════════════
class _FieldLabel extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;

  const _FieldLabel({required this.text, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TERMS FOOTER — reassurance-style
// ═══════════════════════════════════════════════════════════════
class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'By continuing you agree to our Terms',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}
