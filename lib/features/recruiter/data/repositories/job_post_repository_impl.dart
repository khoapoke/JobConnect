import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../../domain/entities/job_post.dart';
import '../../domain/entities/update_job_post_input.dart';
import '../../domain/repositories/job_post_repository.dart';
import '../datasources/job_post_datasource.dart';
import '../models/job_post_model.dart';
import '../models/job_location_model.dart';
import '../models/job_required_skill_model.dart';

class JobPostRepositoryImpl implements JobPostRepository {
  const JobPostRepositoryImpl(this._datasource);

  final JobPostDatasource _datasource;

  @override
  Future<Either<Failure, String>> createJobPost(
    CreateJobPostInput input,
  ) async {
    return _datasource.createJobPost(input);
  }

  @override
  Future<Either<Failure, List<JobPost>>> getMyJobPosts(String companyId) async {
    final result = await _datasource.getMyJobPosts(companyId);
    return result.fold(
      (failure) => Left(failure),
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, JobPostDetail>> getJobPostById(String jobId) async {
    final result = await _datasource.getJobPostById(jobId);
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(JobPostDetail(
        jobPost: data.jobPost.toEntity(),
        location: data.location.toEntity(),
        skills: data.skills.map((s) => s.toEntity()).toList(),
      )),
    );
  }

  @override
  Future<Either<Failure, void>> updateJobPost(UpdateJobPostInput input) async {
    return _datasource.updateJobPost(input);
  }

  @override
  Future<Either<Failure, void>> updateJobPostStatus(
    String jobId,
    String newStatus,
  ) async {
    return _datasource.updateJobPostStatus(jobId, newStatus);
  }
}
