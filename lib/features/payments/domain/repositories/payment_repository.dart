import '../../data/models/invoice_response_model.dart';
import '../../data/models/payment_session_model.dart';
import '../../data/models/payment_status_model.dart';
import '../../data/models/subscription_plan_response_model.dart';

abstract class PaymentRepository {
  /// [parent] is the parent's phone number, forwarded to the backend
  /// so it can filter invoices for the correct parent.
  Future<InvoiceResponseModel> getMyInvoices({
    int limit = 50,
    String? status,
    String? parent,
  });

  Future<PaymentSessionModel> initializePayment({
    required String invoiceName,
    String gateway = 'Chapa',
    String? returnUrl,
    String? callbackUrl,
  });

  Future<PaymentStatusModel> getPaymentStatus({
    String? txRef,
    String? invoiceName,
  });

  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  });
}