import 'job_search_result.dart';

/// Bookmark row for the Bookmarks page.
///
/// [result] is null when the bookmarked Job Post is no longer readable for the
/// Seeker (closed/deleted/RLS-blocked). The Bookmark row itself is kept so the
/// Seeker can remove it manually.
class BookmarkedJob {
  const BookmarkedJob({
    required this.bookmarkId,
    required this.jobPostId,
    required this.createdAt,
    required this.result,
  });

  final String bookmarkId;
  final String jobPostId;
  final DateTime createdAt;
  final JobSearchResult? result;
}
