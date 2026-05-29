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
String _$jobPostNotifierHash() => r'9b2a6335be40b6814a0a3f90fec4b93f9df44aed';

/// Action-only notifier for creating Job Posts.
/// No build() state — just exposes the create() method.
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
