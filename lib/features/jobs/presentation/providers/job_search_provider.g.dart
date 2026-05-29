// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobSearchNotifierHash() => r'80a28f282becf30787981508c7759162e3adbabb';

/// Notifier managing job search state: query, filters, pagination.
///
/// Copied from [JobSearchNotifier].
@ProviderFor(JobSearchNotifier)
final jobSearchNotifierProvider =
    AutoDisposeNotifierProvider<
      JobSearchNotifier,
      AsyncValue<List<JobSearchResult>>
    >.internal(
      JobSearchNotifier.new,
      name: r'jobSearchNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$jobSearchNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JobSearchNotifier =
    AutoDisposeNotifier<AsyncValue<List<JobSearchResult>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
