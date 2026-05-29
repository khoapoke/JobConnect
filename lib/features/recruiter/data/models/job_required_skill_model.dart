// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/job_required_skill.dart';

part 'job_required_skill_model.freezed.dart';
part 'job_required_skill_model.g.dart';

@freezed
class JobRequiredSkillModel with _$JobRequiredSkillModel {
  const factory JobRequiredSkillModel({
    @JsonKey(name: 'job_id') required String jobId,
    @JsonKey(name: 'skill_id') required String skillId,
    @JsonKey(name: 'is_required') required bool isRequired,
    @JsonKey(name: 'skill_name') String? skillName,
  }) = _JobRequiredSkillModel;

  factory JobRequiredSkillModel.fromJson(Map<String, dynamic> json) =>
      _$JobRequiredSkillModelFromJson(json);
}

extension JobRequiredSkillModelX on JobRequiredSkillModel {
  JobRequiredSkill toEntity() => JobRequiredSkill(
        jobId: jobId,
        skillId: skillId,
        isRequired: isRequired,
        skillName: skillName,
      );
}
