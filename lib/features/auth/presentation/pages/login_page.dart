import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/features/auth/presentation/widgets/country_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../injection_container.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
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

  // PHONE VALIDATION

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    if (phone.length < 7) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // LOGIN

  void _login() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final phoneNumber =
        '${_selectedCountry.dialCode}${_phoneController.text.trim()}';

    final password = _passwordController.text.trim();
    print('Login with phone: $phoneNumber, password: $password');

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
        //
        // OTP SENT SUCCESSFULLY
        //

        // if (state is OtpSent) {
        //   context.push(AppRoutes.otpVerification, extra: state.phoneNumber);
        // }
        if (state is OtpSent) {
          context.push(
            AppRoutes.otpVerification,
            extra: {'phoneNumber': state.phoneNumber, 'tmpId': state.tmpId},
          );
        }

        //
        // ERROR
        //

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
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
                            const SizedBox(height: 18),

                            //
                            // TOP LOGO
                            //
                            Align(
                              alignment: Alignment.centerRight,

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  const SizedBox(width: 5),

                                  Text(
                                    'Little Heroes',

                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            //
                            // WELCOME
                            //
                            AppText(
                              'Welcome Back! ',

                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Sign in using your phone number and password.',

                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 38),

                            //
                            // PHONE NUMBER LABEL
                            //
                            Text(
                              'Phone Number',

                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            //
                            // PHONE NUMBER FIELD
                            //
                            PhoneNumberField(
                              controller: _phoneController,
                              selectedCountry: _selectedCountry,

                              onCountryChanged: (country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },

                              validator: _validatePhone,
                            ),

                            const SizedBox(height: 20),

                            //
                            // PASSWORD FIELD
                            //
                            PasswordField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Enter your password',
                            ),

                            const SizedBox(height: 10),

                            //
                            // FORGOT PASSWORD
                            //
                            Align(
                              alignment: Alignment.centerRight,

                              child: TextButton(
                                onPressed: () {
                                  // TODO: Navigate to forgot password page
                                },

                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 32),
                                ),

                                child: Text(
                                  'Forgot Password?',

                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            //
                            // LOGIN BUTTON
                            //
                            SizedBox(
                              height: 56,

                              child: AppButton(
                                text: 'Login',

                                onPressed: isLoading ? null : _login,

                                isLoading: isLoading,
                              ),
                            ),

                            const SizedBox(height: 18),

                            //
                            // SIGN UP
                            //
                            const Spacer(),

                            const SizedBox(height: 24),
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
