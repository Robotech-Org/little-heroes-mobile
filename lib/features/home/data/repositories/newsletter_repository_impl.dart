import '../../domain/repositories/newsletter_repository.dart';
import '../datasources/newsletter_remote_data_source.dart';
import '../models/newsletter_model.dart';
import '../models/newsletter_response_model.dart';

class NewsletterRepositoryImpl implements NewsletterRepository {
  final NewsletterRemoteDataSource remote;
  NewsletterRepositoryImpl({required this.remote});

  @override
  Future<NewsletterResponseModel> listNewsletters({
    int page = 1,
    int pageSize = 20,
  }) => remote.listNewsletters(page: page, pageSize: pageSize);

  @override
  Future<NewsletterModel> getNewsletter(String name) =>
      remote.getNewsletter(name);
}
