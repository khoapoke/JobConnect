import '../../../recruiter/domain/entities/company.dart';
import '../../../recruiter/domain/entities/job_location.dart';
import '../../../recruiter/domain/entities/job_post.dart';
import '../../../recruiter/domain/entities/job_required_skill.dart';

/// Aggregated job search result combining JobPost with related data.
/// Used for displaying jobs in the search list view.
class JobSearchResult {
  const JobSearchResult({
    required this.jobPost,
    required this.company,
    required this.location,
    required this.skills,
    this.categoryName,
  });

  final JobPost jobPost;
  final Company company;
  final JobLocation location;
  final List<JobRequiredSkill> skills;
  final String? categoryName;
}
