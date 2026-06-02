/// Analysis result comparing a Job Post's Required Skills against a Seeker's User Skills.
class SkillGap {
  const SkillGap({
    required this.totalCount,
    required this.ownedCount,
    required this.missingCount,
    required this.ownedSkills,
    required this.missingSkills,
  });

  const SkillGap.empty()
      : totalCount = 0,
        ownedCount = 0,
        missingCount = 0,
        ownedSkills = const [],
        missingSkills = const [];

  final int totalCount;
  final int ownedCount;
  final int missingCount;
  final List<OwnedSkillInfo> ownedSkills;
  final List<MissingSkillInfo> missingSkills;

  double get completionRatio => totalCount == 0 ? 1.0 : ownedCount / totalCount;
}

/// A Required Skill that the Seeker already possesses.
class OwnedSkillInfo {
  const OwnedSkillInfo({
    required this.skillId,
    required this.skillName,
    required this.level,
  });

  final String skillId;
  final String skillName;
  final String level;
}

/// A Required Skill that the Seeker does not yet have.
class MissingSkillInfo {
  const MissingSkillInfo({
    required this.skillId,
    required this.skillName,
  });

  final String skillId;
  final String skillName;
}
