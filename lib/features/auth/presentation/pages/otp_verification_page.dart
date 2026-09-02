
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

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

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

    _remainingSeconds = 30;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
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
      },
    );
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

    // TODO: Connect your real OTP verification here.

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    SnackbarUtils.showSuccess(
      context,
      'Phone number verified successfully.',
    );

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.main);
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  void _resendOtp() {
    if (!_canResend) {
      return;
    }

    setState(() {
      _otp = '';
    });

    _startTimer();

    SnackbarUtils.showSuccess(
      context,
      'A new verification code has been sent.',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // FIXED TOP BAR
            // ======================================================

            SizedBox(
              height: 52,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
              ),
            ),

            // ======================================================
            // SCROLLABLE CONTENT
            // ======================================================

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                padding: const EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  30,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 440,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [
                        // ==================================================
                        // VERIFICATION ICON
                        // ==================================================

                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 32,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        AppText(
                          'Verify your phone',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // DESCRIPTION
                        // ==================================================

                        AppText(
                          'Enter the 6-digit code we sent to',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // PHONE NUMBER
                        // ==================================================

                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withValues(
                                alpha: 0.55,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),

                                const SizedBox(width: 7),

                                Text(
                                  widget.phoneNumber,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // OTP LABEL
                        // ==================================================

                        Text(
                          'Verification code',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // OTP INPUT
                        // ==================================================

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

                        const SizedBox(height: 8),

                        // ==================================================
                        // OTP HELP TEXT
                        // ==================================================

                        Text(
                          'Enter the code from your SMS',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // VERIFY BUTTON
                        // ==================================================

                        AppButton(
                          text: 'Verify & Continue',
                          onPressed: _verifyOtp,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // RESEND
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Didn't receive it?",
                                textAlign: TextAlign.center,
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),

                            const SizedBox(width: 3),

                            TextButton(
                              onPressed:
                                  _canResend ? _resendOtp : null,

                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),

                              child: Text(
                                _canResend
                                    ? 'Resend code'
                                    : 'Resend in ${_remainingSeconds}s',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        // ==================================================
                        // CHANGE PHONE NUMBER
                        // ==================================================

                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              context.pop();
                            },

                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),

                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                            ),

                            label: const Text(
                              'Change phone number',
                            ),
                          ),
                        ),

                        // Extra bottom space so the keyboard
                        // never covers the last button.
                        const SizedBox(height: 20),
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
