// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_skill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSkillModelImpl _$$UserSkillModelImplFromJson(Map<String, dynamic> json) =>
    _$UserSkillModelImpl(
      userId: json['user_id'] as String,
      skillId: json['skill_id'] as String,
      level: json['level'] as String,
      skills: json['skills'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$UserSkillModelImplToJson(
  _$UserSkillModelImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'skill_id': instance.skillId,
  'level': instance.level,
  'skills': instance.skills,
};
