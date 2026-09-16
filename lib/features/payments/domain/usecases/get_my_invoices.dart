import '../../data/models/invoice_response_model.dart';
import '../repositories/payment_repository.dart';

class GetMyInvoices {
  final PaymentRepository repository;
  GetMyInvoices(this.repository);

  Future<InvoiceResponseModel> call({int limit = 50, String? status}) =>
      repository.getMyInvoices(limit: limit, status: status);
}
