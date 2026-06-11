import 'package:flutter/foundation.dart';

/// Aggregated dashboard figures for a recruiter's home screen.
@immutable
class RecruiterStats {
  const RecruiterStats({
    required this.activePosts,
    required this.pendingApplications,
    required this.upcomingInterviews,
    required this.recentApplicants,
    required this.activeJobPosts,
  });

  final int activePosts;
  final int pendingApplications;
  final int upcomingInterviews;
  final List<RecentApplicant> recentApplicants;
  final List<ActiveJobPostSummary> activeJobPosts;

  static const empty = RecruiterStats(
    activePosts: 0,
    pendingApplications: 0,
    upcomingInterviews: 0,
    recentApplicants: [],
    activeJobPosts: [],
  );
}

@immutable
class RecentApplicant {
  const RecentApplicant({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    this.avatarUrl,
    this.createdAt,
    this.jobId,
  });

  final String id;
  final String fullName;
  final String jobTitle;
  final String? avatarUrl;
  final DateTime? createdAt;
  final String? jobId;
}

@immutable
class ActiveJobPostSummary {
  const ActiveJobPostSummary({
    required this.id,
    required this.title,
    required this.applicantCount,
  });

  final String id;
  final String title;
  final int applicantCount;
}
