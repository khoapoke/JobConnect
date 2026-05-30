// ignore_for_file: sort_constructors_first

import '../../domain/entities/interview_schedule.dart';

class InterviewScheduleModel {
  const InterviewScheduleModel({
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

  factory InterviewScheduleModel.fromJson(Map<String, dynamic> json) {
    return InterviewScheduleModel(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      location: json['location'] as String?,
      note: json['note'] as String?,
      status: (json['status'] as String?) ?? 'scheduled',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  InterviewSchedule toEntity() => InterviewSchedule(
    id: id,
    applicationId: applicationId,
    scheduledAt: scheduledAt,
    location: location,
    note: note,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
