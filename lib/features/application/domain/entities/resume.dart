import 'resume_content.dart';

class Resume {
  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    this.fileUrl,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final ResumeContent? content;
  final String? fileUrl;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBuilderResume => content != null;
}
