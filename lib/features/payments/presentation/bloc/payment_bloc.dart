import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_invoices.dart';
import '../../domain/usecases/initialize_payment.dart';
import '../../domain/usecases/verify_payment.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetMyInvoices getMyInvoices;
  final InitializePayment initializePayment;
  final VerifyPayment verifyPayment;

  PaymentBloc({
    required this.getMyInvoices,
    required this.initializePayment,
    required this.verifyPayment,
  }) : super(PaymentInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<StartPayment>(_onStartPayment);
    on<CheckPaymentStatus>(_onCheckStatus);
  }
  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final response = await getMyInvoices(
        status: event.status,
        parent: event.parent,
      );
      emit(InvoicesLoaded(response.items));
    } catch (e) {
      emit(PaymentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onStartPayment(
    StartPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final session = await initializePayment(invoiceName: event.invoiceName);
      emit(PaymentSessionReady(session));
    } catch (e) {
      emit(PaymentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCheckStatus(
    CheckPaymentStatus event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final status = await verifyPayment(
        txRef: event.txRef,
        invoiceName: event.invoiceName,
      );
      emit(PaymentStatusChecked(status));
    } catch (e) {
      emit(PaymentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
