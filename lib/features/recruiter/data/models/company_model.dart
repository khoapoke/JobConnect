// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/company.dart';

part 'company_model.freezed.dart';
part 'company_model.g.dart';

@freezed
class CompanyModel with _$CompanyModel {
  const factory CompanyModel({
    required String id,
    @JsonKey(name: 'recruiter_id') required String recruiterId,
    required String name,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String? description,
    String? website,
    String? size,
    String? province,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CompanyModel;

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);
}

// Extension for model → entity conversion
extension CompanyModelX on CompanyModel {
  Company toEntity() => Company(
    id: id,
    recruiterId: recruiterId,
    name: name,
    logoUrl: logoUrl,
    description: description,
    website: website,
    size: size,
    province: province,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
