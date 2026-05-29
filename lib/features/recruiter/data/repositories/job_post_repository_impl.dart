import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../../domain/repositories/job_post_repository.dart';
import '../datasources/job_post_datasource.dart';

class JobPostRepositoryImpl implements JobPostRepository {
  const JobPostRepositoryImpl(this._datasource);

  final JobPostDatasource _datasource;

  @override
  Future<Either<Failure, String>> createJobPost(
    CreateJobPostInput input,
  ) async {
    return _datasource.createJobPost(input);
  }
}
