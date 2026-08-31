import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text.dart';
import '../widgets/phone_number_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();

  bool _isLoading = false;

  Country _selectedCountry = countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Frontend-only simulation.
    //
    // Later:
    // SendOtpUseCase
    // will be connected here.

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final phoneNumber =
        '${_selectedCountry.dialCode}${_phoneController.text.trim()}';

    context.push(AppRoutes.otpVerification, extra: phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      size: 38,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  AppText(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  AppText(
                    'Sign in to Little Heroes using your phone number.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  AppText(
                    'Phone Number',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

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

                  const SizedBox(height: 12),

                  AppText(
                    'We will send a 6-digit verification code to this number.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 28),

                  AppButton(
                    text: 'Send OTP',
                    onPressed: _sendOtp,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.register);
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
