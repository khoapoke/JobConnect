// ignore_for_file: sort_constructors_first

import '../../domain/entities/application.dart';
import 'interview_schedule_model.dart';

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.seekerId,
    this.resumeUrl,
    this.coverLetter,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoUrl,
    this.interviewSchedule,
    this.jobPostStatus,
  });

  final String id;
  final String jobId;
  final String seekerId;
  final String? resumeUrl;
  final String? coverLetter;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String jobTitle;
  final String companyName;
  final String? companyLogoUrl;
  final InterviewScheduleModel? interviewSchedule;
  final String? jobPostStatus;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final jobPost =
        json['job_posts'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final company =
        jobPost['companies'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final schedules =
        json['interview_schedules'] as List<dynamic>? ?? <dynamic>[];
    final latestSchedule = schedules.isEmpty
        ? null
        : schedules.first as Map<String, dynamic>;

    return ApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      seekerId: json['seeker_id'] as String,
      resumeUrl: json['resume_url'] as String?,
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      jobTitle: (jobPost['title'] as String?) ?? '',
      companyName: (company['name'] as String?) ?? '',
      companyLogoUrl: company['logo_url'] as String?,
      interviewSchedule: latestSchedule == null
          ? null
          : InterviewScheduleModel.fromJson(latestSchedule),
      jobPostStatus: jobPost['status'] as String?,
    );
  }

  Application toEntity() => Application(
    id: id,
    jobId: jobId,
    seekerId: seekerId,
    resumeUrl: resumeUrl,
    coverLetter: coverLetter,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
    jobTitle: jobTitle,
    companyName: companyName,
    companyLogoUrl: companyLogoUrl,
    interviewSchedule: interviewSchedule?.toEntity(),
    jobPostStatus: jobPostStatus,
  );
}
