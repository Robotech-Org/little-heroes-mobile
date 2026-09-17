import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String tmpId;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.tmpId,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );
  final List<TextEditingController> _dummy = []; // silence unused warnings

  Timer? _timer;
  int _remainingSeconds = 30;
  bool _verifying = false;

  bool get _canResend => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _dummy.clear();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // TIMER
  // ═══════════════════════════════════════════════════════════
  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // OTP INPUT HANDLING
  // ═══════════════════════════════════════════════════════════
  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) return;

    // Move to next
    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    // Auto-verify if all filled
    if (_otp.length == _otpLength) {
      _verifyOtp();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // VERIFY
  // ═══════════════════════════════════════════════════════════
  void _verifyOtp() {
    if (_verifying) return;

    if (_otp.length != _otpLength) {
      SnackbarUtils.showError(
        context,
        'Please enter the $_otpLength-digit code.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _verifying = true);

    context.read<AuthBloc>().add(
      VerifyOtpRequested(
        tmpId: widget.tmpId,
        otp: _otp,
        phoneNumber: widget.phoneNumber,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RESEND
  // ═══════════════════════════════════════════════════════════
  void _resendOtp() {
    if (!_canResend) return;
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startTimer();
    SnackbarUtils.showSuccess(
      context,
      'Please request a new verification code.',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          SnackbarUtils.showSuccess(
            context,
            'Phone number verified successfully.',
          );
          await Future.delayed(const Duration(milliseconds: 300));
          if (!context.mounted) return;
          context.go(AppRoutes.main);
        }
        if (state is AuthError) {
          setState(() => _verifying = false);
          SnackbarUtils.showError(context, state.message);
        }
      },
      builder: (context, authState) {
        final isLoading = authState is AuthLoading || _verifying;

        return AppScaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: isLoading ? null : () => context.pop(),
                      ),
                    ],
                  ),
                ),

                // ── Content ─────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // ── Illustration ────────────
                          Center(
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                size: 44,
                                color: colors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Title ────────────────────
                          Text(
                            'Enter verification code',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ── Subtitle ────────────────
                          Text(
                            'We sent a 6-digit code to',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ── Phone pill ──────────────
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer.withValues(
                                  alpha: 0.45,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_iphone_rounded,
                                    size: 16,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.phoneNumber,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ── OTP boxes ──────────────
                          _OtpBoxes(
                            controllers: _controllers,
                            focusNodes: _focusNodes,
                            onChanged: _onDigitChanged,
                            onKey: _onKeyEvent,
                            isEnabled: !isLoading,
                          ),

                          const SizedBox(height: 20),

                          // ── Resend row ─────────────
                          Center(
                            child: _canResend
                                ? TextButton.icon(
                                    onPressed: isLoading ? null : _resendOtp,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Resend code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Resend in ${_remainingSeconds}s',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 28),

                          // ── Verify button ──────────
                          AppButton(
                            text: 'Verify & Continue',
                            onPressed: _otp.length == _otpLength && !isLoading
                                ? _verifyOtp
                                : null,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 16),

                          // ── Change number ──────────
                          Center(
                            child: TextButton.icon(
                              onPressed: isLoading ? null : () => context.pop(),
                              icon: const Icon(Icons.edit_outlined, size: 17),
                              label: const Text('Change phone number'),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.onSurfaceVariant,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CIRCLE BACK BUTTON
// ═══════════════════════════════════════════════════════════════
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OTP BOXES — six square input fields
// ═══════════════════════════════════════════════════════════════
class _OtpBoxes extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final void Function(int index, KeyEvent event) onKey;
  final bool isEnabled;

  const _OtpBoxes({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onKey,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(controllers.length, (i) {
        return _OtpBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onChanged: (v) => onChanged(i, v),
          onKey: (e) => onKey(i, e),
          isEnabled: isEnabled,
          isFirst: i == 0,
          isLast: i == controllers.length - 1,
          primaryColor: colors.primary,
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKey;
  final bool isEnabled;
  final bool isFirst;
  final bool isLast;
  final Color primaryColor;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
    required this.isEnabled,
    required this.isFirst,
    required this.isLast,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (e) {
          if (e is KeyDownEvent) onKey(e);
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: isEnabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          maxLength: 1,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
          ),
          onChanged: (v) {
            onChanged(v);
          },
        ),
      ),
    );
  }
}
