// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:little_heroes_mobile/core/constants/app_colors.dart';
// import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
// import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_event.dart';
// import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_state.dart';

// class PaymentResultPage extends StatefulWidget {
//   final String txRef;
//   final String invoiceName;

//   const PaymentResultPage({
//     super.key,
//     required this.txRef,
//     required this.invoiceName,
//   });

//   @override
//   State<PaymentResultPage> createState() => _PaymentResultPageState();
// }

// class _PaymentResultPageState extends State<PaymentResultPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<PaymentBloc>().add(
//         CheckPaymentStatus(
//           txRef: widget.txRef,
//           invoiceName: widget.invoiceName,
//         ),
//       );
//     });
//   }

//   Future<void> _refresh() async {
//     context.read<PaymentBloc>().add(
//       CheckPaymentStatus(txRef: widget.txRef, invoiceName: widget.invoiceName),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Payment Result',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         backgroundColor: isDark
//             ? AppColors.darkSurface
//             : AppColors.lightSurface,
//         foregroundColor: isDark
//             ? AppColors.darkTextPrimary
//             : AppColors.lightTextPrimary,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _refresh,
//           ),
//         ],
//       ),
//       body: BlocBuilder<PaymentBloc, PaymentState>(
//         builder: (context, state) {
//           if (state is PaymentLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is PaymentStatusChecked) {
//             final s = state.status;
//             if (s.isPaid)
//               return _buildPaid(
//                 theme,
//                 colorScheme,
//                 isDark,
//                 s.amount,
//                 s.currency,
//               );
//             if (s.isPending) return _buildPending(theme, colorScheme);
//             return _buildFailed(theme, colorScheme);
//           }
//           if (state is PaymentError) {
//             return _buildError(theme, colorScheme, state.message);
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildPaid(
//     ThemeData theme,
//     ColorScheme colorScheme,
//     bool isDark,
//     double amount,
//     String currency,
//   ) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 96,
//               height: 96,
//               decoration: BoxDecoration(
//                 color: AppColors.success.withValues(alpha: 0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_rounded,
//                 size: 52,
//                 color: AppColors.success,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Payment Successful',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '$currency ${amount.toStringAsFixed(2)} has been received.',
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorScheme.primary,
//                   foregroundColor: colorScheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: const Text(
//                   'Back to Invoices',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPending(ThemeData theme, ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 96,
//               height: 96,
//               decoration: BoxDecoration(
//                 color: AppColors.warning.withValues(alpha: 0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.hourglass_bottom_rounded,
//                 size: 52,
//                 color: AppColors.warningDark,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Verifying Payment',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'We are checking with the payment gateway. '
//               'This usually takes a few seconds.',
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 24),
//             OutlinedButton.icon(
//               onPressed: _refresh,
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Refresh Status'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFailed(ThemeData theme, ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 96,
//               height: 96,
//               decoration: BoxDecoration(
//                 color: AppColors.error.withValues(alpha: 0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 size: 52,
//                 color: AppColors.error,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Payment Failed',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'The payment was not completed. '
//               'No money has been charged.',
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorScheme.primary,
//                   foregroundColor: colorScheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: const Text(
//                   'Try Again',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildError(ThemeData theme, ColorScheme colorScheme, String message) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               size: 64,
//               color: colorScheme.error,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Could not check status',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _refresh,
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_event.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_state.dart';

class PaymentResultPage extends StatefulWidget {
  final String txRef;
  final String invoiceName;

  const PaymentResultPage({
    super.key,
    required this.txRef,
    required this.invoiceName,
  });

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  // ── Polling config ──
  static const int _maxAttempts = 10;
  static const Duration _pollDelay = Duration(seconds: 3);
  static const Duration _pollTimeout = Duration(seconds: 30);

  // ── State ──
  Timer? _pollTimer;
  int _attempt = 0;
  bool _timedOut = false;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════
  // Polling logic
  // ══════════════════════════════════════════════════

  void _startPolling() {
    if (!mounted || _isPolling) return;
    _isPolling = true;
    _attempt = 0;
    _timedOut = false;
    _check();
  }

  void _check() {
    if (!mounted) return;

    if (_attempt >= _maxAttempts) {
      // Gave up after 30s — show "still pending" UI
      setState(() {
        _isPolling = false;
        _timedOut = true;
      });
      return;
    }

    _attempt++;
    context.read<PaymentBloc>().add(
      CheckPaymentStatus(txRef: widget.txRef, invoiceName: widget.invoiceName),
    );
  }

  void _scheduleNextCheck() {
    _pollTimer?.cancel();
    _pollTimer = Timer(_pollDelay, _check);
  }

  /// Manual refresh — resets the attempt counter and restarts polling.
  void _manualRefresh() {
    _pollTimer?.cancel();
    setState(() {
      _isPolling = true;
      _timedOut = false;
      _attempt = 0;
    });
    _check();
  }

  // ══════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      // Prevent back-swipe from abandoning a pending payment without confirmation
      canPop: !_isPolling,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExitWhilePending();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Payment Result',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          foregroundColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _manualRefresh,
            ),
          ],
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            // Terminal states → stop polling
            if (state is PaymentStatusChecked) {
              if (state.status.isPaid || state.status.isFailed) {
                _pollTimer?.cancel();
                setState(() {
                  _isPolling = false;
                  _timedOut = false;
                });
              } else if (state.status.isPending) {
                // Keep polling
                _scheduleNextCheck();
              }
            }

            // Error → keep polling (network hiccups are common)
            if (state is PaymentError) {
              _scheduleNextCheck();
            }
          },
          builder: (context, state) {
            // ── Terminal states first ──
            if (state is PaymentStatusChecked) {
              final s = state.status;
              if (s.isPaid) {
                return _buildPaid(
                  theme,
                  colorScheme,
                  isDark,
                  s.amount,
                  s.currency,
                );
              }
              if (s.isFailed) {
                return _buildFailed(theme, colorScheme);
              }
            }

            // ── Timed out ──
            if (_timedOut) {
              return _buildTimedOut(theme, colorScheme);
            }

            // ── Error, but still within polling window ──
            if (state is PaymentError) {
              return _buildSoftError(
                theme,
                colorScheme,
                state.message,
                _attempt,
                _maxAttempts,
              );
            }

            // ── Pending / loading ──
            return _buildPending(
              theme,
              colorScheme,
              attempt: _attempt,
              maxAttempts: _maxAttempts,
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // Confirm exit while polling
  // ══════════════════════════════════════════════════

  Future<void> _confirmExitWhilePending() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this page?'),
        content: const Text(
          'We are still verifying your payment. '
          'If you leave now, we will keep checking in the background. '
          'You can view the result later in your invoices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (leave == true && mounted) {
      _pollTimer?.cancel();
      Navigator.pop(context, false);
    }
  }

  // ══════════════════════════════════════════════════
  // PAID
  // ══════════════════════════════════════════════════

  Widget _buildPaid(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    double amount,
    String currency,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 52,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currency ${amount.toStringAsFixed(2)} has been received.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to Invoices',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // PENDING (with progress indicator)
  // ══════════════════════════════════════════════════

  Widget _buildPending(
    ThemeData theme,
    ColorScheme colorScheme, {
    required int attempt,
    required int maxAttempts,
  }) {
    final progress = (attempt / maxAttempts).clamp(0.0, 1.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.warningDark,
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_bottom_rounded,
                    size: 40,
                    color: AppColors.warningDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Verifying Payment',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We are checking with the payment gateway. '
              'This usually takes a few seconds.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Attempt counter — subtle, reassures the user
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Attempt $attempt of $maxAttempts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _manualRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh Now'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // TIMED OUT (30s elapsed, still pending)
  // ══════════════════════════════════════════════════

  Widget _buildTimedOut(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_rounded,
                size: 52,
                color: AppColors.warningDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Still Processing',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment is taking longer than usual to confirm. '
              'This can happen during peak hours. '
              'We will update your invoice as soon as it clears.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _manualRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Check Again',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Back to Invoices'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // FAILED
  // ══════════════════════════════════════════════════

  Widget _buildFailed(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 52,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Failed',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The payment was not completed. '
              'No money has been charged.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // SOFT ERROR (network hiccup during polling)
  // ══════════════════════════════════════════════════

  Widget _buildSoftError(
    ThemeData theme,
    ColorScheme colorScheme,
    String message,
    int attempt,
    int maxAttempts,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Checking connection…',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Retrying ($attempt of $maxAttempts)…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _manualRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Now'),
            ),
          ],
        ),
      ),
    );
  }
}
