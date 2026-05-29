// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/job_post.dart';

part 'job_post_model.freezed.dart';
part 'job_post_model.g.dart';

@freezed
class JobPostModel with _$JobPostModel {
  const factory JobPostModel({
    required String id,
    @JsonKey(name: 'company_id') required String companyId,
    required String title,
    String? description,
    String? requirements,
    @JsonKey(name: 'salary_min') required int salaryMin,
    @JsonKey(name: 'salary_max') required int salaryMax,
    @JsonKey(name: 'is_salary_visible') required bool isSalaryVisible,
    required String type,
    @JsonKey(name: 'category_id') String? categoryId,
    required String status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _JobPostModel;

  factory JobPostModel.fromJson(Map<String, dynamic> json) =>
      _$JobPostModelFromJson(json);
}

extension JobPostModelX on JobPostModel {
  JobPost toEntity() => JobPost(
        id: id,
        companyId: companyId,
        title: title,
        description: description,
        requirements: requirements,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        isSalaryVisible: isSalaryVisible,
        type: type,
        categoryId: categoryId,
        status: status,
        expiresAt: expiresAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
