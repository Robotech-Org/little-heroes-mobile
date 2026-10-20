// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:little_heroes_mobile/core/router/app_routes.dart';
// import 'package:little_heroes_mobile/core/widgets/app_button.dart';
// import 'package:little_heroes_mobile/core/widgets/app_scaffold.dart';

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
//     //  FIX: Use the ROOT AuthBloc from main.dart.
//     // Do NOT create a new BlocProvider here — the router reads the
//     // root bloc, so both must share the SAME instance.
//     return const _LoginView();
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

//   final _phoneFocus = FocusNode();
//   final _passwordFocus = FocusNode();

//   Country _selectedCountry = countries.first;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _phoneFocus.dispose();
//     _passwordFocus.dispose();
//     super.dispose();
//   }

//   String? _validatePhone(String? value) {
//     final phone = value?.trim() ?? '';
//     if (phone.isEmpty) return 'Phone number is required';
//     if (phone.length < 7) return 'Enter a valid phone number';
//     return null;
//   }

//   void _login() {
//     FocusScope.of(context).unfocus();
//     HapticFeedback.lightImpact();

//     if (!_formKey.currentState!.validate()) return;

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
//         // ─────────────────────────────────────────────
//         //  OTP OFF — direct login (bypass)
//         // ─────────────────────────────────────────────
//         if (state is AuthAuthenticated) {
//           HapticFeedback.mediumImpact();
//           debugPrint('🚀 AUTHENTICATED → going to ${AppRoutes.main}');
//           context.go(AppRoutes.main);
//           return;
//         }

//         // ─────────────────────────────────────────────
//         // 📩 OTP ON — go to verification page
//         // ─────────────────────────────────────────────
//         if (state is OtpSent) {
//           HapticFeedback.mediumImpact();
//           context.push(
//             AppRoutes.otpVerification,
//             extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
//           );
//           return;
//         }

//         // ─────────────────────────────────────────────
//         // ⚠️ Error — show snackbar
//         // ─────────────────────────────────────────────
//         if (state is AuthError) {
//           HapticFeedback.heavyImpact();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   const Icon(
//                     Icons.error_outline_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(child: Text(state.message)),
//                 ],
//               ),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: colors.error,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               margin: const EdgeInsets.all(16),
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
//                 //  Responsive horizontal padding
//                 final hPad = constraints.maxWidth > 600 ? 48.0 : 24.0;

//                 return SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   keyboardDismissBehavior:
//                       ScrollViewKeyboardDismissBehavior.onDrag,
//                   padding: EdgeInsets.symmetric(horizontal: hPad),
//                   child: ConstrainedBox(
//                     //  min height so short content still centers
//                     constraints: BoxConstraints(
//                       minHeight: constraints.maxHeight,
//                     ),
//                     child: Center(
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 440),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min, //  KEY FIX
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               const SizedBox(height: 24),

//                               // ── Logo mark ──────────────
//                               Center(child: _AnimatedBrandMark()),
//                               const SizedBox(height: 16),

//                               // ── App name ───────────────
//                               Center(
//                                 child: Text(
//                                   'Little Heroes',
//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.w800,
//                                     color: colors.primary,
//                                     letterSpacing: 0.2,
//                                   ),
//                                 ),
//                               ),

//                               const SizedBox(height: 40),

//                               // ── Welcome ────────────────
//                               Text(
//                                 'Welcome back',
//                                 style: theme.textTheme.headlineMedium?.copyWith(
//                                   fontWeight: FontWeight.w800,
//                                   letterSpacing: -0.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Sign in with your phone number and password.',
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   color: colors.onSurfaceVariant,
//                                   height: 1.5,
//                                 ),
//                               ),

//                               const SizedBox(height: 28),

//                               // ── Phone ───────────────────
//                               Text(
//                                 'Phone Number',
//                                 style: theme.textTheme.labelMedium?.copyWith(
//                                   color: colors.onSurfaceVariant,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),

//                               PhoneNumberField(
//                                 controller: _phoneController,
//                                 selectedCountry: _selectedCountry,
//                                 onCountryChanged: (country) {
//                                   HapticFeedback.selectionClick();
//                                   setState(() => _selectedCountry = country);
//                                 },
//                                 validator: _validatePhone,
//                               ),

//                               const SizedBox(height: 20),

//                               // ── Password ────────────────
//                               PasswordField(
//                                 controller: _passwordController,
//                                 label: 'Password',
//                                 hintText: 'Enter your password',
//                               ),

//                               const SizedBox(height: 6),

//                               // ── Forgot password ─────────
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: _ForgotPasswordButton(
//                                   onTap: isLoading
//                                       ? null
//                                       : () {
//                                           HapticFeedback.selectionClick();
//                                           _showForgotPasswordDialog(context);
//                                         },
//                                 ),
//                               ),

//                               const SizedBox(height: 24),

//                               // ── Login button ────────────
//                               SizedBox(
//                                 height: 56,
//                                 child: AppButton(
//                                   text: 'Login',
//                                   onPressed: isLoading ? null : _login,
//                                   isLoading: isLoading,
//                                 ),
//                               ),

//                               const SizedBox(height: 24), //  replaces Spacer
//                               // ── Footer ──────────────────
//                               Center(
//                                 child: Text(
//                                   'By continuing you agree to our Terms.',
//                                   textAlign: TextAlign.center,
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: colors.onSurfaceVariant.withValues(
//                                       alpha: 0.7,
//                                     ),
//                                     fontSize: 11.5,
//                                   ),
//                                 ),
//                               ),

//                               const SizedBox(height: 16),
//                             ],
//                           ),
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

//   void _showForgotPasswordDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 24,
//             right: 24,
//             top: 24,
//             //  SafeArea bottom for gesture bar
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Theme.of(ctx).colorScheme.outlineVariant,
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Forgot your password?',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(ctx).textTheme.titleLarge
//                     ?.copyWith(fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please contact your school administrator to reset your password.',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(ctx).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 24),
//               AppButton(text: 'OK', onPressed: () => Navigator.of(ctx).pop()),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ANIMATED BRAND MARK
// // ═══════════════════════════════════════════════════════════════
// class _AnimatedBrandMark extends StatefulWidget {
//   @override
//   State<_AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
// }

// class _AnimatedBrandMarkState extends State<_AnimatedBrandMark>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..forward();
//     _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     return ScaleTransition(
//       scale: _scale,
//       child: Container(
//         width: 72,
//         height: 72,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: colors.primaryContainer.withValues(alpha: 0.55),
//           border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
//           boxShadow: [
//             BoxShadow(
//               color: colors.primary.withValues(alpha: 0.15),
//               blurRadius: 24,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         alignment: Alignment.center,
//         child: Icon(Icons.shield_rounded, size: 32, color: colors.primary),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // FORGOT PASSWORD BUTTON
// // ═══════════════════════════════════════════════════════════════
// class _ForgotPasswordButton extends StatefulWidget {
//   final VoidCallback? onTap;
//   const _ForgotPasswordButton({this.onTap});

//   @override
//   State<_ForgotPasswordButton> createState() => _ForgotPasswordButtonState();
// }

// class _ForgotPasswordButtonState extends State<_ForgotPasswordButton> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     return GestureDetector(
//       onTapDown: widget.onTap == null
//           ? null
//           : (_) => setState(() => _pressed = true),
//       onTapUp: widget.onTap == null
//           ? null
//           : (_) {
//               setState(() => _pressed = false);
//               widget.onTap!();
//             },
//       onTapCancel: () => setState(() => _pressed = false),
//       child: AnimatedScale(
//         scale: _pressed ? 0.94 : 1.0,
//         duration: const Duration(milliseconds: 100),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           child: Text(
//             'Forgot password?',
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: widget.onTap == null
//                   ? colors.onSurfaceVariant.withValues(alpha: 0.5)
//                   : colors.primary,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    // Uses the ROOT AuthBloc from main.dart — do NOT wrap in another
    // BlocProvider here, or the router redirect will see a different bloc.
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
        // ── Direct login ──────────────────────────────
        if (state is AuthAuthenticated) {
          HapticFeedback.mediumImpact();
          debugPrint('🚀 AUTHENTICATED → going to ${AppRoutes.main}');
          context.go(AppRoutes.main);
          return;
        }

        // ── OTP flow ──────────────────────────────────
        if (state is OtpSent) {
          HapticFeedback.mediumImpact();
          context.push(
            AppRoutes.otpVerification,
            extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
          );
          return;
        }

        // ── Error ─────────────────────────────────────
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
              // ── Soft background gradient ────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground),
                          (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightSurface),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Primary radial glow (top-left) ──────────
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
                              .withValues(alpha: 0.10),
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
                                  const SizedBox(height: 32),

                                  // ── Brand mark ────────────
                                  const Center(child: _AnimatedBrandMark()),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Text(
                                      'Little Heroes',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: colors.primary,
                                            letterSpacing: 0.4,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(height: 44),

                                  // ── Welcome heading ───────
                                  Text(
                                    'Welcome back.',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.6,
                                          height: 1.15,
                                        ),
                                  ),
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

                                  // ── Password label + Forgot ─
                                  Row(
                                    children: [
                                      _FieldLabel(
                                        text: 'PASSWORD',
                                        colorScheme: colors,
                                      ),
                                      const Spacer(),
                                      _ForgotPasswordButton(
                                        onTap: isLoading
                                            ? null
                                            : () {
                                                HapticFeedback.selectionClick();
                                                _showForgotPasswordDialog(
                                                  context,
                                                );
                                              },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  PasswordField(
                                    controller: _passwordController,
                                    label: '',
                                    hintText: 'Enter your password',
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Login button ──────────
                                  AppButton(
                                    text: 'Login',
                                    onPressed: isLoading ? null : _login,
                                    isLoading: isLoading,
                                    height: 56,
                                    borderRadius: 14,
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

  void _showForgotPasswordDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
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
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Forgot your password?',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Please contact your school administrator to reset '
                'your password.',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Got it',
                onPressed: () => Navigator.of(ctx).pop(),
                height: 52,
                borderRadius: 14,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FIELD LABEL — uppercase, letter-spaced
// ═══════════════════════════════════════════════════════════════
class _FieldLabel extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;

  const _FieldLabel({required this.text, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED BRAND MARK — entrance + pulsing glow
// ═══════════════════════════════════════════════════════════════
class _AnimatedBrandMark extends StatefulWidget {
  const _AnimatedBrandMark();

  @override
  State<_AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
}

class _AnimatedBrandMarkState extends State<_AnimatedBrandMark>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.12, end: 0.30).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryLight : AppColors.primary;
    final containerColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, _) {
          return Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [primary.withValues(alpha: 0.22), containerColor],
              ),
              border: Border.all(
                color: primary.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: _glow.value),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.shield_rounded, size: 44, color: primary),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FORGOT PASSWORD LINK — animated pressed state
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
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'Forgot?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: disabled
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
