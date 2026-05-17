// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_experience_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkExperienceModel _$WorkExperienceModelFromJson(Map<String, dynamic> json) {
  return _WorkExperienceModel.fromJson(json);
}

/// @nodoc
mixin _$WorkExperienceModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get company => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_date')
  String get fromDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_date')
  String? get toDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_current')
  bool get isCurrent => throw _privateConstructorUsedError;

  /// Serializes this WorkExperienceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkExperienceModelCopyWith<WorkExperienceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkExperienceModelCopyWith<$Res> {
  factory $WorkExperienceModelCopyWith(
    WorkExperienceModel value,
    $Res Function(WorkExperienceModel) then,
  ) = _$WorkExperienceModelCopyWithImpl<$Res, WorkExperienceModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String company,
    String role,
    @JsonKey(name: 'from_date') String fromDate,
    @JsonKey(name: 'to_date') String? toDate,
    String? description,
    @JsonKey(name: 'is_current') bool isCurrent,
  });
}

/// @nodoc
class _$WorkExperienceModelCopyWithImpl<$Res, $Val extends WorkExperienceModel>
    implements $WorkExperienceModelCopyWith<$Res> {
  _$WorkExperienceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? company = null,
    Object? role = null,
    Object? fromDate = null,
    Object? toDate = freezed,
    Object? description = freezed,
    Object? isCurrent = null,
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
            company: null == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            fromDate: null == fromDate
                ? _value.fromDate
                : fromDate // ignore: cast_nullable_to_non_nullable
                      as String,
            toDate: freezed == toDate
                ? _value.toDate
                : toDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCurrent: null == isCurrent
                ? _value.isCurrent
                : isCurrent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkExperienceModelImplCopyWith<$Res>
    implements $WorkExperienceModelCopyWith<$Res> {
  factory _$$WorkExperienceModelImplCopyWith(
    _$WorkExperienceModelImpl value,
    $Res Function(_$WorkExperienceModelImpl) then,
  ) = __$$WorkExperienceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String company,
    String role,
    @JsonKey(name: 'from_date') String fromDate,
    @JsonKey(name: 'to_date') String? toDate,
    String? description,
    @JsonKey(name: 'is_current') bool isCurrent,
  });
}

/// @nodoc
class __$$WorkExperienceModelImplCopyWithImpl<$Res>
    extends _$WorkExperienceModelCopyWithImpl<$Res, _$WorkExperienceModelImpl>
    implements _$$WorkExperienceModelImplCopyWith<$Res> {
  __$$WorkExperienceModelImplCopyWithImpl(
    _$WorkExperienceModelImpl _value,
    $Res Function(_$WorkExperienceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? company = null,
    Object? role = null,
    Object? fromDate = null,
    Object? toDate = freezed,
    Object? description = freezed,
    Object? isCurrent = null,
  }) {
    return _then(
      _$WorkExperienceModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        company: null == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        fromDate: null == fromDate
            ? _value.fromDate
            : fromDate // ignore: cast_nullable_to_non_nullable
                  as String,
        toDate: freezed == toDate
            ? _value.toDate
            : toDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCurrent: null == isCurrent
            ? _value.isCurrent
            : isCurrent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkExperienceModelImpl extends _WorkExperienceModel {
  const _$WorkExperienceModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.company,
    required this.role,
    @JsonKey(name: 'from_date') required this.fromDate,
    @JsonKey(name: 'to_date') this.toDate,
    this.description,
    @JsonKey(name: 'is_current') this.isCurrent = false,
  }) : super._();

  factory _$WorkExperienceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkExperienceModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String company;
  @override
  final String role;
  @override
  @JsonKey(name: 'from_date')
  final String fromDate;
  @override
  @JsonKey(name: 'to_date')
  final String? toDate;
  @override
  final String? description;
  @override
  @JsonKey(name: 'is_current')
  final bool isCurrent;

  @override
  String toString() {
    return 'WorkExperienceModel(id: $id, userId: $userId, company: $company, role: $role, fromDate: $fromDate, toDate: $toDate, description: $description, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkExperienceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    company,
    role,
    fromDate,
    toDate,
    description,
    isCurrent,
  );

  /// Create a copy of WorkExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkExperienceModelImplCopyWith<_$WorkExperienceModelImpl> get copyWith =>
      __$$WorkExperienceModelImplCopyWithImpl<_$WorkExperienceModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkExperienceModelImplToJson(this);
  }
}

abstract class _WorkExperienceModel extends WorkExperienceModel {
  const factory _WorkExperienceModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String company,
    required final String role,
    @JsonKey(name: 'from_date') required final String fromDate,
    @JsonKey(name: 'to_date') final String? toDate,
    final String? description,
    @JsonKey(name: 'is_current') final bool isCurrent,
  }) = _$WorkExperienceModelImpl;
  const _WorkExperienceModel._() : super._();

  factory _WorkExperienceModel.fromJson(Map<String, dynamic> json) =
      _$WorkExperienceModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get company;
  @override
  String get role;
  @override
  @JsonKey(name: 'from_date')
  String get fromDate;
  @override
  @JsonKey(name: 'to_date')
  String? get toDate;
  @override
  String? get description;
  @override
  @JsonKey(name: 'is_current')
  bool get isCurrent;

  /// Create a copy of WorkExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkExperienceModelImplCopyWith<_$WorkExperienceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
