class InterviewSchedule {
  const InterviewSchedule({
    required this.id,
    required this.applicationId,
    required this.scheduledAt,
    this.location,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String applicationId;
  final DateTime scheduledAt;
  final String? location;
  final String? note;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
