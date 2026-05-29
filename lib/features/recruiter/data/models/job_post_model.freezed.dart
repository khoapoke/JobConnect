// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JobPostModel _$JobPostModelFromJson(Map<String, dynamic> json) {
  return _JobPostModel.fromJson(json);
}

/// @nodoc
mixin _$JobPostModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_id')
  String get companyId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get requirements => throw _privateConstructorUsedError;
  @JsonKey(name: 'salary_min')
  int get salaryMin => throw _privateConstructorUsedError;
  @JsonKey(name: 'salary_max')
  int get salaryMax => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_salary_visible')
  bool get isSalaryVisible => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this JobPostModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobPostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobPostModelCopyWith<JobPostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobPostModelCopyWith<$Res> {
  factory $JobPostModelCopyWith(
    JobPostModel value,
    $Res Function(JobPostModel) then,
  ) = _$JobPostModelCopyWithImpl<$Res, JobPostModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'company_id') String companyId,
    String title,
    String? description,
    String? requirements,
    @JsonKey(name: 'salary_min') int salaryMin,
    @JsonKey(name: 'salary_max') int salaryMax,
    @JsonKey(name: 'is_salary_visible') bool isSalaryVisible,
    String type,
    @JsonKey(name: 'category_id') String? categoryId,
    String status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$JobPostModelCopyWithImpl<$Res, $Val extends JobPostModel>
    implements $JobPostModelCopyWith<$Res> {
  _$JobPostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobPostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? title = null,
    Object? description = freezed,
    Object? requirements = freezed,
    Object? salaryMin = null,
    Object? salaryMax = null,
    Object? isSalaryVisible = null,
    Object? type = null,
    Object? categoryId = freezed,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            companyId: null == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            requirements: freezed == requirements
                ? _value.requirements
                : requirements // ignore: cast_nullable_to_non_nullable
                      as String?,
            salaryMin: null == salaryMin
                ? _value.salaryMin
                : salaryMin // ignore: cast_nullable_to_non_nullable
                      as int,
            salaryMax: null == salaryMax
                ? _value.salaryMax
                : salaryMax // ignore: cast_nullable_to_non_nullable
                      as int,
            isSalaryVisible: null == isSalaryVisible
                ? _value.isSalaryVisible
                : isSalaryVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobPostModelImplCopyWith<$Res>
    implements $JobPostModelCopyWith<$Res> {
  factory _$$JobPostModelImplCopyWith(
    _$JobPostModelImpl value,
    $Res Function(_$JobPostModelImpl) then,
  ) = __$$JobPostModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'company_id') String companyId,
    String title,
    String? description,
    String? requirements,
    @JsonKey(name: 'salary_min') int salaryMin,
    @JsonKey(name: 'salary_max') int salaryMax,
    @JsonKey(name: 'is_salary_visible') bool isSalaryVisible,
    String type,
    @JsonKey(name: 'category_id') String? categoryId,
    String status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$JobPostModelImplCopyWithImpl<$Res>
    extends _$JobPostModelCopyWithImpl<$Res, _$JobPostModelImpl>
    implements _$$JobPostModelImplCopyWith<$Res> {
  __$$JobPostModelImplCopyWithImpl(
    _$JobPostModelImpl _value,
    $Res Function(_$JobPostModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobPostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? title = null,
    Object? description = freezed,
    Object? requirements = freezed,
    Object? salaryMin = null,
    Object? salaryMax = null,
    Object? isSalaryVisible = null,
    Object? type = null,
    Object? categoryId = freezed,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$JobPostModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        requirements: freezed == requirements
            ? _value.requirements
            : requirements // ignore: cast_nullable_to_non_nullable
                  as String?,
        salaryMin: null == salaryMin
            ? _value.salaryMin
            : salaryMin // ignore: cast_nullable_to_non_nullable
                  as int,
        salaryMax: null == salaryMax
            ? _value.salaryMax
            : salaryMax // ignore: cast_nullable_to_non_nullable
                  as int,
        isSalaryVisible: null == isSalaryVisible
            ? _value.isSalaryVisible
            : isSalaryVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobPostModelImpl implements _JobPostModel {
  const _$JobPostModelImpl({
    required this.id,
    @JsonKey(name: 'company_id') required this.companyId,
    required this.title,
    this.description,
    this.requirements,
    @JsonKey(name: 'salary_min') required this.salaryMin,
    @JsonKey(name: 'salary_max') required this.salaryMax,
    @JsonKey(name: 'is_salary_visible') required this.isSalaryVisible,
    required this.type,
    @JsonKey(name: 'category_id') this.categoryId,
    required this.status,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$JobPostModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobPostModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'company_id')
  final String companyId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? requirements;
  @override
  @JsonKey(name: 'salary_min')
  final int salaryMin;
  @override
  @JsonKey(name: 'salary_max')
  final int salaryMax;
  @override
  @JsonKey(name: 'is_salary_visible')
  final bool isSalaryVisible;
  @override
  final String type;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  final String status;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'JobPostModel(id: $id, companyId: $companyId, title: $title, description: $description, requirements: $requirements, salaryMin: $salaryMin, salaryMax: $salaryMax, isSalaryVisible: $isSalaryVisible, type: $type, categoryId: $categoryId, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobPostModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.requirements, requirements) ||
                other.requirements == requirements) &&
            (identical(other.salaryMin, salaryMin) ||
                other.salaryMin == salaryMin) &&
            (identical(other.salaryMax, salaryMax) ||
                other.salaryMax == salaryMax) &&
            (identical(other.isSalaryVisible, isSalaryVisible) ||
                other.isSalaryVisible == isSalaryVisible) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    title,
    description,
    requirements,
    salaryMin,
    salaryMax,
    isSalaryVisible,
    type,
    categoryId,
    status,
    expiresAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of JobPostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobPostModelImplCopyWith<_$JobPostModelImpl> get copyWith =>
      __$$JobPostModelImplCopyWithImpl<_$JobPostModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobPostModelImplToJson(this);
  }
}

abstract class _JobPostModel implements JobPostModel {
  const factory _JobPostModel({
    required final String id,
    @JsonKey(name: 'company_id') required final String companyId,
    required final String title,
    final String? description,
    final String? requirements,
    @JsonKey(name: 'salary_min') required final int salaryMin,
    @JsonKey(name: 'salary_max') required final int salaryMax,
    @JsonKey(name: 'is_salary_visible') required final bool isSalaryVisible,
    required final String type,
    @JsonKey(name: 'category_id') final String? categoryId,
    required final String status,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$JobPostModelImpl;

  factory _JobPostModel.fromJson(Map<String, dynamic> json) =
      _$JobPostModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'company_id')
  String get companyId;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get requirements;
  @override
  @JsonKey(name: 'salary_min')
  int get salaryMin;
  @override
  @JsonKey(name: 'salary_max')
  int get salaryMax;
  @override
  @JsonKey(name: 'is_salary_visible')
  bool get isSalaryVisible;
  @override
  String get type;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  String get status;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of JobPostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobPostModelImplCopyWith<_$JobPostModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
