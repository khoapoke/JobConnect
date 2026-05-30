import 'interview_schedule.dart';

class Application {
  const Application({
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
  final InterviewSchedule? interviewSchedule;
  final String? jobPostStatus;

  bool get isJobPostClosed => jobPostStatus == 'closed';

  bool get canWithdraw => status == 'pending' && !isJobPostClosed;
  bool get canEditSubmission =>
      (status == 'pending' || status == 'withdrawn' || status == 'rejected') &&
      !isJobPostClosed;
  bool get isResubmittable =>
      (status == 'withdrawn' || status == 'rejected') && !isJobPostClosed;
}
