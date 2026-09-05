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
  String _otp = '';
  bool _isLoading = false;

  Timer? _timer;
  int _remainingSeconds = 30;

  bool get _canResend => _remainingSeconds == 0;

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

  // ============================================================
  // TIMER
  // ============================================================

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

  // ============================================================
  // VERIFY OTP
  // ============================================================

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

    // TODO: Connect real OTP verification

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    SnackbarUtils.showSuccess(context, 'Phone number verified successfully.');

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    context.go(AppRoutes.main);
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  void _resendOtp() {
    if (!_canResend) return;

    setState(() {
      _otp = '';
    });

    _startTimer();

    SnackbarUtils.showSuccess(
      context,
      'A new verification code has been sent.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // TOP BAR
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Material(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.pop(),
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CONTENT
            // =====================================================
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // =================================================
                      // TITLE
                      // =================================================
                      AppText(
                        'Enter verification code',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =================================================
                      // DESCRIPTION
                      // =================================================
                      AppText(
                        'We sent a 6-digit verification code to your phone number.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // =================================================
                      // PHONE NUMBER
                      // =================================================
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            context.pop();
                          },
                          icon: Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          label: Text(
                            widget.phoneNumber,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: colors.primaryContainer.withValues(
                              alpha: 0.45,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 42),

                      // =================================================
                      // OTP LABEL
                      // =================================================
                      Text(
                        'Verification Code',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // =================================================
                      // OTP INPUT
                      // =================================================
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

                          // Optional automatic verification
                          // _verifyOtp();
                        },
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Enter the code sent to your phone',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // =================================================
                      // VERIFY BUTTON
                      // =================================================
                      AppButton(
                        text: 'Verify & Continue',
                        onPressed: _otp.length == 6 && !_isLoading
                            ? _verifyOtp
                            : null,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // =================================================
                      // RESEND SECTION
                      // =================================================
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Didn't receive the code?",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 4),

                            TextButton(
                              onPressed: _canResend ? _resendOtp : null,
                              child: Text(
                                _canResend
                                    ? 'Resend Code'
                                    : 'Resend code in ${_remainingSeconds}s',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _canResend
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =================================================
                      // CHANGE NUMBER
                      // =================================================
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('Change phone number'),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
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
