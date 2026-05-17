// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'certificate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CertificateModel _$CertificateModelFromJson(Map<String, dynamic> json) {
  return _CertificateModel.fromJson(json);
}

/// @nodoc
mixin _$CertificateModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get issuer => throw _privateConstructorUsedError;
  @JsonKey(name: 'issued_at')
  String? get issuedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'credential_url')
  String? get credentialUrl => throw _privateConstructorUsedError;

  /// Serializes this CertificateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CertificateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificateModelCopyWith<CertificateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificateModelCopyWith<$Res> {
  factory $CertificateModelCopyWith(
    CertificateModel value,
    $Res Function(CertificateModel) then,
  ) = _$CertificateModelCopyWithImpl<$Res, CertificateModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    String? issuer,
    @JsonKey(name: 'issued_at') String? issuedAt,
    @JsonKey(name: 'credential_url') String? credentialUrl,
  });
}

/// @nodoc
class _$CertificateModelCopyWithImpl<$Res, $Val extends CertificateModel>
    implements $CertificateModelCopyWith<$Res> {
  _$CertificateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CertificateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? issuer = freezed,
    Object? issuedAt = freezed,
    Object? credentialUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            issuer: freezed == issuer
                ? _value.issuer
                : issuer // ignore: cast_nullable_to_non_nullable
                      as String?,
            issuedAt: freezed == issuedAt
                ? _value.issuedAt
                : issuedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            credentialUrl: freezed == credentialUrl
                ? _value.credentialUrl
                : credentialUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CertificateModelImplCopyWith<$Res>
    implements $CertificateModelCopyWith<$Res> {
  factory _$$CertificateModelImplCopyWith(
    _$CertificateModelImpl value,
    $Res Function(_$CertificateModelImpl) then,
  ) = __$$CertificateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    String? issuer,
    @JsonKey(name: 'issued_at') String? issuedAt,
    @JsonKey(name: 'credential_url') String? credentialUrl,
  });
}

/// @nodoc
class __$$CertificateModelImplCopyWithImpl<$Res>
    extends _$CertificateModelCopyWithImpl<$Res, _$CertificateModelImpl>
    implements _$$CertificateModelImplCopyWith<$Res> {
  __$$CertificateModelImplCopyWithImpl(
    _$CertificateModelImpl _value,
    $Res Function(_$CertificateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CertificateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? issuer = freezed,
    Object? issuedAt = freezed,
    Object? credentialUrl = freezed,
  }) {
    return _then(
      _$CertificateModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        issuer: freezed == issuer
            ? _value.issuer
            : issuer // ignore: cast_nullable_to_non_nullable
                  as String?,
        issuedAt: freezed == issuedAt
            ? _value.issuedAt
            : issuedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        credentialUrl: freezed == credentialUrl
            ? _value.credentialUrl
            : credentialUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificateModelImpl extends _CertificateModel {
  const _$CertificateModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.name,
    this.issuer,
    @JsonKey(name: 'issued_at') this.issuedAt,
    @JsonKey(name: 'credential_url') this.credentialUrl,
  }) : super._();

  factory _$CertificateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificateModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  final String? issuer;
  @override
  @JsonKey(name: 'issued_at')
  final String? issuedAt;
  @override
  @JsonKey(name: 'credential_url')
  final String? credentialUrl;

  @override
  String toString() {
    return 'CertificateModel(id: $id, userId: $userId, name: $name, issuer: $issuer, issuedAt: $issuedAt, credentialUrl: $credentialUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.issuedAt, issuedAt) ||
                other.issuedAt == issuedAt) &&
            (identical(other.credentialUrl, credentialUrl) ||
                other.credentialUrl == credentialUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    issuer,
    issuedAt,
    credentialUrl,
  );

  /// Create a copy of CertificateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificateModelImplCopyWith<_$CertificateModelImpl> get copyWith =>
      __$$CertificateModelImplCopyWithImpl<_$CertificateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificateModelImplToJson(this);
  }
}

abstract class _CertificateModel extends CertificateModel {
  const factory _CertificateModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String name,
    final String? issuer,
    @JsonKey(name: 'issued_at') final String? issuedAt,
    @JsonKey(name: 'credential_url') final String? credentialUrl,
  }) = _$CertificateModelImpl;
  const _CertificateModel._() : super._();

  factory _CertificateModel.fromJson(Map<String, dynamic> json) =
      _$CertificateModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  String? get issuer;
  @override
  @JsonKey(name: 'issued_at')
  String? get issuedAt;
  @override
  @JsonKey(name: 'credential_url')
  String? get credentialUrl;

  /// Create a copy of CertificateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificateModelImplCopyWith<_$CertificateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
