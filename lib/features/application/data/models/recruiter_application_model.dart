// ignore_for_file: sort_constructors_first

import '../../domain/entities/recruiter_application.dart';
import 'interview_schedule_model.dart';

class RecruiterApplicationModel {
  const RecruiterApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.seekerId,
    required this.seekerName,
    this.seekerHeadline,
    this.seekerAvatarUrl,
    this.resumeUrl,
    this.coverLetter,
    required this.status,
    required this.createdAt,
    this.internalNote,
    this.interviewSchedule,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String seekerId;
  final String seekerName;
  final String? seekerHeadline;
  final String? seekerAvatarUrl;
  final String? resumeUrl;
  final String? coverLetter;
  final String status;
  final DateTime createdAt;
  final String? internalNote;
  final InterviewScheduleModel? interviewSchedule;

  factory RecruiterApplicationModel.fromJson(Map<String, dynamic> json) {
    final seeker =
        json['profiles'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final jobPost =
        json['job_posts'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final notes = json['application_notes'] as List<dynamic>? ?? <dynamic>[];
    final schedules =
        json['interview_schedules'] as List<dynamic>? ?? <dynamic>[];
    final latestNote = notes.isEmpty
        ? null
        : notes.first as Map<String, dynamic>;
    final latestSchedule = schedules.isEmpty
        ? null
        : schedules.first as Map<String, dynamic>;

    return RecruiterApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      jobTitle: (jobPost['title'] as String?) ?? '',
      seekerId: json['seeker_id'] as String,
      seekerName: (seeker['full_name'] as String?) ?? '',
      seekerHeadline: seeker['headline'] as String?,
      seekerAvatarUrl: seeker['avatar_url'] as String?,
      resumeUrl: json['resume_url'] as String?,
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      internalNote: latestNote?['note'] as String?,
      interviewSchedule: latestSchedule == null
          ? null
          : InterviewScheduleModel.fromJson(latestSchedule),
    );
  }

  RecruiterApplication toEntity() => RecruiterApplication(
    id: id,
    jobId: jobId,
    jobTitle: jobTitle,
    seekerId: seekerId,
    seekerName: seekerName,
    seekerHeadline: seekerHeadline,
    seekerAvatarUrl: seekerAvatarUrl,
    resumeUrl: resumeUrl,
    coverLetter: coverLetter,
    status: status,
    createdAt: createdAt,
    internalNote: internalNote,
    interviewSchedule: interviewSchedule?.toEntity(),
  );
}
