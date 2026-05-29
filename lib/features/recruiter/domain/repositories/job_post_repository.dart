import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/create_job_post_input.dart';
import '../entities/job_post.dart';
import '../entities/job_location.dart';
import '../entities/job_required_skill.dart';
import '../entities/update_job_post_input.dart';

/// Aggregated job post data with location and skills.
class JobPostDetail {
  const JobPostDetail({
    required this.jobPost,
    required this.location,
    required this.skills,
  });

  final JobPost jobPost;
  final JobLocation location;
  final List<JobRequiredSkill> skills;
}

abstract class JobPostRepository {
  /// Create a new Job Post via atomic RPC call.
  /// Returns the new job post's UUID on success.
  Future<Either<Failure, String>> createJobPost(CreateJobPostInput input);

  /// Get all job posts for a company.
  Future<Either<Failure, List<JobPost>>> getMyJobPosts(String companyId);

  /// Get a single job post with location and skills.
  Future<Either<Failure, JobPostDetail>> getJobPostById(String jobId);

  /// Update an existing Job Post via atomic RPC call.
  Future<Either<Failure, void>> updateJobPost(UpdateJobPostInput input);

  /// Update job post status (publish, close, discard, resubmit).
  Future<Either<Failure, void>> updateJobPostStatus(String jobId, String newStatus);
}
