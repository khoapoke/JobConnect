class Conversation {
  const Conversation({
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
    this.lastMessageContent,
    this.lastMessageCreatedAt,
    this.unreadCount = 0,
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
  final String? lastMessageContent;
  final DateTime? lastMessageCreatedAt;
  final int unreadCount;
}
