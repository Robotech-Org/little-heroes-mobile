// lib/features/home/data/repositories/moment_repository_impl.dart
import '../../domain/repositories/moment_repository.dart';
import '../datasources/moment_remote_data_source.dart';
import '../models/moment_model.dart';
import '../models/moment_response_model.dart';

class MomentRepositoryImpl implements MomentRepository {
  final MomentRemoteDataSource remoteDataSource;

  MomentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MomentResponseModel> getMoments({
    int page = 1,
    int pageSize = 20,
    Map<String, String>? filters,
  }) async {
    return await remoteDataSource.getMoments(
      page: page,
      pageSize: pageSize,
      filters: filters,
    );
  }

  @override
  Future<MomentModel> getMoment(String momentName) async {
    return await remoteDataSource.getMoment(momentName);
  }

  @override
  Future<MomentModel> createMoment(Map<String, dynamic> data) async {
    return await remoteDataSource.createMoment(data);
  }

  @override
  Future<MomentModel> updateMoment({
    required String momentName,
    required Map<String, dynamic> data,
  }) async {
    return await remoteDataSource.updateMoment(
      momentName: momentName,
      data: data,
    );
  }

  @override
  Future<void> deleteMoment(String momentName) async {
    await remoteDataSource.deleteMoment(momentName);
  }

  @override
  Future<void> approveMoment(String momentName) async {
    await remoteDataSource.approveMoment(momentName);
  }

  @override
  Future<void> denyMoment(String momentName) async {
    await remoteDataSource.denyMoment(momentName);
  }

  @override
  Future<String> uploadMomentFile({
    required String fileName,
    required String filePath,
  }) async {
    return await remoteDataSource.uploadMomentFile(
      fileName: fileName,
      filePath: filePath,
    );
  }
}
