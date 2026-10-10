// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:little_heroes_mobile/core/router/app_routes.dart';
// import 'package:little_heroes_mobile/core/widgets/app_button.dart';
// import 'package:little_heroes_mobile/core/widgets/app_scaffold.dart';
// import 'package:little_heroes_mobile/injection_container.dart';

// import '../bloc/auth_bloc.dart';
// import '../bloc/auth_event.dart';
// import '../bloc/auth_state.dart';
// import '../widgets/country_picker.dart';
// import '../widgets/phone_number_field.dart';
// import '../widgets/password_field.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<AuthBloc>(
//       create: (_) => sl<AuthBloc>(),
//       child: const _LoginView(),
//     );
//   }
// }

// class _LoginView extends StatefulWidget {
//   const _LoginView();

//   @override
//   State<_LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<_LoginView> {
//   final _formKey = GlobalKey<FormState>();

//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();

//   Country _selectedCountry = countries.first;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   String? _validatePhone(String? value) {
//     final phone = value?.trim() ?? '';
//     if (phone.isEmpty) return 'Phone number is required';
//     if (phone.length < 7) return 'Enter a valid phone number';
//     return null;
//   }

//   void _login() {
//     if (!_formKey.currentState!.validate()) return;

//     FocusScope.of(context).unfocus();

//     final phoneNumber =
//         '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
//     final password = _passwordController.text.trim();

//     context.read<AuthBloc>().add(
//       LoginRequested(phoneNumber: phoneNumber, password: password),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     return BlocConsumer<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is OtpSent) {
//           context.push(
//             AppRoutes.otpVerification,
//             extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
//           );
//         }
//         if (state is AuthError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: colors.error,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         final isLoading = state is AuthLoading;

//         return AppScaffold(
//           resizeToAvoidBottomInset: true,
//           body: SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   keyboardDismissBehavior:
//                       ScrollViewKeyboardDismissBehavior.onDrag,
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       minHeight: constraints.maxHeight,
//                     ),
//                     child: IntrinsicHeight(
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             const SizedBox(height: 24),

//                             // ── Logo mark ──────────────────
//                             Center(child: _BrandMark(colors: colors)),
//                             const SizedBox(height: 12),

//                             // ── App name ───────────────────
//                             Center(
//                               child: Text(
//                                 'Little Heroes',
//                                 style: theme.textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.w800,
//                                   color: colors.primary,
//                                   letterSpacing: 0.2,
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 48),

//                             // ── Welcome ────────────────────
//                             Text(
//                               'Welcome back',
//                               style: theme.textTheme.headlineMedium?.copyWith(
//                                 fontWeight: FontWeight.w800,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Sign in with your phone number and password.',
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: colors.onSurfaceVariant,
//                                 height: 1.5,
//                               ),
//                             ),

//                             const SizedBox(height: 36),

//                             // ── Phone label ────────────────
//                             Text(
//                               'Phone Number',
//                               style: theme.textTheme.labelMedium?.copyWith(
//                                 color: colors.onSurfaceVariant,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 10),

//                             // ── Phone field ────────────────
//                             PhoneNumberField(
//                               controller: _phoneController,
//                               selectedCountry: _selectedCountry,
//                               onCountryChanged: (country) {
//                                 setState(() => _selectedCountry = country);
//                               },
//                               validator: _validatePhone,
//                             ),

//                             const SizedBox(height: 20),

//                             // ── Password ───────────────────
//                             PasswordField(
//                               controller: _passwordController,
//                               label: 'Password',
//                               hintText: 'Enter your password',
//                             ),

//                             const SizedBox(height: 6),

//                             // ── Forgot password ────────────
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: () {
//                                   // TODO: navigate to forgot password
//                                 },
//                                 style: TextButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 4,
//                                   ),
//                                   minimumSize: const Size(0, 32),
//                                   tapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                 ),
//                                 child: Text(
//                                   'Forgot password?',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: colors.primary,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 24),

//                             // ── Login button ───────────────
//                             SizedBox(
//                               height: 56,
//                               child: AppButton(
//                                 text: 'Login',
//                                 onPressed: isLoading ? null : _login,
//                                 isLoading: isLoading,
//                               ),
//                             ),

//                             const Spacer(),

//                             // ── Footer ─────────────────────
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 24),
//                               child: Center(
//                                 child: Text(
//                                   'By continuing you agree to our Terms.',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: colors.onSurfaceVariant.withValues(
//                                       alpha: 0.7,
//                                     ),
//                                     fontSize: 11.5,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRAND MARK — small round logo at the top
// // ═══════════════════════════════════════════════════════════════
// class _BrandMark extends StatelessWidget {
//   final ColorScheme colors;
//   const _BrandMark({required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 64,
//       height: 64,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: colors.primaryContainer.withValues(alpha: 0.55),
//         border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
//       ),
//       alignment: Alignment.center,
//       child: Icon(Icons.shield_rounded, size: 28, color: colors.primary),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          HapticFeedback.mediumImpact();
          context.push(
            AppRoutes.otpVerification,
            extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
          );
        }
        if (state is AuthError) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.error,
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
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ✅ Responsive horizontal padding
                final hPad = constraints.maxWidth > 600 ? 48.0 : 24.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: ConstrainedBox(
                    // ✅ min height so short content still centers
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // ✅ KEY FIX
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),

                              // ── Logo mark ──────────────
                              Center(child: _AnimatedBrandMark()),
                              const SizedBox(height: 16),

                              // ── App name ───────────────
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

                              const SizedBox(height: 40),

                              // ── Welcome ────────────────
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

                              const SizedBox(height: 28),

                              // ── Phone ───────────────────
                              Text(
                                'Phone Number',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),

                              PhoneNumberField(
                                controller: _phoneController,
                                selectedCountry: _selectedCountry,
                                onCountryChanged: (country) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedCountry = country);
                                },
                                validator: _validatePhone,
                              ),

                              const SizedBox(height: 20),

                              // ── Password ────────────────
                              PasswordField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: 'Enter your password',
                              ),

                              const SizedBox(height: 6),

                              // ── Forgot password ─────────
                              Align(
                                alignment: Alignment.centerRight,
                                child: _ForgotPasswordButton(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          HapticFeedback.selectionClick();
                                          _showForgotPasswordDialog(context);
                                        },
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Login button ────────────
                              SizedBox(
                                height: 56,
                                child: AppButton(
                                  text: 'Login',
                                  onPressed: isLoading ? null : _login,
                                  isLoading: isLoading,
                                ),
                              ),

                              const SizedBox(height: 24), // ✅ replaces Spacer
                              // ── Footer ──────────────────
                              Center(
                                child: Text(
                                  'By continuing you agree to our Terms.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
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
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            // ✅ SafeArea bottom for gesture bar
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Forgot your password?',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Please contact your school administrator to reset your password.',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppButton(text: 'OK', onPressed: () => Navigator.of(ctx).pop()),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED BRAND MARK
// ═══════════════════════════════════════════════════════════════
class _AnimatedBrandMark extends StatefulWidget {
  @override
  State<_AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
}

class _AnimatedBrandMarkState extends State<_AnimatedBrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryContainer.withValues(alpha: 0.55),
          border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(Icons.shield_rounded, size: 32, color: colors.primary),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FORGOT PASSWORD BUTTON
// ═══════════════════════════════════════════════════════════════
class _ForgotPasswordButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _ForgotPasswordButton({this.onTap});

  @override
  State<_ForgotPasswordButton> createState() => _ForgotPasswordButtonState();
}

class _ForgotPasswordButtonState extends State<_ForgotPasswordButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'Forgot password?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: widget.onTap == null
                  ? colors.onSurfaceVariant.withValues(alpha: 0.5)
                  : colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
