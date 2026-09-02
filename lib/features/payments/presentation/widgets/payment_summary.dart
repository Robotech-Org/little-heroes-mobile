import 'package:flutter/material.dart';

class PaymentSummary extends StatelessWidget {
  final double amount;
  final double fee;
  final double total;

  const PaymentSummary({
    super.key,
    required this.amount,
    required this.fee,
    required this.total,
  });

  Widget summaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          summaryRow('Amount', '${amount.toStringAsFixed(0)} ETB'),

          summaryRow('Fee', '${fee.toStringAsFixed(0)} ETB'),

          const Divider(),

          summaryRow('Total', '${total.toStringAsFixed(0)} ETB', isTotal: true),
        ],
      ),
    );
  }
}
