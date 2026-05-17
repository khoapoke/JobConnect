// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CertificateModelImpl _$$CertificateModelImplFromJson(
  Map<String, dynamic> json,
) => _$CertificateModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  issuer: json['issuer'] as String?,
  issuedAt: json['issued_at'] as String?,
  credentialUrl: json['credential_url'] as String?,
);

Map<String, dynamic> _$$CertificateModelImplToJson(
  _$CertificateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'issuer': instance.issuer,
  'issued_at': instance.issuedAt,
  'credential_url': instance.credentialUrl,
};
