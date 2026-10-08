import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/payments/data/models/invoice_model.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_event.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_state.dart';

import 'chapa_webview_page.dart';
import 'payment_result_page.dart';

class PaymentPage extends StatefulWidget {
  final InvoiceModel invoice;

  const PaymentPage({super.key, required this.invoice});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentBloc>().add(StartPayment(widget.invoice.name));
    });
  }

  // ══════════════════════════════════════════════════
  // OPEN CHAPA IN-APP
  // ══════════════════════════════════════════════════
  Future<void> _openCheckout(String checkoutUrl, String txRef) async {
    // Wait a frame so the PaymentPage is fully mounted
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChapaWebViewPage(
          checkoutUrl: checkoutUrl,
          invoiceName: widget.invoice.name,
          // If your backend uses a specific path, put it here:
          // returnUrlPattern: 'payment/callback',
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // WebView said "success" → verify with backend
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentResultPage(txRef: txRef, invoiceName: widget.invoice.name),
        ),
      );
    } else if (result == false) {
      // User cancelled or closed
      SnackbarUtils.showError(context, 'Payment cancelled or incomplete.');
    }
  }

  // ══════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pay Tuition',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSessionReady) {
            _openCheckout(state.session.checkoutUrl, state.session.txRef);
          } else if (state is PaymentError) {
            SnackbarUtils.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceSummary(theme, colorScheme, isDark),
                const SizedBox(height: 20),
                _buildInstructions(theme, colorScheme, isDark),
                const SizedBox(height: 30),
                if (state is PaymentLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is PaymentError)
                  _buildRetry(theme, colorScheme),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceSummary(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
            colorScheme.primary.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount to pay',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.invoice.currency} '
            '${widget.invoice.outstandingAmount.toStringAsFixed(2)}',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          _kv(theme, colorScheme, 'Student', widget.invoice.studentName),
          _kv(theme, colorScheme, 'Invoice', widget.invoice.name),
          _kv(theme, colorScheme, 'Due', widget.invoice.dueDate),
        ],
      ),
    );
  }

  Widget _kv(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.security_rounded,
                size: 18,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Secure Checkout',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Complete your payment directly in the app. '
            'Choose from Telebirr, CBE, or debit card. '
            'You will be returned here automatically.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetry(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<PaymentBloc>().add(StartPayment(widget.invoice.name));
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
      ),
    );
  }
}
