// lib/features/payments/data/repositories/payment_repository_impl.dart
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_plan_response_model.dart' hide SubscriptionPlanResponseModel;

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await remoteDataSource.getSubscriptionPlans(
      page: page,
      pageSize: pageSize,
    );
  }
}
