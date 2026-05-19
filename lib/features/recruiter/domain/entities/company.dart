/// Company entity for read operations.
class Company {
  const Company({
    required this.id,
    required this.recruiterId,
    required this.name,
    this.logoUrl,
    this.description,
    this.website,
    this.size,
    this.province,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String recruiterId;
  final String name;
  final String? logoUrl;      // relative Storage path
  final String? description;
  final String? website;
  final String? size;         // CompanySize.value string
  final String? province;     // VietnamProvinces entry
  final DateTime createdAt;
  final DateTime updatedAt;
}
