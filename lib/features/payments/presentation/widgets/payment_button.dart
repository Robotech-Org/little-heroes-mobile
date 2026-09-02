import 'package:flutter/material.dart';

class PaymentButton extends StatelessWidget {
  final double amount;
  final VoidCallback onPressed;

  const PaymentButton({
    super.key,
    required this.amount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Pay ${amount.toStringAsFixed(0)} ETB',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
