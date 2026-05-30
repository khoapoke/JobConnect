import '../../../recruiter/domain/entities/company.dart';
import '../../../recruiter/domain/entities/job_location.dart';
import '../../../recruiter/domain/entities/job_post.dart';
import '../../../recruiter/domain/entities/job_required_skill.dart';

/// Seeker-facing full detail for an active Job Post.
class JobDetail {
  const JobDetail({
    required this.jobPost,
    required this.company,
    required this.location,
    required this.requiredSkills,
    this.categoryName,
  });

  final JobPost jobPost;
  final Company company;
  final JobLocation location;
  final List<JobRequiredSkill> requiredSkills;
  final String? categoryName;
}
