import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/job_filter.dart';
import '../entities/job_search_result.dart';

/// Repository contract for seeker-side job search.
abstract class JobSearchRepository {
  /// Search active job posts with filters and pagination.
  ///
  /// [searchQuery] — ILIKE match on title, description, company name.
  /// [filter] — combined filter state (categories, provinces, types, salary, remote).
  /// [cursor] — ISO 8601 timestamp for cursor-based pagination (null = first page).
  /// [limit] — page size (default 20).
  Future<Either<Failure, List<JobSearchResult>>> searchJobs({
    String? searchQuery,
    required JobFilter filter,
    String? cursor,
    int limit,
  });
}
