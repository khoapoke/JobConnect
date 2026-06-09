// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminStatsModel _$AdminStatsModelFromJson(Map<String, dynamic> json) {
  return _AdminStatsModel.fromJson(json);
}

/// @nodoc
mixin _$AdminStatsModel {
  @JsonKey(name: 'total_seekers')
  int get totalSeekers => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_recruiters')
  int get totalRecruiters => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_active_posts')
  int get totalActivePosts => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_applications')
  int get totalApplications => throw _privateConstructorUsedError;
  @JsonKey(name: 'applications_per_day')
  List<DayCountModel> get applicationsPerDay =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'posts_by_category')
  List<CategoryCountModel> get postsByCategory =>
      throw _privateConstructorUsedError;

  /// Serializes this AdminStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminStatsModelCopyWith<AdminStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminStatsModelCopyWith<$Res> {
  factory $AdminStatsModelCopyWith(
    AdminStatsModel value,
    $Res Function(AdminStatsModel) then,
  ) = _$AdminStatsModelCopyWithImpl<$Res, AdminStatsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_seekers') int totalSeekers,
    @JsonKey(name: 'total_recruiters') int totalRecruiters,
    @JsonKey(name: 'total_active_posts') int totalActivePosts,
    @JsonKey(name: 'total_applications') int totalApplications,
    @JsonKey(name: 'applications_per_day')
    List<DayCountModel> applicationsPerDay,
    @JsonKey(name: 'posts_by_category')
    List<CategoryCountModel> postsByCategory,
  });
}

/// @nodoc
class _$AdminStatsModelCopyWithImpl<$Res, $Val extends AdminStatsModel>
    implements $AdminStatsModelCopyWith<$Res> {
  _$AdminStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSeekers = null,
    Object? totalRecruiters = null,
    Object? totalActivePosts = null,
    Object? totalApplications = null,
    Object? applicationsPerDay = null,
    Object? postsByCategory = null,
  }) {
    return _then(
      _value.copyWith(
            totalSeekers: null == totalSeekers
                ? _value.totalSeekers
                : totalSeekers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRecruiters: null == totalRecruiters
                ? _value.totalRecruiters
                : totalRecruiters // ignore: cast_nullable_to_non_nullable
                      as int,
            totalActivePosts: null == totalActivePosts
                ? _value.totalActivePosts
                : totalActivePosts // ignore: cast_nullable_to_non_nullable
                      as int,
            totalApplications: null == totalApplications
                ? _value.totalApplications
                : totalApplications // ignore: cast_nullable_to_non_nullable
                      as int,
            applicationsPerDay: null == applicationsPerDay
                ? _value.applicationsPerDay
                : applicationsPerDay // ignore: cast_nullable_to_non_nullable
                      as List<DayCountModel>,
            postsByCategory: null == postsByCategory
                ? _value.postsByCategory
                : postsByCategory // ignore: cast_nullable_to_non_nullable
                      as List<CategoryCountModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminStatsModelImplCopyWith<$Res>
    implements $AdminStatsModelCopyWith<$Res> {
  factory _$$AdminStatsModelImplCopyWith(
    _$AdminStatsModelImpl value,
    $Res Function(_$AdminStatsModelImpl) then,
  ) = __$$AdminStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_seekers') int totalSeekers,
    @JsonKey(name: 'total_recruiters') int totalRecruiters,
    @JsonKey(name: 'total_active_posts') int totalActivePosts,
    @JsonKey(name: 'total_applications') int totalApplications,
    @JsonKey(name: 'applications_per_day')
    List<DayCountModel> applicationsPerDay,
    @JsonKey(name: 'posts_by_category')
    List<CategoryCountModel> postsByCategory,
  });
}

/// @nodoc
class __$$AdminStatsModelImplCopyWithImpl<$Res>
    extends _$AdminStatsModelCopyWithImpl<$Res, _$AdminStatsModelImpl>
    implements _$$AdminStatsModelImplCopyWith<$Res> {
  __$$AdminStatsModelImplCopyWithImpl(
    _$AdminStatsModelImpl _value,
    $Res Function(_$AdminStatsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSeekers = null,
    Object? totalRecruiters = null,
    Object? totalActivePosts = null,
    Object? totalApplications = null,
    Object? applicationsPerDay = null,
    Object? postsByCategory = null,
  }) {
    return _then(
      _$AdminStatsModelImpl(
        totalSeekers: null == totalSeekers
            ? _value.totalSeekers
            : totalSeekers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRecruiters: null == totalRecruiters
            ? _value.totalRecruiters
            : totalRecruiters // ignore: cast_nullable_to_non_nullable
                  as int,
        totalActivePosts: null == totalActivePosts
            ? _value.totalActivePosts
            : totalActivePosts // ignore: cast_nullable_to_non_nullable
                  as int,
        totalApplications: null == totalApplications
            ? _value.totalApplications
            : totalApplications // ignore: cast_nullable_to_non_nullable
                  as int,
        applicationsPerDay: null == applicationsPerDay
            ? _value._applicationsPerDay
            : applicationsPerDay // ignore: cast_nullable_to_non_nullable
                  as List<DayCountModel>,
        postsByCategory: null == postsByCategory
            ? _value._postsByCategory
            : postsByCategory // ignore: cast_nullable_to_non_nullable
                  as List<CategoryCountModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminStatsModelImpl extends _AdminStatsModel {
  const _$AdminStatsModelImpl({
    @JsonKey(name: 'total_seekers') required this.totalSeekers,
    @JsonKey(name: 'total_recruiters') required this.totalRecruiters,
    @JsonKey(name: 'total_active_posts') required this.totalActivePosts,
    @JsonKey(name: 'total_applications') required this.totalApplications,
    @JsonKey(name: 'applications_per_day')
    required final List<DayCountModel> applicationsPerDay,
    @JsonKey(name: 'posts_by_category')
    required final List<CategoryCountModel> postsByCategory,
  }) : _applicationsPerDay = applicationsPerDay,
       _postsByCategory = postsByCategory,
       super._();

  factory _$AdminStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminStatsModelImplFromJson(json);

  @override
  @JsonKey(name: 'total_seekers')
  final int totalSeekers;
  @override
  @JsonKey(name: 'total_recruiters')
  final int totalRecruiters;
  @override
  @JsonKey(name: 'total_active_posts')
  final int totalActivePosts;
  @override
  @JsonKey(name: 'total_applications')
  final int totalApplications;
  final List<DayCountModel> _applicationsPerDay;
  @override
  @JsonKey(name: 'applications_per_day')
  List<DayCountModel> get applicationsPerDay {
    if (_applicationsPerDay is EqualUnmodifiableListView)
      return _applicationsPerDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_applicationsPerDay);
  }

  final List<CategoryCountModel> _postsByCategory;
  @override
  @JsonKey(name: 'posts_by_category')
  List<CategoryCountModel> get postsByCategory {
    if (_postsByCategory is EqualUnmodifiableListView) return _postsByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_postsByCategory);
  }

  @override
  String toString() {
    return 'AdminStatsModel(totalSeekers: $totalSeekers, totalRecruiters: $totalRecruiters, totalActivePosts: $totalActivePosts, totalApplications: $totalApplications, applicationsPerDay: $applicationsPerDay, postsByCategory: $postsByCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminStatsModelImpl &&
            (identical(other.totalSeekers, totalSeekers) ||
                other.totalSeekers == totalSeekers) &&
            (identical(other.totalRecruiters, totalRecruiters) ||
                other.totalRecruiters == totalRecruiters) &&
            (identical(other.totalActivePosts, totalActivePosts) ||
                other.totalActivePosts == totalActivePosts) &&
            (identical(other.totalApplications, totalApplications) ||
                other.totalApplications == totalApplications) &&
            const DeepCollectionEquality().equals(
              other._applicationsPerDay,
              _applicationsPerDay,
            ) &&
            const DeepCollectionEquality().equals(
              other._postsByCategory,
              _postsByCategory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalSeekers,
    totalRecruiters,
    totalActivePosts,
    totalApplications,
    const DeepCollectionEquality().hash(_applicationsPerDay),
    const DeepCollectionEquality().hash(_postsByCategory),
  );

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminStatsModelImplCopyWith<_$AdminStatsModelImpl> get copyWith =>
      __$$AdminStatsModelImplCopyWithImpl<_$AdminStatsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminStatsModelImplToJson(this);
  }
}

abstract class _AdminStatsModel extends AdminStatsModel {
  const factory _AdminStatsModel({
    @JsonKey(name: 'total_seekers') required final int totalSeekers,
    @JsonKey(name: 'total_recruiters') required final int totalRecruiters,
    @JsonKey(name: 'total_active_posts') required final int totalActivePosts,
    @JsonKey(name: 'total_applications') required final int totalApplications,
    @JsonKey(name: 'applications_per_day')
    required final List<DayCountModel> applicationsPerDay,
    @JsonKey(name: 'posts_by_category')
    required final List<CategoryCountModel> postsByCategory,
  }) = _$AdminStatsModelImpl;
  const _AdminStatsModel._() : super._();

  factory _AdminStatsModel.fromJson(Map<String, dynamic> json) =
      _$AdminStatsModelImpl.fromJson;

  @override
  @JsonKey(name: 'total_seekers')
  int get totalSeekers;
  @override
  @JsonKey(name: 'total_recruiters')
  int get totalRecruiters;
  @override
  @JsonKey(name: 'total_active_posts')
  int get totalActivePosts;
  @override
  @JsonKey(name: 'total_applications')
  int get totalApplications;
  @override
  @JsonKey(name: 'applications_per_day')
  List<DayCountModel> get applicationsPerDay;
  @override
  @JsonKey(name: 'posts_by_category')
  List<CategoryCountModel> get postsByCategory;

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminStatsModelImplCopyWith<_$AdminStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DayCountModel _$DayCountModelFromJson(Map<String, dynamic> json) {
  return _DayCountModel.fromJson(json);
}

/// @nodoc
mixin _$DayCountModel {
  DateTime get date => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this DayCountModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayCountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayCountModelCopyWith<DayCountModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayCountModelCopyWith<$Res> {
  factory $DayCountModelCopyWith(
    DayCountModel value,
    $Res Function(DayCountModel) then,
  ) = _$DayCountModelCopyWithImpl<$Res, DayCountModel>;
  @useResult
  $Res call({DateTime date, int count});
}

/// @nodoc
class _$DayCountModelCopyWithImpl<$Res, $Val extends DayCountModel>
    implements $DayCountModelCopyWith<$Res> {
  _$DayCountModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayCountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DayCountModelImplCopyWith<$Res>
    implements $DayCountModelCopyWith<$Res> {
  factory _$$DayCountModelImplCopyWith(
    _$DayCountModelImpl value,
    $Res Function(_$DayCountModelImpl) then,
  ) = __$$DayCountModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int count});
}

/// @nodoc
class __$$DayCountModelImplCopyWithImpl<$Res>
    extends _$DayCountModelCopyWithImpl<$Res, _$DayCountModelImpl>
    implements _$$DayCountModelImplCopyWith<$Res> {
  __$$DayCountModelImplCopyWithImpl(
    _$DayCountModelImpl _value,
    $Res Function(_$DayCountModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DayCountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? count = null}) {
    return _then(
      _$DayCountModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DayCountModelImpl extends _DayCountModel {
  const _$DayCountModelImpl({required this.date, required this.count})
    : super._();

  factory _$DayCountModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayCountModelImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int count;

  @override
  String toString() {
    return 'DayCountModel(date: $date, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayCountModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, count);

  /// Create a copy of DayCountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayCountModelImplCopyWith<_$DayCountModelImpl> get copyWith =>
      __$$DayCountModelImplCopyWithImpl<_$DayCountModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayCountModelImplToJson(this);
  }
}

abstract class _DayCountModel extends DayCountModel {
  const factory _DayCountModel({
    required final DateTime date,
    required final int count,
  }) = _$DayCountModelImpl;
  const _DayCountModel._() : super._();

  factory _DayCountModel.fromJson(Map<String, dynamic> json) =
      _$DayCountModelImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get count;

  /// Create a copy of DayCountModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayCountModelImplCopyWith<_$DayCountModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryCountModel _$CategoryCountModelFromJson(Map<String, dynamic> json) {
  return _CategoryCountModel.fromJson(json);
}

/// @nodoc
mixin _$CategoryCountModel {
  String get category => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this CategoryCountModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryCountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryCountModelCopyWith<CategoryCountModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCountModelCopyWith<$Res> {
  factory $CategoryCountModelCopyWith(
    CategoryCountModel value,
    $Res Function(CategoryCountModel) then,
  ) = _$CategoryCountModelCopyWithImpl<$Res, CategoryCountModel>;
  @useResult
  $Res call({String category, int count});
}

/// @nodoc
class _$CategoryCountModelCopyWithImpl<$Res, $Val extends CategoryCountModel>
    implements $CategoryCountModelCopyWith<$Res> {
  _$CategoryCountModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryCountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? category = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryCountModelImplCopyWith<$Res>
    implements $CategoryCountModelCopyWith<$Res> {
  factory _$$CategoryCountModelImplCopyWith(
    _$CategoryCountModelImpl value,
    $Res Function(_$CategoryCountModelImpl) then,
  ) = __$$CategoryCountModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, int count});
}

/// @nodoc
class __$$CategoryCountModelImplCopyWithImpl<$Res>
    extends _$CategoryCountModelCopyWithImpl<$Res, _$CategoryCountModelImpl>
    implements _$$CategoryCountModelImplCopyWith<$Res> {
  __$$CategoryCountModelImplCopyWithImpl(
    _$CategoryCountModelImpl _value,
    $Res Function(_$CategoryCountModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryCountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? category = null, Object? count = null}) {
    return _then(
      _$CategoryCountModelImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryCountModelImpl extends _CategoryCountModel {
  const _$CategoryCountModelImpl({required this.category, required this.count})
    : super._();

  factory _$CategoryCountModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryCountModelImplFromJson(json);

  @override
  final String category;
  @override
  final int count;

  @override
  String toString() {
    return 'CategoryCountModel(category: $category, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryCountModelImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, count);

  /// Create a copy of CategoryCountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryCountModelImplCopyWith<_$CategoryCountModelImpl> get copyWith =>
      __$$CategoryCountModelImplCopyWithImpl<_$CategoryCountModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryCountModelImplToJson(this);
  }
}

abstract class _CategoryCountModel extends CategoryCountModel {
  const factory _CategoryCountModel({
    required final String category,
    required final int count,
  }) = _$CategoryCountModelImpl;
  const _CategoryCountModel._() : super._();

  factory _CategoryCountModel.fromJson(Map<String, dynamic> json) =
      _$CategoryCountModelImpl.fromJson;

  @override
  String get category;
  @override
  int get count;

  /// Create a copy of CategoryCountModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryCountModelImplCopyWith<_$CategoryCountModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
