import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Load invoices for the authenticated parent.
class LoadInvoices extends PaymentEvent {
  final String? status;
  final String? parent;
  const LoadInvoices({this.status, this.parent});
  @override
  List<Object?> get props => [status, parent];
}

/// Initialize a checkout for a specific invoice.
class StartPayment extends PaymentEvent {
  final String invoiceName;
  const StartPayment(this.invoiceName);
  @override
  List<Object?> get props => [invoiceName];
}

/// Check whether a payment completed.
class CheckPaymentStatus extends PaymentEvent {
  final String? txRef;
  final String? invoiceName;
  const CheckPaymentStatus({this.txRef, this.invoiceName});
  @override
  List<Object?> get props => [txRef, invoiceName];
}
