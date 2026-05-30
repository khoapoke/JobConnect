class ResumeContent {
  const ResumeContent({
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

  bool get isEmpty =>
      fullName.trim().isEmpty &&
      professionalTitle.trim().isEmpty &&
      headline.trim().isEmpty &&
      contactEmail.trim().isEmpty &&
      location.trim().isEmpty &&
      summary.trim().isEmpty &&
      skills.isEmpty &&
      workExperiences.isEmpty &&
      educations.isEmpty &&
      certificates.isEmpty;
}
