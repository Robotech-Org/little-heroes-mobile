import '../../data/models/framework_domain_response_model.dart';

abstract class FrameworkDomainRepository {
  Future<FrameworkDomainResponseModel> getFrameworkDomains({
    int page = 1,
    int pageSize = 20,
  });
}
