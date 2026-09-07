import '../datasources/framework_domain_remote_data_source.dart';
import '../../domain/repositories/framework_domain_repository.dart';
import '../models/framework_domain_response_model.dart';

class FrameworkDomainRepositoryImpl implements FrameworkDomainRepository {
  final FrameworkDomainRemoteDataSource remoteDataSource;

  FrameworkDomainRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FrameworkDomainResponseModel> getFrameworkDomains({
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getFrameworkDomains(page: page, pageSize: pageSize);
  }
}
