// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EducationModelImpl _$$EducationModelImplFromJson(Map<String, dynamic> json) =>
    _$EducationModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      school: json['school'] as String,
      fromDate: json['from_date'] as String,
      toDate: json['to_date'] as String?,
      degree: json['degree'] as String?,
      major: json['major'] as String?,
    );

Map<String, dynamic> _$$EducationModelImplToJson(
  _$EducationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'school': instance.school,
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'degree': instance.degree,
  'major': instance.major,
};
