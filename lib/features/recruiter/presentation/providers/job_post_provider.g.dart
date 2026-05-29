// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobPostRepositoryHash() => r'b3c828e63b1dec77815fe35bfea03963912ee45e';

/// See also [jobPostRepository].
@ProviderFor(jobPostRepository)
final jobPostRepositoryProvider =
    AutoDisposeProvider<JobPostRepository>.internal(
      jobPostRepository,
      name: r'jobPostRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$jobPostRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JobPostRepositoryRef = AutoDisposeProviderRef<JobPostRepository>;
String _$myJobPostsHash() => r'abeb7b2db3a12e9424cd9c7cec2de64c1063a898';

/// Fetches all job posts for the current company.
///
/// Copied from [myJobPosts].
@ProviderFor(myJobPosts)
final myJobPostsProvider = AutoDisposeFutureProvider<List<JobPost>>.internal(
  myJobPosts,
  name: r'myJobPostsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myJobPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyJobPostsRef = AutoDisposeFutureProviderRef<List<JobPost>>;
String _$jobPostDetailHash() => r'bd4120352b1729bd9ec3588b584bc7c299fc4d8c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches a single job post detail by ID.
///
/// Copied from [jobPostDetail].
@ProviderFor(jobPostDetail)
const jobPostDetailProvider = JobPostDetailFamily();

/// Fetches a single job post detail by ID.
///
/// Copied from [jobPostDetail].
class JobPostDetailFamily extends Family<AsyncValue<JobPostDetail>> {
  /// Fetches a single job post detail by ID.
  ///
  /// Copied from [jobPostDetail].
  const JobPostDetailFamily();

  /// Fetches a single job post detail by ID.
  ///
  /// Copied from [jobPostDetail].
  JobPostDetailProvider call(String jobId) {
    return JobPostDetailProvider(jobId);
  }

  @override
  JobPostDetailProvider getProviderOverride(
    covariant JobPostDetailProvider provider,
  ) {
    return call(provider.jobId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'jobPostDetailProvider';
}

/// Fetches a single job post detail by ID.
///
/// Copied from [jobPostDetail].
class JobPostDetailProvider extends AutoDisposeFutureProvider<JobPostDetail> {
  /// Fetches a single job post detail by ID.
  ///
  /// Copied from [jobPostDetail].
  JobPostDetailProvider(String jobId)
    : this._internal(
        (ref) => jobPostDetail(ref as JobPostDetailRef, jobId),
        from: jobPostDetailProvider,
        name: r'jobPostDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$jobPostDetailHash,
        dependencies: JobPostDetailFamily._dependencies,
        allTransitiveDependencies:
            JobPostDetailFamily._allTransitiveDependencies,
        jobId: jobId,
      );

  JobPostDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    FutureOr<JobPostDetail> Function(JobPostDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobPostDetailProvider._internal(
        (ref) => create(ref as JobPostDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<JobPostDetail> createElement() {
    return _JobPostDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobPostDetailProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobPostDetailRef on AutoDisposeFutureProviderRef<JobPostDetail> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _JobPostDetailProviderElement
    extends AutoDisposeFutureProviderElement<JobPostDetail>
    with JobPostDetailRef {
  _JobPostDetailProviderElement(super.provider);

  @override
  String get jobId => (origin as JobPostDetailProvider).jobId;
}

String _$jobPostNotifierHash() => r'eeb8fa0462f1593adb21c8ebedaca3a3469598bd';

/// Action notifier for Job Post operations (create, update, status changes).
///
/// Copied from [JobPostNotifier].
@ProviderFor(JobPostNotifier)
final jobPostNotifierProvider =
    AutoDisposeNotifierProvider<JobPostNotifier, void>.internal(
      JobPostNotifier.new,
      name: r'jobPostNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$jobPostNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JobPostNotifier = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
