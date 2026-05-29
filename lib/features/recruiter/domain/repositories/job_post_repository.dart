import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/create_job_post_input.dart';

abstract class JobPostRepository {
  /// Create a new Job Post via atomic RPC call.
  /// Returns the new job post's UUID on success.
  Future<Either<Failure, String>> createJobPost(CreateJobPostInput input);
}
