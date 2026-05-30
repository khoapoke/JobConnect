// ignore_for_file: sort_constructors_first

import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_content.dart';

class ResumeModel {
  const ResumeModel({
    required this.id,
    required this.userId,
    required this.title,
    this.contentJson,
    this.fileUrl,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic>? contentJson;
  final String? fileUrl;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      contentJson: json['content_json'] as Map<String, dynamic>?,
      fileUrl: json['file_url'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Resume toEntity() => Resume(
    id: id,
    userId: userId,
    title: title,
    content: contentJson == null
        ? null
        : ResumeContentModel.fromJson(contentJson!).toEntity(),
    fileUrl: fileUrl,
    isDefault: isDefault,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class ResumeContentModel {
  const ResumeContentModel({
    required this.fullName,
    required this.professionalTitle,
    required this.headline,
    required this.contactEmail,
    required this.location,
    required this.summary,
    required this.skills,
    required this.workExperiences,
    required this.educations,
    required this.certificates,
  });

  final String fullName;
  final String professionalTitle;
  final String headline;
  final String contactEmail;
  final String location;
  final String summary;
  final List<String> skills;
  final List<String> workExperiences;
  final List<String> educations;
  final List<String> certificates;

  factory ResumeContentModel.fromEntity(ResumeContent entity) {
    return ResumeContentModel(
      fullName: entity.fullName,
      professionalTitle: entity.professionalTitle,
      headline: entity.headline,
      contactEmail: entity.contactEmail,
      location: entity.location,
      summary: entity.summary,
      skills: entity.skills,
      workExperiences: entity.workExperiences,
      educations: entity.educations,
      certificates: entity.certificates,
    );
  }

  factory ResumeContentModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(String key) {
      final raw = json[key] as List<dynamic>? ?? <dynamic>[];
      return raw
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return ResumeContentModel(
      fullName: (json['full_name'] as String?) ?? '',
      professionalTitle: (json['professional_title'] as String?) ?? '',
      headline: (json['headline'] as String?) ?? '',
      contactEmail: (json['contact_email'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      skills: parseList('skills'),
      workExperiences: parseList('work_experiences'),
      educations: parseList('educations'),
      certificates: parseList('certificates'),
    );
  }

  ResumeContent toEntity() => ResumeContent(
    fullName: fullName,
    professionalTitle: professionalTitle,
    headline: headline,
    contactEmail: contactEmail,
    location: location,
    summary: summary,
    skills: skills,
    workExperiences: workExperiences,
    educations: educations,
    certificates: certificates,
  );

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'professional_title': professionalTitle,
    'headline': headline,
    'contact_email': contactEmail,
    'location': location,
    'summary': summary,
    'skills': skills,
    'work_experiences': workExperiences,
    'educations': educations,
    'certificates': certificates,
  };
}
