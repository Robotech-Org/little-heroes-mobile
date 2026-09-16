// // lib/features/payments/data/repositories/payment_repository_impl.dart
// import '../../domain/repositories/payment_repository.dart';
// import '../datasources/payment_remote_data_source.dart';
// import '../models/subscription_plan_model.dart';
// import '../models/subscription_plan_response_model.dart' hide SubscriptionPlanResponseModel;

// class PaymentRepositoryImpl implements PaymentRepository {
//   final PaymentRemoteDataSource remoteDataSource;

//   PaymentRepositoryImpl({required this.remoteDataSource});

//   @override
//   Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     return await remoteDataSource.getSubscriptionPlans(
//       page: page,
//       pageSize: pageSize,
//     );
//   }
// }

import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/invoice_response_model.dart';
import '../models/payment_session_model.dart';
import '../models/payment_status_model.dart';
import '../models/subscription_plan_response_model.dart'
   ;

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<InvoiceResponseModel> getMyInvoices({
    int limit = 50,
    String? status,
  }) => remoteDataSource.getMyInvoices(limit: limit, status: status);

  @override
  Future<PaymentSessionModel> initializePayment({
    required String invoiceName,
    String gateway = 'Chapa',
    String? returnUrl,
    String? callbackUrl,
  }) => remoteDataSource.initializePayment(
    invoiceName: invoiceName,
    gateway: gateway,
    returnUrl: returnUrl,
    callbackUrl: callbackUrl,
  );

  @override
  Future<PaymentStatusModel> getPaymentStatus({
    String? txRef,
    String? invoiceName,
  }) =>
      remoteDataSource.getPaymentStatus(txRef: txRef, invoiceName: invoiceName);

  @override
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  }) => remoteDataSource.getSubscriptionPlans(page: page, pageSize: pageSize);
}
