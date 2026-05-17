/// Education entry for a seeker's profile.
class Education {
  const Education({
    required this.id,
    required this.userId,
    required this.school,
    required this.fromDate,
    this.toDate,
    this.degree,
    this.major,
  });

  final String id;
  final String userId;
  final String school;
  final DateTime fromDate;
  final DateTime? toDate;
  final String? degree;
  final String? major;
}
