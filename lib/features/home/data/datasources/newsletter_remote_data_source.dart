import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/newsletter_model.dart';
import '../models/newsletter_response_model.dart';

abstract class NewsletterRemoteDataSource {
  Future<NewsletterResponseModel> listNewsletters({int page, int pageSize});
  Future<NewsletterModel> getNewsletter(String name);
}

class NewsletterRemoteDataSourceImpl implements NewsletterRemoteDataSource {
  final Dio dio;
  NewsletterRemoteDataSourceImpl(this.dio);

  @override
  Future<NewsletterResponseModel> listNewsletters({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listNewsletters,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final raw = response.data;
      if (raw is Map) {
        return NewsletterResponseModel.fromJson(Map<String, dynamic>.from(raw));
      }
      throw const UnknownException('Unexpected response format');
    } on DioException catch (e) {
      throw _mapDio(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<NewsletterModel> getNewsletter(String name) async {
    try {
      final response = await dio.get(
        ApiConstants.getNewsletter,
        queryParameters: {'name': name},
      );

      final raw = response.data;
      if (raw is Map) {
        final json = Map<String, dynamic>.from(raw);
        final message = json['message'];
        final inner = message is Map
            ? Map<String, dynamic>.from(message)
            : json;
        final data = inner['data'];
        final body = data is Map ? Map<String, dynamic>.from(data) : inner;
        return NewsletterModel.fromJson(body);
      }
      throw const UnknownException('Unexpected response format');
    } on DioException catch (e) {
      throw _mapDio(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  AppException _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      msg = data['message']?.toString() ?? data['exception']?.toString();
    }
    if (status == 401 || status == 403) {
      return UnauthorizedException(msg ?? 'Not authorized');
    }
    if (status == 404) {
      return NotFoundException(msg ?? 'Newsletter not found');
    }
    return ServerException(msg ?? 'Server error ($status)');
  }
}
