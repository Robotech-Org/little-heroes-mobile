class PaymentSessionModel {
  final String paymentRequest; // ACC-PRQ-...
  final String txRef; // LH-ACC-SINV-...-A1B2C3D4
  final String checkoutUrl; // Chapa hosted checkout URL
  final double amount;
  final String currency;
  final String invoice; // ACC-SINV-...
  final String gateway; // Chapa

  PaymentSessionModel({
    required this.paymentRequest,
    required this.txRef,
    required this.checkoutUrl,
    required this.amount,
    required this.currency,
    required this.invoice,
    required this.gateway,
  });

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) {
    return PaymentSessionModel(
      paymentRequest: json['payment_request']?.toString() ?? '',
      txRef: json['tx_ref']?.toString() ?? '',
      checkoutUrl: json['checkout_url']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'ETB',
      invoice: json['invoice']?.toString() ?? '',
      gateway: json['gateway']?.toString() ?? 'Chapa',
    );
  }
}
