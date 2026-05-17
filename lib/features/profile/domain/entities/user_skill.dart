/// A skill assigned to a user with a proficiency level.
class UserSkill {
  const UserSkill({
    required this.skillId,
    required this.skillName,
    required this.categoryId,
    required this.level,
  });

  final String skillId;
  final String skillName;
  final String categoryId;
  final String level; // 'beginner' | 'intermediate' | 'advanced'

  String get levelLabel => levelLabelFor(level);

  static String levelLabelFor(String level) => switch (level) {
        'beginner' => 'Cơ bản',
        'intermediate' => 'Trung bình',
        'advanced' => 'Nâng cao',
        _ => level,
      };
}
