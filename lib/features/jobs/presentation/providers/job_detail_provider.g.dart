// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobDetailHash() => r'aacc6bd2df4a4c7abb3ef1971a24a1b8324ecc7b';

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

/// See also [jobDetail].
@ProviderFor(jobDetail)
const jobDetailProvider = JobDetailFamily();

/// See also [jobDetail].
class JobDetailFamily extends Family<AsyncValue<JobDetail?>> {
  /// See also [jobDetail].
  const JobDetailFamily();

  /// See also [jobDetail].
  JobDetailProvider call(String jobPostId) {
    return JobDetailProvider(jobPostId);
  }

  @override
  JobDetailProvider getProviderOverride(covariant JobDetailProvider provider) {
    return call(provider.jobPostId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'jobDetailProvider';
}

/// See also [jobDetail].
class JobDetailProvider extends AutoDisposeFutureProvider<JobDetail?> {
  /// See also [jobDetail].
  JobDetailProvider(String jobPostId)
    : this._internal(
        (ref) => jobDetail(ref as JobDetailRef, jobPostId),
        from: jobDetailProvider,
        name: r'jobDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$jobDetailHash,
        dependencies: JobDetailFamily._dependencies,
        allTransitiveDependencies: JobDetailFamily._allTransitiveDependencies,
        jobPostId: jobPostId,
      );

  JobDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobPostId,
  }) : super.internal();

  final String jobPostId;

  @override
  Override overrideWith(
    FutureOr<JobDetail?> Function(JobDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobDetailProvider._internal(
        (ref) => create(ref as JobDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobPostId: jobPostId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<JobDetail?> createElement() {
    return _JobDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobDetailProvider && other.jobPostId == jobPostId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobPostId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobDetailRef on AutoDisposeFutureProviderRef<JobDetail?> {
  /// The parameter `jobPostId` of this provider.
  String get jobPostId;
}

class _JobDetailProviderElement
    extends AutoDisposeFutureProviderElement<JobDetail?>
    with JobDetailRef {
  _JobDetailProviderElement(super.provider);

  @override
  String get jobPostId => (origin as JobDetailProvider).jobPostId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
