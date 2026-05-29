/// Pure Dart input for updating a Job Post.
/// No Freezed annotation — this is a domain entity, not a data model.
class UpdateJobPostInput {
  const UpdateJobPostInput({
    required this.jobId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.salaryMin,
    required this.salaryMax,
    required this.isSalaryVisible,
    required this.type,
    this.categoryId,
    this.expiresAt,
    required this.province,
    this.district,
    this.address,
    required this.isRemote,
    required this.skillIds,
  });

  final String jobId;
  final String title;
  final String description;
  final String requirements;
  final int salaryMin;
  final int salaryMax;
  final bool isSalaryVisible;
  final String type;
  final String? categoryId;
  final DateTime? expiresAt;
  final String province;
  final String? district;
  final String? address;
  final bool isRemote;
  final List<String> skillIds;
}
