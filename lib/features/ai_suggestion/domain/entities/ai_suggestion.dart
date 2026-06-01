import '../../../jobs/domain/entities/job_search_result.dart';

/// AI Suggestion entity combining a Job Post with its Match Score.
/// Wraps [JobSearchResult] to avoid duplicating job data.
class AiSuggestion {
  const AiSuggestion({
    required this.id,
    required this.result,
    required this.matchScore,
    required this.cachedAt,
    this.reason,
  });

  final String id;
  final JobSearchResult result;

  /// Cosine similarity, 0.0–1.0.
  final double matchScore;

  final DateTime cachedAt;
  final String? reason;
}
