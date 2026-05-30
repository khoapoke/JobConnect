import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/job_detail.dart';

/// Repository contract for seeker-side Job Post detail.
abstract class JobDetailRepository {
  /// Returns null when the active Job Post is unavailable or hidden by RLS.
  Future<Either<Failure, JobDetail?>> getActiveJobDetail(String jobPostId);
}
