// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminStatsModelImpl _$$AdminStatsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AdminStatsModelImpl(
  totalSeekers: (json['total_seekers'] as num).toInt(),
  totalRecruiters: (json['total_recruiters'] as num).toInt(),
  totalActivePosts: (json['total_active_posts'] as num).toInt(),
  totalApplications: (json['total_applications'] as num).toInt(),
  applicationsPerDay: (json['applications_per_day'] as List<dynamic>)
      .map((e) => DayCountModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  postsByCategory: (json['posts_by_category'] as List<dynamic>)
      .map((e) => CategoryCountModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AdminStatsModelImplToJson(
  _$AdminStatsModelImpl instance,
) => <String, dynamic>{
  'total_seekers': instance.totalSeekers,
  'total_recruiters': instance.totalRecruiters,
  'total_active_posts': instance.totalActivePosts,
  'total_applications': instance.totalApplications,
  'applications_per_day': instance.applicationsPerDay,
  'posts_by_category': instance.postsByCategory,
};

_$DayCountModelImpl _$$DayCountModelImplFromJson(Map<String, dynamic> json) =>
    _$DayCountModelImpl(
      date: DateTime.parse(json['date'] as String),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$DayCountModelImplToJson(_$DayCountModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'count': instance.count,
    };

_$CategoryCountModelImpl _$$CategoryCountModelImplFromJson(
  Map<String, dynamic> json,
) => _$CategoryCountModelImpl(
  category: json['category'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$CategoryCountModelImplToJson(
  _$CategoryCountModelImpl instance,
) => <String, dynamic>{'category': instance.category, 'count': instance.count};
