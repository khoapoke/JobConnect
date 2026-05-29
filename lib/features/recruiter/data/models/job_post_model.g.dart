// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobPostModelImpl _$$JobPostModelImplFromJson(Map<String, dynamic> json) =>
    _$JobPostModelImpl(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      requirements: json['requirements'] as String?,
      salaryMin: (json['salary_min'] as num).toInt(),
      salaryMax: (json['salary_max'] as num).toInt(),
      isSalaryVisible: json['is_salary_visible'] as bool,
      type: json['type'] as String,
      categoryId: json['category_id'] as String?,
      status: json['status'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$JobPostModelImplToJson(_$JobPostModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'title': instance.title,
      'description': instance.description,
      'requirements': instance.requirements,
      'salary_min': instance.salaryMin,
      'salary_max': instance.salaryMax,
      'is_salary_visible': instance.isSalaryVisible,
      'type': instance.type,
      'category_id': instance.categoryId,
      'status': instance.status,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
