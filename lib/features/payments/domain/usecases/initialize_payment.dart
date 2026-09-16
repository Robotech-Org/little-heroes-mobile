import '../../data/models/payment_session_model.dart';
import '../repositories/payment_repository.dart';

class InitializePayment {
  final PaymentRepository repository;
  InitializePayment(this.repository);

  Future<PaymentSessionModel> call({
    required String invoiceName,
    String gateway = 'Chapa',
    String? returnUrl,
    String? callbackUrl,
  }) => repository.initializePayment(
    invoiceName: invoiceName,
    gateway: gateway,
    returnUrl: returnUrl,
    callbackUrl: callbackUrl,
  );
}
