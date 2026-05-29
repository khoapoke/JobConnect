// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/job_location.dart';

part 'job_location_model.freezed.dart';
part 'job_location_model.g.dart';

@freezed
class JobLocationModel with _$JobLocationModel {
  const factory JobLocationModel({
    required String id,
    @JsonKey(name: 'job_id') required String jobId,
    String? province,
    String? district,
    String? address,
    @JsonKey(name: 'is_remote') required bool isRemote,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _JobLocationModel;

  factory JobLocationModel.fromJson(Map<String, dynamic> json) =>
      _$JobLocationModelFromJson(json);
}

extension JobLocationModelX on JobLocationModel {
  JobLocation toEntity() => JobLocation(
        id: id,
        jobId: jobId,
        province: province,
        district: district,
        address: address,
        isRemote: isRemote,
        createdAt: createdAt,
      );
}
