// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobLocationModelImpl _$$JobLocationModelImplFromJson(
  Map<String, dynamic> json,
) => _$JobLocationModelImpl(
  id: json['id'] as String,
  jobId: json['job_id'] as String,
  province: json['province'] as String?,
  district: json['district'] as String?,
  address: json['address'] as String?,
  isRemote: json['is_remote'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$JobLocationModelImplToJson(
  _$JobLocationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'job_id': instance.jobId,
  'province': instance.province,
  'district': instance.district,
  'address': instance.address,
  'is_remote': instance.isRemote,
  'created_at': instance.createdAt.toIso8601String(),
};
