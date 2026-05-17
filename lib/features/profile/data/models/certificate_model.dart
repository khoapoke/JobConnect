// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/certificate.dart';

part 'certificate_model.freezed.dart';
part 'certificate_model.g.dart';

@freezed
class CertificateModel with _$CertificateModel {
  const factory CertificateModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? issuer,
    @JsonKey(name: 'issued_at') String? issuedAt,
    @JsonKey(name: 'credential_url') String? credentialUrl,
  }) = _CertificateModel;

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      _$CertificateModelFromJson(json);

  const CertificateModel._();

  Certificate toEntity() => Certificate(
        id: id,
        userId: userId,
        name: name,
        issuer: issuer,
        issuedAt: issuedAt != null ? DateTime.parse(issuedAt!) : null,
        credentialUrl: credentialUrl,
      );
}
