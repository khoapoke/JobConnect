// ignore_for_file: sort_constructors_first

import '../../domain/entities/conversation.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.seekerId,
    required this.recruiterId,
    required this.jobId,
    required this.createdAt,
    required this.jobTitle,
    this.companyName,
    this.companyLogoUrl,
    required this.seekerName,
    this.seekerHeadline,
    this.seekerAvatarUrl,
    required this.recruiterName,
    this.recruiterAvatarUrl,
  });

  final String id;
  final String seekerId;
  final String recruiterId;
  final String jobId;
  final DateTime createdAt;
  final String jobTitle;
  final String? companyName;
  final String? companyLogoUrl;
  final String seekerName;
  final String? seekerHeadline;
  final String? seekerAvatarUrl;
  final String recruiterName;
  final String? recruiterAvatarUrl;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final jobPost = json['job_posts'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final company = jobPost['companies'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final seekerProfile = json['seeker_profile'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final recruiterProfile = json['recruiter_profile'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ConversationModel(
      id: json['id'] as String,
      seekerId: json['seeker_id'] as String,
      recruiterId: json['recruiter_id'] as String,
      jobId: json['job_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      jobTitle: jobPost['title'] as String? ?? '',
      companyName: company['name'] as String?,
      companyLogoUrl: company['logo_url'] as String?,
      seekerName: seekerProfile['full_name'] as String? ?? '',
      seekerHeadline: seekerProfile['headline'] as String?,
      seekerAvatarUrl: seekerProfile['avatar_url'] as String?,
      recruiterName: recruiterProfile['full_name'] as String? ?? '',
      recruiterAvatarUrl: recruiterProfile['avatar_url'] as String?,
    );
  }

  Conversation toEntity({
    String? lastMessageContent,
    DateTime? lastMessageCreatedAt,
    int unreadCount = 0,
  }) =>
      Conversation(
        id: id,
        seekerId: seekerId,
        recruiterId: recruiterId,
        jobId: jobId,
        createdAt: createdAt,
        jobTitle: jobTitle,
        companyName: companyName,
        companyLogoUrl: companyLogoUrl,
        seekerName: seekerName,
        seekerHeadline: seekerHeadline,
        seekerAvatarUrl: seekerAvatarUrl,
        recruiterName: recruiterName,
        recruiterAvatarUrl: recruiterAvatarUrl,
        lastMessageContent: lastMessageContent,
        lastMessageCreatedAt: lastMessageCreatedAt,
        unreadCount: unreadCount,
      );
}
