// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JobLocationModel _$JobLocationModelFromJson(Map<String, dynamic> json) {
  return _JobLocationModel.fromJson(json);
}

/// @nodoc
mixin _$JobLocationModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  String? get province => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_remote')
  bool get isRemote => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this JobLocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobLocationModelCopyWith<JobLocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobLocationModelCopyWith<$Res> {
  factory $JobLocationModelCopyWith(
    JobLocationModel value,
    $Res Function(JobLocationModel) then,
  ) = _$JobLocationModelCopyWithImpl<$Res, JobLocationModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'job_id') String jobId,
    String? province,
    String? district,
    String? address,
    @JsonKey(name: 'is_remote') bool isRemote,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$JobLocationModelCopyWithImpl<$Res, $Val extends JobLocationModel>
    implements $JobLocationModelCopyWith<$Res> {
  _$JobLocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? province = freezed,
    Object? district = freezed,
    Object? address = freezed,
    Object? isRemote = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            jobId: null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                      as String,
            province: freezed == province
                ? _value.province
                : province // ignore: cast_nullable_to_non_nullable
                      as String?,
            district: freezed == district
                ? _value.district
                : district // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRemote: null == isRemote
                ? _value.isRemote
                : isRemote // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobLocationModelImplCopyWith<$Res>
    implements $JobLocationModelCopyWith<$Res> {
  factory _$$JobLocationModelImplCopyWith(
    _$JobLocationModelImpl value,
    $Res Function(_$JobLocationModelImpl) then,
  ) = __$$JobLocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'job_id') String jobId,
    String? province,
    String? district,
    String? address,
    @JsonKey(name: 'is_remote') bool isRemote,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$JobLocationModelImplCopyWithImpl<$Res>
    extends _$JobLocationModelCopyWithImpl<$Res, _$JobLocationModelImpl>
    implements _$$JobLocationModelImplCopyWith<$Res> {
  __$$JobLocationModelImplCopyWithImpl(
    _$JobLocationModelImpl _value,
    $Res Function(_$JobLocationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? province = freezed,
    Object? district = freezed,
    Object? address = freezed,
    Object? isRemote = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$JobLocationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        jobId: null == jobId
            ? _value.jobId
            : jobId // ignore: cast_nullable_to_non_nullable
                  as String,
        province: freezed == province
            ? _value.province
            : province // ignore: cast_nullable_to_non_nullable
                  as String?,
        district: freezed == district
            ? _value.district
            : district // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRemote: null == isRemote
            ? _value.isRemote
            : isRemote // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobLocationModelImpl implements _JobLocationModel {
  const _$JobLocationModelImpl({
    required this.id,
    @JsonKey(name: 'job_id') required this.jobId,
    this.province,
    this.district,
    this.address,
    @JsonKey(name: 'is_remote') required this.isRemote,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$JobLocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobLocationModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  final String? province;
  @override
  final String? district;
  @override
  final String? address;
  @override
  @JsonKey(name: 'is_remote')
  final bool isRemote;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'JobLocationModel(id: $id, jobId: $jobId, province: $province, district: $district, address: $address, isRemote: $isRemote, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobLocationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.isRemote, isRemote) ||
                other.isRemote == isRemote) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    jobId,
    province,
    district,
    address,
    isRemote,
    createdAt,
  );

  /// Create a copy of JobLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobLocationModelImplCopyWith<_$JobLocationModelImpl> get copyWith =>
      __$$JobLocationModelImplCopyWithImpl<_$JobLocationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JobLocationModelImplToJson(this);
  }
}

abstract class _JobLocationModel implements JobLocationModel {
  const factory _JobLocationModel({
    required final String id,
    @JsonKey(name: 'job_id') required final String jobId,
    final String? province,
    final String? district,
    final String? address,
    @JsonKey(name: 'is_remote') required final bool isRemote,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$JobLocationModelImpl;

  factory _JobLocationModel.fromJson(Map<String, dynamic> json) =
      _$JobLocationModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  String? get province;
  @override
  String? get district;
  @override
  String? get address;
  @override
  @JsonKey(name: 'is_remote')
  bool get isRemote;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of JobLocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobLocationModelImplCopyWith<_$JobLocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
