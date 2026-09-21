import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/widgets/app_button.dart';
import 'package:little_heroes_mobile/core/widgets/app_scaffold.dart';
import 'package:little_heroes_mobile/injection_container.dart';

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
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
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

  Country _selectedCountry = countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required';
    if (phone.length < 7) return 'Enter a valid phone number';
    return null;
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

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

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          context.push(
            AppRoutes.otpVerification,
            extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AppScaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),

                            // ── Logo mark ──────────────────
                            Center(child: _BrandMark(colors: colors)),
                            const SizedBox(height: 12),

                            // ── App name ───────────────────
                            Center(
                              child: Text(
                                'Little Heroes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // ── Welcome ────────────────────
                            Text(
                              'Welcome back',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in with your phone number and password.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // ── Phone label ────────────────
                            Text(
                              'Phone Number',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // ── Phone field ────────────────
                            PhoneNumberField(
                              controller: _phoneController,
                              selectedCountry: _selectedCountry,
                              onCountryChanged: (country) {
                                setState(() => _selectedCountry = country);
                              },
                              validator: _validatePhone,
                            ),

                            const SizedBox(height: 20),

                            // ── Password ───────────────────
                            PasswordField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Enter your password',
                            ),

                            const SizedBox(height: 6),

                            // ── Forgot password ────────────
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: navigate to forgot password
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Login button ───────────────
                            SizedBox(
                              height: 56,
                              child: AppButton(
                                text: 'Login',
                                onPressed: isLoading ? null : _login,
                                isLoading: isLoading,
                              ),
                            ),

                            const Spacer(),

                            // ── Footer ─────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'By continuing you agree to our Terms.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND MARK — small round logo at the top
// ═══════════════════════════════════════════════════════════════
class _BrandMark extends StatelessWidget {
  final ColorScheme colors;
  const _BrandMark({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryContainer.withValues(alpha: 0.55),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.shield_rounded, size: 28, color: colors.primary),
    );
  }
}
