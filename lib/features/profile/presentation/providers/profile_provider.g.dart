// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'd24be1673f41b3ff5ab5d7de4be5af09b77e7c82';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$currentProfileHash() => r'3f862dfa9aa109bdffbc9ae9a225c344b34d7d80';

/// Watches [authProvider] and auto-rebuilds when auth state changes.
///
/// This is the single source of truth for the current user's profile data.
/// Separate from authProvider which only handles authentication state.
///
/// Copied from [currentProfile].
@ProviderFor(currentProfile)
final currentProfileProvider = AutoDisposeFutureProvider<UserProfile>.internal(
  currentProfile,
  name: r'currentProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentProfileRef = AutoDisposeFutureProviderRef<UserProfile>;
String _$workExperiencesHash() => r'8b80cf3485d0beb24b8e7b33d21d149da3653476';

/// See also [workExperiences].
@ProviderFor(workExperiences)
final workExperiencesProvider =
    AutoDisposeFutureProvider<List<WorkExperience>>.internal(
      workExperiences,
      name: r'workExperiencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workExperiencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkExperiencesRef = AutoDisposeFutureProviderRef<List<WorkExperience>>;
String _$educationsHash() => r'1d9b4748509730198735f274244439709705aa28';

/// See also [educations].
@ProviderFor(educations)
final educationsProvider = AutoDisposeFutureProvider<List<Education>>.internal(
  educations,
  name: r'educationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$educationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EducationsRef = AutoDisposeFutureProviderRef<List<Education>>;
String _$certificatesHash() => r'c4dfb44e859bf1e0fa867244e974b8a3feb72247';

/// See also [certificates].
@ProviderFor(certificates)
final certificatesProvider =
    AutoDisposeFutureProvider<List<Certificate>>.internal(
      certificates,
      name: r'certificatesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$certificatesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CertificatesRef = AutoDisposeFutureProviderRef<List<Certificate>>;
String _$availableSkillsHash() => r'e39fbc7258bc762237055384d477d58d8cf0bd2d';

/// See also [availableSkills].
@ProviderFor(availableSkills)
final availableSkillsProvider = AutoDisposeFutureProvider<List<Skill>>.internal(
  availableSkills,
  name: r'availableSkillsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableSkillsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableSkillsRef = AutoDisposeFutureProviderRef<List<Skill>>;
String _$userSkillsHash() => r'81c7edbd4344e6d272145e44e85b9128a3c83898';

/// See also [userSkills].
@ProviderFor(userSkills)
final userSkillsProvider = AutoDisposeFutureProvider<List<UserSkill>>.internal(
  userSkills,
  name: r'userSkillsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userSkillsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserSkillsRef = AutoDisposeFutureProviderRef<List<UserSkill>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
