import '../../../profile/domain/entities/user_skill.dart';
import '../../../recruiter/domain/entities/job_required_skill.dart';
import '../entities/skill_gap.dart';

/// Pure computation use case — compares Required Skills with User Skills.
/// No repository call; logic runs locally.
class GetSkillGapUseCase {
  const GetSkillGapUseCase();

  SkillGap call(
    List<JobRequiredSkill> requiredSkills,
    List<UserSkill> userSkills,
  ) {
    if (requiredSkills.isEmpty) return const SkillGap.empty();

    final userSkillIds =
        userSkills.map((s) => s.skillId).toSet();

    final owned = <OwnedSkillInfo>[];
    final missing = <MissingSkillInfo>[];

    for (final req in requiredSkills) {
      final matchingUserSkill = userSkills.firstWhere(
        (us) => us.skillId == req.skillId,
        orElse: () => const UserSkill(
          skillId: '',
          skillName: '',
          categoryId: '',
          level: '',
        ),
      );

      if (userSkillIds.contains(req.skillId) &&
          matchingUserSkill.skillId.isNotEmpty) {
        owned.add(
          OwnedSkillInfo(
            skillId: req.skillId,
            skillName: req.skillName ?? matchingUserSkill.skillName,
            level: matchingUserSkill.level,
          ),
        );
      } else {
        missing.add(
          MissingSkillInfo(
            skillId: req.skillId,
            skillName: req.skillName ?? '',
          ),
        );
      }
    }

    return SkillGap(
      totalCount: requiredSkills.length,
      ownedCount: owned.length,
      missingCount: missing.length,
      ownedSkills: owned,
      missingSkills: missing,
    );
  }
}
