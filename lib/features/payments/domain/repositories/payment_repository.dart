// // lib/features/payments/domain/repositories/payment_repository.dart
// import '../../data/models/subscription_plan_model.dart';
// import '../../data/models/subscription_plan_response_model.dart'
//     hide SubscriptionPlanResponseModel;

// abstract class PaymentRepository {
//   Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
//     int page = 1,
//     int pageSize = 20,
//   });
// }

import '../../data/models/invoice_response_model.dart';
import '../../data/models/payment_session_model.dart';
import '../../data/models/payment_status_model.dart';
import '../../data/models/subscription_plan_response_model.dart'
   ;

abstract class PaymentRepository {
  Future<InvoiceResponseModel> getMyInvoices({int limit = 50, String? status});

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
