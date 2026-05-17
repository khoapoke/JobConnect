// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_skill.dart';

part 'user_skill_model.freezed.dart';
part 'user_skill_model.g.dart';

@freezed
class UserSkillModel with _$UserSkillModel {
  const factory UserSkillModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'skill_id') required String skillId,
    required String level,
    required Map<String, dynamic> skills,
  }) = _UserSkillModel;

  factory UserSkillModel.fromJson(Map<String, dynamic> json) =>
      _$UserSkillModelFromJson(json);

  const UserSkillModel._();

  UserSkill toEntity() => UserSkill(
        skillId: skillId,
        skillName: (skills['name'] as String?) ?? '',
        categoryId: (skills['category_id'] as String?) ?? '',
        level: level,
      );
}
