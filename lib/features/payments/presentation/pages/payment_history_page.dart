import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/payments/data/models/invoice_model.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_event.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_state.dart';

import 'payment_page.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  // ═════════════════════════════════════════════════════════════
  // Load invoices — reads the parent's phone from AuthBloc
  // ═════════════════════════════════════════════════════════════
  void _load() {
    final authState = context.read<AuthBloc>().state;
    String? phone;

    if (authState is AuthAuthenticated) {
      // Use whichever field your AuthUser exposes. Common names:
      //   authState.user.phoneNumber
      //   authState.user.username
      //   authState.user.phone
      phone = authState.user.phoneNumber;
      phone = _normalizePhone(phone);
    }

    debugPrint(
      '🔵 [PaymentHistoryPage] dispatching LoadInvoices(parent=$phone)',
    );
    context.read<PaymentBloc>().add(LoadInvoices(parent: phone));
  }

  /// Normalize "0956309313" / "251956309313" → "+251956309313"
  String? _normalizePhone(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var p = raw.trim().replaceAll(' ', '').replaceAll('-', '');
    if (p.startsWith('+')) return p;
    if (p.startsWith('0')) return '+251${p.substring(1)}';
    if (p.startsWith('251')) return '+$p';
    return p;
  }

  Future<void> _payInvoice(InvoiceModel invoice) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PaymentPage(invoice: invoice)),
    );

    if (result == true && mounted) {
      _load(); // refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tuition & Payments',
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load, // 👈 uses _load() so phone is included
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(), // 👈 same here
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PaymentError) {
              return _buildError(theme, colorScheme, state.message);
            }
            if (state is InvoicesLoaded) {
              if (state.invoices.isEmpty) {
                return _buildEmpty(theme, colorScheme);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                physics: const BouncingScrollPhysics(),
                itemCount: state.invoices.length,
                itemBuilder: (_, i) {
                  final invoice = state.invoices[i];
                  return _InvoiceCard(
                    invoice: invoice,
                    onPay: () => _payInvoice(invoice),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colorScheme, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load invoices',
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _load, // 👈 uses _load()
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No invoices',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your tuition invoices will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Invoice card
// ─────────────────────────────────────────────
class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onPay;

  const _InvoiceCard({required this.invoice, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPaid = invoice.isPaid;
    final isOverdue = invoice.status.toLowerCase() == 'overdue' && !isPaid;

    final statusColor = isPaid
        ? AppColors.success
        : isOverdue
        ? AppColors.error
        : AppColors.warning;
    final statusLabel = isPaid
        ? 'Paid'
        : isOverdue
        ? 'Overdue'
        : 'Unpaid';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? AppColors.success.withValues(alpha: 0.35)
              : isOverdue
              ? AppColors.error.withValues(alpha: 0.35)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.studentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Amount + due date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${invoice.currency} '
                      '${invoice.grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (!isPaid && invoice.outstandingAmount > 0)
                      Text(
                        'Outstanding: ${invoice.currency} '
                        '${invoice.outstandingAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Issued',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _fmtDate(invoice.postingDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _fmtDate(invoice.dueDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isOverdue ? AppColors.error : null,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (!isPaid) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: const Text(
                  'Pay Now',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso.replaceFirst(' ', 'T'));
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
