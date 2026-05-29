// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_required_skill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JobRequiredSkillModel _$JobRequiredSkillModelFromJson(
  Map<String, dynamic> json,
) {
  return _JobRequiredSkillModel.fromJson(json);
}

/// @nodoc
mixin _$JobRequiredSkillModel {
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'skill_id')
  String get skillId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_required')
  bool get isRequired => throw _privateConstructorUsedError;
  @JsonKey(name: 'skill_name')
  String? get skillName => throw _privateConstructorUsedError;

  /// Serializes this JobRequiredSkillModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobRequiredSkillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobRequiredSkillModelCopyWith<JobRequiredSkillModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobRequiredSkillModelCopyWith<$Res> {
  factory $JobRequiredSkillModelCopyWith(
    JobRequiredSkillModel value,
    $Res Function(JobRequiredSkillModel) then,
  ) = _$JobRequiredSkillModelCopyWithImpl<$Res, JobRequiredSkillModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'job_id') String jobId,
    @JsonKey(name: 'skill_id') String skillId,
    @JsonKey(name: 'is_required') bool isRequired,
    @JsonKey(name: 'skill_name') String? skillName,
  });
}

/// @nodoc
class _$JobRequiredSkillModelCopyWithImpl<
  $Res,
  $Val extends JobRequiredSkillModel
>
    implements $JobRequiredSkillModelCopyWith<$Res> {
  _$JobRequiredSkillModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobRequiredSkillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? skillId = null,
    Object? isRequired = null,
    Object? skillName = freezed,
  }) {
    return _then(
      _value.copyWith(
            jobId: null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                      as String,
            skillId: null == skillId
                ? _value.skillId
                : skillId // ignore: cast_nullable_to_non_nullable
                      as String,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            skillName: freezed == skillName
                ? _value.skillName
                : skillName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobRequiredSkillModelImplCopyWith<$Res>
    implements $JobRequiredSkillModelCopyWith<$Res> {
  factory _$$JobRequiredSkillModelImplCopyWith(
    _$JobRequiredSkillModelImpl value,
    $Res Function(_$JobRequiredSkillModelImpl) then,
  ) = __$$JobRequiredSkillModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'job_id') String jobId,
    @JsonKey(name: 'skill_id') String skillId,
    @JsonKey(name: 'is_required') bool isRequired,
    @JsonKey(name: 'skill_name') String? skillName,
  });
}

/// @nodoc
class __$$JobRequiredSkillModelImplCopyWithImpl<$Res>
    extends
        _$JobRequiredSkillModelCopyWithImpl<$Res, _$JobRequiredSkillModelImpl>
    implements _$$JobRequiredSkillModelImplCopyWith<$Res> {
  __$$JobRequiredSkillModelImplCopyWithImpl(
    _$JobRequiredSkillModelImpl _value,
    $Res Function(_$JobRequiredSkillModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobRequiredSkillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? skillId = null,
    Object? isRequired = null,
    Object? skillName = freezed,
  }) {
    return _then(
      _$JobRequiredSkillModelImpl(
        jobId: null == jobId
            ? _value.jobId
            : jobId // ignore: cast_nullable_to_non_nullable
                  as String,
        skillId: null == skillId
            ? _value.skillId
            : skillId // ignore: cast_nullable_to_non_nullable
                  as String,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        skillName: freezed == skillName
            ? _value.skillName
            : skillName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobRequiredSkillModelImpl implements _JobRequiredSkillModel {
  const _$JobRequiredSkillModelImpl({
    @JsonKey(name: 'job_id') required this.jobId,
    @JsonKey(name: 'skill_id') required this.skillId,
    @JsonKey(name: 'is_required') required this.isRequired,
    @JsonKey(name: 'skill_name') this.skillName,
  });

  factory _$JobRequiredSkillModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobRequiredSkillModelImplFromJson(json);

  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  @JsonKey(name: 'skill_id')
  final String skillId;
  @override
  @JsonKey(name: 'is_required')
  final bool isRequired;
  @override
  @JsonKey(name: 'skill_name')
  final String? skillName;

  @override
  String toString() {
    return 'JobRequiredSkillModel(jobId: $jobId, skillId: $skillId, isRequired: $isRequired, skillName: $skillName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobRequiredSkillModelImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.skillId, skillId) || other.skillId == skillId) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.skillName, skillName) ||
                other.skillName == skillName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, jobId, skillId, isRequired, skillName);

  /// Create a copy of JobRequiredSkillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobRequiredSkillModelImplCopyWith<_$JobRequiredSkillModelImpl>
  get copyWith =>
      __$$JobRequiredSkillModelImplCopyWithImpl<_$JobRequiredSkillModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JobRequiredSkillModelImplToJson(this);
  }
}

abstract class _JobRequiredSkillModel implements JobRequiredSkillModel {
  const factory _JobRequiredSkillModel({
    @JsonKey(name: 'job_id') required final String jobId,
    @JsonKey(name: 'skill_id') required final String skillId,
    @JsonKey(name: 'is_required') required final bool isRequired,
    @JsonKey(name: 'skill_name') final String? skillName,
  }) = _$JobRequiredSkillModelImpl;

  factory _JobRequiredSkillModel.fromJson(Map<String, dynamic> json) =
      _$JobRequiredSkillModelImpl.fromJson;

  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  @JsonKey(name: 'skill_id')
  String get skillId;
  @override
  @JsonKey(name: 'is_required')
  bool get isRequired;
  @override
  @JsonKey(name: 'skill_name')
  String? get skillName;

  /// Create a copy of JobRequiredSkillModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobRequiredSkillModelImplCopyWith<_$JobRequiredSkillModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
