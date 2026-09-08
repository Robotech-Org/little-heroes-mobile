// lib/features/payments/domain/repositories/payment_repository.dart
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/subscription_plan_response_model.dart'
    hide SubscriptionPlanResponseModel;

abstract class PaymentRepository {
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int pageSize = 20,
  });
}
