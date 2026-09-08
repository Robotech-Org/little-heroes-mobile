// lib/features/payments/data/datasources/payment_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_plan_response_model.dart' hide SubscriptionPlanResponseModel;

abstract class PaymentRemoteDataSource {
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl(this.dio);

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
