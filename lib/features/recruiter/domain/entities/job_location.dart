/// Pure Dart entity for Job Location.
/// No Freezed annotation — this is a domain entity, not a data model.
class JobLocation {
  const JobLocation({
    required this.id,
    required this.jobId,
    this.province,
    this.district,
    this.address,
    required this.isRemote,
    required this.createdAt,
  });

  final String id;
  final String jobId;
  final String? province;
  final String? district;
  final String? address;
  final bool isRemote;
  final DateTime createdAt;
}
