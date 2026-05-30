import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/bookmarked_job.dart';

/// Repository contract for Seeker Bookmarks.
abstract class BookmarkRepository {
  Future<Either<Failure, Set<String>>> getActiveBookmarkedJobIds(
    String seekerId,
  );

  Future<Either<Failure, List<BookmarkedJob>>> getBookmarkedJobs(
    String seekerId,
  );

  Future<Either<Failure, Unit>> addBookmark({
    required String seekerId,
    required String jobPostId,
  });

  Future<Either<Failure, Unit>> removeBookmark({
    required String seekerId,
    required String jobPostId,
  });
}

class Unit {
  const Unit();
}

const unit = Unit();
