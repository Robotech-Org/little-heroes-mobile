// // lib/features/payments/data/datasources/payment_remote_data_source.dart
// import 'package:dio/dio.dart';

// import '../../../../core/constants/api_constants.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../models/subscription_plan_model.dart';
// import '../models/subscription_plan_response_model.dart'
//     hide SubscriptionPlanResponseModel;

// abstract class PaymentRemoteDataSource {
//   Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
//     int page = 1,
//     int pageSize = 20,
//   });
// }

// class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
//   final Dio dio;

//   PaymentRemoteDataSourceImpl(this.dio);

//   @override
//   Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     try {
//       final response = await dio.get(
//         ApiConstants.listSubscriptionPlans,
//         queryParameters: {'page': page, 'page_size': pageSize},
//       );

//       if (response.data is Map<String, dynamic>) {
//         return SubscriptionPlanResponseModel.fromJson(response.data);
//       }

//       throw Exception('Invalid response format');
//     } on DioException catch (e) {
//       DioErrorHandler.handle(e);
//       rethrow;
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
// }

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/invoice_response_model.dart';
import '../models/payment_session_model.dart';
import '../models/payment_status_model.dart';
import '../models/subscription_plan_response_model.dart';

abstract class PaymentRemoteDataSource {
  /// List parent's tuition invoices.
  Future<InvoiceResponseModel> getMyInvoices({int limit = 50, String? status});

  /// Initialize a Chapa checkout session.
  Future<PaymentSessionModel> initializePayment({
    required String invoiceName,
    String gateway = 'Chapa',
    String? returnUrl,
    String? callbackUrl,
  });

  /// Verify the current status of a payment.
  Future<PaymentStatusModel> getPaymentStatus({
    String? txRef,
    String? invoiceName,
  });

  /// Subscription plans (existing).
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl(this.dio);

  // @override
  // Future<InvoiceResponseModel> getMyInvoices({
  //   int limit = 50,
  //   String? status,
  // }) async {
  //   try {
  //     final query = <String, dynamic>{'limit': limit};
  //     if (status != null && status.isNotEmpty) query['status'] = status;

  //     final response = await dio.get(
  //       ApiConstants.getMyInvoices,
  //       queryParameters: query,
  //     );

  //     if (response.data is Map<String, dynamic>) {
  //       return InvoiceResponseModel.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     }
  //     throw Exception('Invalid response format');
  //   } on DioException catch (e) {
  //     DioErrorHandler.handle(e);
  //     rethrow;
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }

  @override
  Future<InvoiceResponseModel> getMyInvoices({
    int limit = 50,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (status != null && status.isNotEmpty) query['status'] = status;

      final response = await dio.get(
        ApiConstants.getMyInvoices,
        queryParameters: query,
      );

      if (response.data is Map<String, dynamic>) {
        final parsed = InvoiceResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        // If server returns nothing, fall back to mock so the UI has data.
        if (parsed.items.isEmpty) {
          return _getMockInvoices();
        }

        return parsed;
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      // On network/API error, also fall back to mock instead of crashing.
      return _getMockInvoices();
    } catch (e) {
      return _getMockInvoices();
    }
  }

  // ═════════════════════════════════════════════════════════════
  // MOCK INVOICES — used when the API returns empty or fails
  // ═════════════════════════════════════════════════════════════
  InvoiceResponseModel _getMockInvoices() {
    return InvoiceResponseModel.fromJson({
      'success': true,
      'data': [
        {
          'name': 'ACC-SINV-2026-00001',
          'posting_date': '2026-09-01',
          'due_date': '2026-09-06',
          'grand_total': 3500.0,
          'outstanding_amount': 3500.0,
          'is_paid': false,
          'status': 'Unpaid',
          'currency': 'ETB',
          'student_id': 'STU-00012',
          'student_name': 'Liya Tesfaye',
          'admission_id': 'ADM-2026-00001',
        },
        // Add more mock invoices below if you want richer testing.
        // {
        //   'name': 'ACC-SINV-2026-00002',
        //   'posting_date': '2026-08-01',
        //   'due_date': '2026-08-06',
        //   'grand_total': 3500.0,
        //   'outstanding_amount': 0.0,
        //   'is_paid': true,
        //   'status': 'Paid',
        //   'currency': 'ETB',
        //   'student_id': 'STU-00012',
        //   'student_name': 'Liya Tesfaye',
        //   'admission_id': 'ADM-2026-00001',
        // },
      ],
    });
  }

  @override
  Future<PaymentSessionModel> initializePayment({
    required String invoiceName,
    String gateway = 'Chapa',
    String? returnUrl,
    String? callbackUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'invoice_name': invoiceName,
        'gateway': gateway,
        if (returnUrl != null && returnUrl.isNotEmpty) 'return_url': returnUrl,
        if (callbackUrl != null && callbackUrl.isNotEmpty)
          'callback_url': callbackUrl,
      };

      final response = await dio.post(
        ApiConstants.initializePayment,
        data: body,
      );

      final json = response.data as Map<String, dynamic>;
      final data = json['data'];

      if (data is Map<String, dynamic>) {
        return PaymentSessionModel.fromJson(data);
      }
      throw Exception(
        json['message']?.toString() ?? 'Failed to initialize payment',
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<PaymentStatusModel> getPaymentStatus({
    String? txRef,
    String? invoiceName,
  }) async {
    try {
      if ((txRef == null || txRef.isEmpty) &&
          (invoiceName == null || invoiceName.isEmpty)) {
        throw Exception('Provide tx_ref or invoice_name');
      }

      final query = <String, dynamic>{};
      if (txRef != null && txRef.isNotEmpty) query['tx_ref'] = txRef;
      if (invoiceName != null && invoiceName.isNotEmpty) {
        query['invoice_name'] = invoiceName;
      }

      final response = await dio.get(
        ApiConstants.getPaymentStatus,
        queryParameters: query,
      );

      final json = response.data as Map<String, dynamic>;
      final data = json['data'];

      if (data is Map<String, dynamic>) {
        return PaymentStatusModel.fromJson(data);
      }
      throw Exception(
        json['message']?.toString() ?? 'Failed to get payment status',
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listSubscriptionPlans,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        return SubscriptionPlanResponseModel.fromJson(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
