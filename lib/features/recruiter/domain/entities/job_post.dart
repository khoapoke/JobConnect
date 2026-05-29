/// Pure Dart entity for Job Post.
/// No Freezed annotation — this is a domain entity, not a data model.
class JobPost {
  const JobPost({
    required this.id,
    required this.companyId,
    required this.title,
    this.description,
    this.requirements,
    required this.salaryMin,
    required this.salaryMax,
    required this.isSalaryVisible,
    required this.type,
    this.categoryId,
    required this.status,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String title;
  final String? description;
  final String? requirements;
  final int salaryMin;
  final int salaryMax;
  final bool isSalaryVisible;
  final String type;
  final String? categoryId;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether this job post is editable (not closed).
  bool get isEditable => status != 'closed';

  /// Whether this job post can be published (draft or rejected).
  bool get canPublish => status == 'draft' || status == 'rejected';

  /// Whether this job post can be closed (draft, active, or rejected).
  bool get canClose => status == 'draft' || status == 'active' || status == 'rejected';
}
