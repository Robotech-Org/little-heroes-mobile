import 'package:equatable/equatable.dart';

import '../../data/models/invoice_model.dart';
import '../../data/models/payment_session_model.dart';
import '../../data/models/payment_status_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class InvoicesLoaded extends PaymentState {
  final List<InvoiceModel> invoices;
  const InvoicesLoaded(this.invoices);
  @override
  List<Object?> get props => [invoices];
}

class PaymentSessionReady extends PaymentState {
  final PaymentSessionModel session;
  const PaymentSessionReady(this.session);
  @override
  List<Object?> get props => [session];
}

class PaymentStatusChecked extends PaymentState {
  final PaymentStatusModel status;
  const PaymentStatusChecked(this.status);
  @override
  List<Object?> get props => [status];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}
