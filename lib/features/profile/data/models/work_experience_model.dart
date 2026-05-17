// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/work_experience.dart';

part 'work_experience_model.freezed.dart';
part 'work_experience_model.g.dart';

@freezed
class WorkExperienceModel with _$WorkExperienceModel {
  const factory WorkExperienceModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String company,
    required String role,
    @JsonKey(name: 'from_date') required String fromDate,
    @JsonKey(name: 'to_date') String? toDate,
    String? description,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
  }) = _WorkExperienceModel;

  factory WorkExperienceModel.fromJson(Map<String, dynamic> json) =>
      _$WorkExperienceModelFromJson(json);

  const WorkExperienceModel._();

  WorkExperience toEntity() => WorkExperience(
        id: id,
        userId: userId,
        company: company,
        role: role,
        fromDate: DateTime.parse(fromDate),
        toDate: toDate != null ? DateTime.parse(toDate!) : null,
        description: description,
        isCurrent: isCurrent,
      );
}
