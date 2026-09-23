import '../../data/models/newsletter_model.dart';
import '../../data/models/newsletter_response_model.dart';

abstract class NewsletterRepository {
  Future<NewsletterResponseModel> listNewsletters({int page, int pageSize});
  Future<NewsletterModel> getNewsletter(String name);
}
