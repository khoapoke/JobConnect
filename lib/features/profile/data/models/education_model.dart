// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/education.dart';

part 'education_model.freezed.dart';
part 'education_model.g.dart';

@freezed
class EducationModel with _$EducationModel {
  const factory EducationModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String school,
    @JsonKey(name: 'from_date') required String fromDate,
    @JsonKey(name: 'to_date') String? toDate,
    String? degree,
    String? major,
  }) = _EducationModel;

  factory EducationModel.fromJson(Map<String, dynamic> json) =>
      _$EducationModelFromJson(json);

  const EducationModel._();

  Education toEntity() => Education(
        id: id,
        userId: userId,
        school: school,
        fromDate: DateTime.parse(fromDate),
        toDate: toDate != null ? DateTime.parse(toDate!) : null,
        degree: degree,
        major: major,
      );
}
