class PaymentStatusModel {
  final String paymentRequest;
  final String txRef;
  final String status; // Initiated | Paid | Failed
  final String paymentGateway;
  final double amount;
  final String currency;
  final String checkoutUrl;
  final String invoice;
  final double invoiceOutstanding;
  final String invoiceStatus;

  PaymentStatusModel({
    required this.paymentRequest,
    required this.txRef,
    required this.status,
    required this.paymentGateway,
    required this.amount,
    required this.currency,
    required this.checkoutUrl,
    required this.invoice,
    required this.invoiceOutstanding,
    required this.invoiceStatus,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'initiated';
  bool get isFailed => status.toLowerCase() == 'failed';

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      paymentRequest: json['payment_request']?.toString() ?? '',
      txRef: json['tx_ref']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Initiated',
      paymentGateway: json['payment_gateway']?.toString() ?? 'Chapa',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'ETB',
      checkoutUrl: json['checkout_url']?.toString() ?? '',
      invoice: json['invoice']?.toString() ?? '',
      invoiceOutstanding:
          (json['invoice_outstanding'] as num?)?.toDouble() ?? 0,
      invoiceStatus: json['invoice_status']?.toString() ?? 'Unpaid',
    );
  }
}
