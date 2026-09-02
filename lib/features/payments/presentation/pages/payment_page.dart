import 'package:flutter/material.dart';

import '../widgets/payment_amount_card.dart';
import '../widgets/payment_button.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_summary.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double selectedAmount = 500;
  String selectedMethod = 'Telebirr';

  final List<double> amounts = [100, 250, 500, 1000, 2000];

  final List<String> paymentMethods = ['Telebirr', 'CBE Birr', 'Chapa'];

  void selectAmount(double amount) {
    setState(() {
      selectedAmount = amount;
    });
  }

  void selectPaymentMethod(String method) {
    setState(() {
      selectedMethod = method;
    });
  }

  void handlePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mock payment of '
          '${selectedAmount.toStringAsFixed(0)} ETB '
          'using $selectedMethod',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Amount',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Select the amount you want to pay',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.65),
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: amounts.map((amount) {
                  return PaymentAmountCard(
                    amount: amount,
                    isSelected: selectedAmount == amount,
                    onTap: () => selectAmount(amount),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              Text(
                'Payment Method',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Choose how you want to pay',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.65),
                ),
              ),

              const SizedBox(height: 16),

              ...paymentMethods.map(
                (method) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaymentMethodCard(
                    method: method,
                    isSelected: selectedMethod == method,
                    onTap: () => selectPaymentMethod(method),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              PaymentSummary(
                amount: selectedAmount,
                fee: 0,
                total: selectedAmount,
              ),

              const SizedBox(height: 24),

              PaymentButton(amount: selectedAmount, onPressed: handlePayment),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
