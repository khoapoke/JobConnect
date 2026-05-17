/// Work experience entry for a seeker's profile.
class WorkExperience {
  const WorkExperience({
    required this.id,
    required this.userId,
    required this.company,
    required this.role,
    required this.fromDate,
    this.toDate,
    this.description,
    this.isCurrent = false,
  });

  final String id;
  final String userId;
  final String company;
  final String role;
  final DateTime fromDate;
  final DateTime? toDate;
  final String? description;
  final bool isCurrent;
}
