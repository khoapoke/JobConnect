// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_required_skill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobRequiredSkillModelImpl _$$JobRequiredSkillModelImplFromJson(
  Map<String, dynamic> json,
) => _$JobRequiredSkillModelImpl(
  jobId: json['job_id'] as String,
  skillId: json['skill_id'] as String,
  isRequired: json['is_required'] as bool,
  skillName: json['skill_name'] as String?,
);

Map<String, dynamic> _$$JobRequiredSkillModelImplToJson(
  _$JobRequiredSkillModelImpl instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'skill_id': instance.skillId,
  'is_required': instance.isRequired,
  'skill_name': instance.skillName,
};
