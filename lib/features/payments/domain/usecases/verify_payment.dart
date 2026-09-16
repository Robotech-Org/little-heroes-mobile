import '../../data/models/payment_status_model.dart';
import '../repositories/payment_repository.dart';

class VerifyPayment {
  final PaymentRepository repository;
  VerifyPayment(this.repository);

  Future<PaymentStatusModel> call({String? txRef, String? invoiceName}) =>
      repository.getPaymentStatus(txRef: txRef, invoiceName: invoiceName);
}
