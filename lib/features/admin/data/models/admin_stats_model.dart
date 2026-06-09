// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/admin_stats.dart';

part 'admin_stats_model.freezed.dart';
part 'admin_stats_model.g.dart';

@freezed
class AdminStatsModel with _$AdminStatsModel {
  const factory AdminStatsModel({
    @JsonKey(name: 'total_seekers') required int totalSeekers,
    @JsonKey(name: 'total_recruiters') required int totalRecruiters,
    @JsonKey(name: 'total_active_posts') required int totalActivePosts,
    @JsonKey(name: 'total_applications') required int totalApplications,
    @JsonKey(name: 'applications_per_day')
    required List<DayCountModel> applicationsPerDay,
    @JsonKey(name: 'posts_by_category')
    required List<CategoryCountModel> postsByCategory,
  }) = _AdminStatsModel;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);

  const AdminStatsModel._();

  AdminStats toEntity() => AdminStats(
        totalSeekers: totalSeekers,
        totalRecruiters: totalRecruiters,
        totalActivePosts: totalActivePosts,
        totalApplications: totalApplications,
        applicationsPerDay:
            applicationsPerDay.map((e) => e.toEntity()).toList(),
        postsByCategory: postsByCategory.map((e) => e.toEntity()).toList(),
      );
}

@freezed
class DayCountModel with _$DayCountModel {
  const factory DayCountModel({
    required DateTime date,
    required int count,
  }) = _DayCountModel;

  factory DayCountModel.fromJson(Map<String, dynamic> json) =>
      _$DayCountModelFromJson(json);

  const DayCountModel._();

  DayCount toEntity() => DayCount(date: date, count: count);
}

@freezed
class CategoryCountModel with _$CategoryCountModel {
  const factory CategoryCountModel({
    required String category,
    required int count,
  }) = _CategoryCountModel;

  factory CategoryCountModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryCountModelFromJson(json);

  const CategoryCountModel._();

  CategoryCount toEntity() => CategoryCount(category: category, count: count);
}
