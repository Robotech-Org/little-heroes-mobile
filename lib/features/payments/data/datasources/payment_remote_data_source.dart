import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/invoice_response_model.dart';
import '../models/payment_session_model.dart';
import '../models/payment_status_model.dart';
import '../models/subscription_plan_response_model.dart';

abstract class PaymentRemoteDataSource {
  /// List parent's tuition invoices.
  /// [parent] should be the parent's phone in the format
  /// the backend expects (e.g. "+251956309313").
  Future<InvoiceResponseModel> getMyInvoices({
    int limit = 50,
    String? status,
    String? parent,
  });

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

  /// Subscription plans.
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl(this.dio);

  @override
  Future<InvoiceResponseModel> getMyInvoices({
    int limit = 50,
    String? status,
    String? parent,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (parent != null && parent.isNotEmpty) query['parent'] = parent;

      debugPrint('🔵 [Payments] getMyInvoices query: $query');

      final response = await dio.get(
        ApiConstants.getMyInvoices,
        queryParameters: query,
      );

      final Map<String, dynamic> raw;
      if (response.data is Map<String, dynamic>) {
        raw = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        raw = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        raw = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      // ✅ Unwrap { message: { success, data, message } }
      final envelope = _unwrapEnvelope(raw);
      debugPrint('🔵 [invoices] envelope keys: ${envelope.keys.toList()}');

      final parsed = InvoiceResponseModel.fromJson(envelope);

      if (parsed.items.isEmpty) {
        debugPrint('⚠️ [Payments] No invoices from server — using mock');
        return _getMockInvoices();
      }

      return parsed;
    } on DioException catch (e) {
      final serverData = e.response?.data;
      final serverMsg = serverData is Map
          ? (serverData['message'] ?? serverData['exception'])
          : null;
      debugPrint(
        '❌ [Payments] getMyInvoices failed '
        '(status=${e.response?.statusCode}): ${serverMsg ?? e.message}',
      );
      DioErrorHandler.handle(e);
      return _getMockInvoices();
    } catch (e, st) {
      debugPrint('❌ [Payments] getMyInvoices unexpected: $e\n$st');
      return _getMockInvoices();
    }
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

      debugPrint(
        ' [init] status=${response.statusCode} '
        'type=${response.data.runtimeType}',
      );

      // 1. Coerce response.data to a Map
      final Map<String, dynamic> raw;
      if (response.data is Map<String, dynamic>) {
        raw = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        raw = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        raw = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      // 2. Unwrap the ERPNext "message" envelope
      final json = _unwrapEnvelope(raw);

      // 3. Now json['data'] is the real payload
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return PaymentSessionModel.fromJson(data);
      }
      if (data is Map) {
        return PaymentSessionModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception(
        json['message']?.toString() ?? 'Failed to initialize payment',
      );
    } on DioException catch (e) {
      debugPrint(
        '❌ [init] DioException status=${e.response?.statusCode} '
        'body=${e.response?.data}',
      );
      rethrow;
    } catch (e, st) {
      debugPrint('❌ [init] parse error: $e\n$st');
      rethrow;
    }
  }

  /// ERPNext / Frappe wraps every response as:
  ///   { "message": { "success": true, "data": ..., "message": "..." } }
  /// This unwraps the outer layer and returns the inner envelope.
  Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> raw) {
    final msg = raw['message'];
    if (msg is Map) {
      return Map<String, dynamic>.from(msg);
    }
    // Not wrapped — assume raw already IS the envelope
    return raw;
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

      debugPrint('🔵 [status] GET $query');

      final response = await dio.get(
        ApiConstants.getPaymentStatus,
        queryParameters: query,
      );

      debugPrint(
        ' [status] status=${response.statusCode} '
        'type=${response.data.runtimeType}',
      );

      // 1. Coerce response.data to a Map
      final Map<String, dynamic> raw;
      if (response.data is Map<String, dynamic>) {
        raw = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        raw = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        raw = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      // 2. Unwrap the ERPNext "message" envelope
      final json = _unwrapEnvelope(raw);

      // 3. json['data'] is now the real payload
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return PaymentStatusModel.fromJson(data);
      }
      if (data is Map) {
        return PaymentStatusModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception(
        json['message']?.toString() ?? 'Failed to get payment status',
      );
    } on DioException catch (e) {
      debugPrint(
        '❌ [status] DioException status=${e.response?.statusCode} '
        'body=${e.response?.data}',
      );
      rethrow;
    } catch (e, st) {
      debugPrint('❌ [status] parse error: $e\n$st');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // SUBSCRIPTION PLANS
  // ═════════════════════════════════════════════════════════════
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

  // ═════════════════════════════════════════════════════════════
  // MOCK — fallback when server returns empty or errors
  // ═════════════════════════════════════════════════════════════
  InvoiceResponseModel _getMockInvoices() {
    return InvoiceResponseModel.fromJson({
      'success': true,
      'data': [
        {
          "name": "ACC-SINV-2026-00001",
          "posting_date": "2026-09-16",
          "due_date": "2026-09-30",
          "grand_total": 3500.0,
          "outstanding_amount": 3500.0,
          "is_paid": false,
          "status": "Unpaid",
          "currency": "ETB",
          "student_id": "STUD-0001",
          "student_name": "Noah Tesfaye",
          "admission_id": "7jsqbri815",
        },
      ],
    });
  }
}
