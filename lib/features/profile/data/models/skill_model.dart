// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/skill.dart';

part 'skill_model.freezed.dart';
part 'skill_model.g.dart';

@freezed
class SkillModel with _$SkillModel {
  const factory SkillModel({
    required String id,
    required String name,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'job_categories') required Map<String, dynamic> jobCategories,
  }) = _SkillModel;

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);

  const SkillModel._();

  Skill toEntity() => Skill(
        id: id,
        name: name,
        categoryId: categoryId,
        categoryName: (jobCategories['name'] as String?) ?? '',
      );
}
