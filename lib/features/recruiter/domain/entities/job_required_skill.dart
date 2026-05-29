/// Pure Dart entity for Job Required Skill.
/// No Freezed annotation — this is a domain entity, not a data model.
class JobRequiredSkill {
  const JobRequiredSkill({
    required this.jobId,
    required this.skillId,
    required this.isRequired,
    this.skillName,
  });

  final String jobId;
  final String skillId;
  final bool isRequired;
  
  /// Optional: populated when joining with skills table.
  final String? skillName;
}
