// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_experience_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkExperienceModelImpl _$$WorkExperienceModelImplFromJson(
  Map<String, dynamic> json,
) => _$WorkExperienceModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  company: json['company'] as String,
  role: json['role'] as String,
  fromDate: json['from_date'] as String,
  toDate: json['to_date'] as String?,
  description: json['description'] as String?,
  isCurrent: json['is_current'] as bool? ?? false,
);

Map<String, dynamic> _$$WorkExperienceModelImplToJson(
  _$WorkExperienceModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'company': instance.company,
  'role': instance.role,
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'description': instance.description,
  'is_current': instance.isCurrent,
};
