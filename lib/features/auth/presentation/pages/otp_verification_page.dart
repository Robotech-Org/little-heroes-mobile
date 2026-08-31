import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text.dart';
import '../widgets/otp_input.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // =========================
  // CONTROLLERS / STATE
  // =========================

  String _otp = '';

  bool _isLoading = false;

  Timer? _timer;

  int _remainingSeconds = 30;

  bool get _canResend => _remainingSeconds == 0;

  // =========================
  // LIFECYCLE
  // =========================

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  // =========================
  // OTP TIMER
  // =========================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  // =========================
  // VERIFY OTP
  // =========================

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      SnackbarUtils.showError(
        context,
        'Please enter the 6-digit verification code.',
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // =========================================
    // FRONTEND ONLY
    //
    // Later connect your real authentication:
    //
    // VerifyOtpUseCase
    // AuthBloc
    // API
    //
    // Example:
    //
    // context.read<AuthBloc>().add(
    //   VerifyOtpRequested(
    //     phoneNumber: widget.phoneNumber,
    //     otp: _otp,
    //   ),
    // );
    // =========================================

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // =========================================
    // TEMPORARY FRONTEND NAVIGATION
    // =========================================

    SnackbarUtils.showSuccess(context, 'Phone number verified successfully.');

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.main);
  }

  // =========================
  // RESEND OTP
  // =========================

  void _resendOtp() {
    if (!_canResend) {
      return;
    }

    // =========================================
    // FRONTEND ONLY
    //
    // Later:
    //
    // SendOtpUseCase
    // AuthBloc
    // API
    // =========================================

    _startTimer();

    setState(() {
      _otp = '';
    });

    SnackbarUtils.showSuccess(
      context,
      'A new verification code has been sent.',
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // =====================================
            // HEADER
            // =====================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                  ),
                ],
              ),
            ),

            // =====================================
            // CONTENT
            // =====================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // =================================
                        // PHONE ICON
                        // =================================
                        Center(
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.10,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone_android_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =================================
                        // TITLE
                        // =================================
                        AppText(
                          'Verify your phone',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // =================================
                        // DESCRIPTION
                        // =================================
                        AppText(
                          'We sent a 6-digit verification code to your phone number.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // =================================
                        // PHONE NUMBER
                        // =================================
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 19,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.phoneNumber,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 38),

                        // =================================
                        // OTP LABEL
                        // =================================
                        AppText(
                          'Enter verification code',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // =================================
                        // OTP INPUT
                        // =================================
                        OtpInput(
                          onChanged: (otp) {
                            setState(() {
                              _otp = otp;
                            });
                          },
                          onCompleted: (otp) {
                            setState(() {
                              _otp = otp;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // =================================
                        // HELPER TEXT
                        // =================================
                        AppText(
                          'Enter the 6-digit code sent to your phone.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.60,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        // =================================
                        // VERIFY BUTTON
                        // =================================
                        AppButton(
                          text: 'Verify & Continue',
                          onPressed: _verifyOtp,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 24),

                        // =================================
                        // RESEND OTP
                        // =================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              'Didn\'t receive the code?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.70),
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: _canResend ? _resendOtp : null,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                              ),
                              child: Text(
                                _canResend
                                    ? 'Resend'
                                    : 'Resend in ${_remainingSeconds}s',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // =================================
                        // CHANGE PHONE
                        // =================================
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              context.pop();
                            },
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            label: const Text('Change phone number'),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
