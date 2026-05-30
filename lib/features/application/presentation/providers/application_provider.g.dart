// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$applicationRepositoryHash() =>
    r'9afd4f41bfb66a2f419a9df1cb9706fd3515109f';

/// See also [applicationRepository].
@ProviderFor(applicationRepository)
final applicationRepositoryProvider =
    AutoDisposeProvider<ApplicationRepository>.internal(
      applicationRepository,
      name: r'applicationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$applicationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApplicationRepositoryRef =
    AutoDisposeProviderRef<ApplicationRepository>;
String _$resumePdfServiceHash() => r'0e8d4f6716f32431373dfea7f178d67d0f9abca8';

/// See also [resumePdfService].
@ProviderFor(resumePdfService)
final resumePdfServiceProvider = AutoDisposeProvider<ResumePdfService>.internal(
  resumePdfService,
  name: r'resumePdfServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resumePdfServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResumePdfServiceRef = AutoDisposeProviderRef<ResumePdfService>;
String _$createBuilderResumeUseCaseHash() =>
    r'06b3166a5fc994e8dce3ac23d47e872e692a2548';

/// See also [createBuilderResumeUseCase].
@ProviderFor(createBuilderResumeUseCase)
final createBuilderResumeUseCaseProvider =
    AutoDisposeProvider<CreateBuilderResumeUseCase>.internal(
      createBuilderResumeUseCase,
      name: r'createBuilderResumeUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createBuilderResumeUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateBuilderResumeUseCaseRef =
    AutoDisposeProviderRef<CreateBuilderResumeUseCase>;
String _$uploadResumePdfUseCaseHash() =>
    r'5c389b5296f2c9698adc9a0e17777ae083c42b9b';

/// See also [uploadResumePdfUseCase].
@ProviderFor(uploadResumePdfUseCase)
final uploadResumePdfUseCaseProvider =
    AutoDisposeProvider<UploadResumePdfUseCase>.internal(
      uploadResumePdfUseCase,
      name: r'uploadResumePdfUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$uploadResumePdfUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UploadResumePdfUseCaseRef =
    AutoDisposeProviderRef<UploadResumePdfUseCase>;
String _$applyToJobUseCaseHash() => r'e2e0a2ae82d894c785e7bdf6eb4b80b8ad7aee55';

/// See also [applyToJobUseCase].
@ProviderFor(applyToJobUseCase)
final applyToJobUseCaseProvider =
    AutoDisposeProvider<ApplyToJobUseCase>.internal(
      applyToJobUseCase,
      name: r'applyToJobUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$applyToJobUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApplyToJobUseCaseRef = AutoDisposeProviderRef<ApplyToJobUseCase>;
String _$myResumesHash() => r'ec967908cc092d94d41ab75415d8b248268255f5';

/// See also [myResumes].
@ProviderFor(myResumes)
final myResumesProvider = AutoDisposeFutureProvider<List<Resume>>.internal(
  myResumes,
  name: r'myResumesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myResumesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyResumesRef = AutoDisposeFutureProviderRef<List<Resume>>;
String _$resumeBytesHash() => r'f476791823647992fa188150ed4a665def9b37ef';

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

/// See also [resumeBytes].
@ProviderFor(resumeBytes)
const resumeBytesProvider = ResumeBytesFamily();

/// See also [resumeBytes].
class ResumeBytesFamily extends Family<AsyncValue<List<int>>> {
  /// See also [resumeBytes].
  const ResumeBytesFamily();

  /// See also [resumeBytes].
  ResumeBytesProvider call(String relativePath) {
    return ResumeBytesProvider(relativePath);
  }

  @override
  ResumeBytesProvider getProviderOverride(
    covariant ResumeBytesProvider provider,
  ) {
    return call(provider.relativePath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'resumeBytesProvider';
}

/// See also [resumeBytes].
class ResumeBytesProvider extends AutoDisposeFutureProvider<List<int>> {
  /// See also [resumeBytes].
  ResumeBytesProvider(String relativePath)
    : this._internal(
        (ref) => resumeBytes(ref as ResumeBytesRef, relativePath),
        from: resumeBytesProvider,
        name: r'resumeBytesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$resumeBytesHash,
        dependencies: ResumeBytesFamily._dependencies,
        allTransitiveDependencies: ResumeBytesFamily._allTransitiveDependencies,
        relativePath: relativePath,
      );

  ResumeBytesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.relativePath,
  }) : super.internal();

  final String relativePath;

  @override
  Override overrideWith(
    FutureOr<List<int>> Function(ResumeBytesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResumeBytesProvider._internal(
        (ref) => create(ref as ResumeBytesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        relativePath: relativePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<int>> createElement() {
    return _ResumeBytesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResumeBytesProvider && other.relativePath == relativePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, relativePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResumeBytesRef on AutoDisposeFutureProviderRef<List<int>> {
  /// The parameter `relativePath` of this provider.
  String get relativePath;
}

class _ResumeBytesProviderElement
    extends AutoDisposeFutureProviderElement<List<int>>
    with ResumeBytesRef {
  _ResumeBytesProviderElement(super.provider);

  @override
  String get relativePath => (origin as ResumeBytesProvider).relativePath;
}

String _$myApplicationsHash() => r'8fd094d43ca25fb1bf5bdfd5d98b000d2d806501';

/// See also [myApplications].
@ProviderFor(myApplications)
const myApplicationsProvider = MyApplicationsFamily();

/// See also [myApplications].
class MyApplicationsFamily extends Family<AsyncValue<List<Application>>> {
  /// See also [myApplications].
  const MyApplicationsFamily();

  /// See also [myApplications].
  MyApplicationsProvider call(ApplicationStatusFilter filter) {
    return MyApplicationsProvider(filter);
  }

  @override
  MyApplicationsProvider getProviderOverride(
    covariant MyApplicationsProvider provider,
  ) {
    return call(provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myApplicationsProvider';
}

/// See also [myApplications].
class MyApplicationsProvider
    extends AutoDisposeFutureProvider<List<Application>> {
  /// See also [myApplications].
  MyApplicationsProvider(ApplicationStatusFilter filter)
    : this._internal(
        (ref) => myApplications(ref as MyApplicationsRef, filter),
        from: myApplicationsProvider,
        name: r'myApplicationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myApplicationsHash,
        dependencies: MyApplicationsFamily._dependencies,
        allTransitiveDependencies:
            MyApplicationsFamily._allTransitiveDependencies,
        filter: filter,
      );

  MyApplicationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final ApplicationStatusFilter filter;

  @override
  Override overrideWith(
    FutureOr<List<Application>> Function(MyApplicationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyApplicationsProvider._internal(
        (ref) => create(ref as MyApplicationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Application>> createElement() {
    return _MyApplicationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyApplicationsProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyApplicationsRef on AutoDisposeFutureProviderRef<List<Application>> {
  /// The parameter `filter` of this provider.
  ApplicationStatusFilter get filter;
}

class _MyApplicationsProviderElement
    extends AutoDisposeFutureProviderElement<List<Application>>
    with MyApplicationsRef {
  _MyApplicationsProviderElement(super.provider);

  @override
  ApplicationStatusFilter get filter =>
      (origin as MyApplicationsProvider).filter;
}

String _$myApplicationForJobHash() =>
    r'f2edc4a9c05dc2aa035a7f793c8f2a4207fc6b08';

/// See also [myApplicationForJob].
@ProviderFor(myApplicationForJob)
const myApplicationForJobProvider = MyApplicationForJobFamily();

/// See also [myApplicationForJob].
class MyApplicationForJobFamily extends Family<AsyncValue<Application?>> {
  /// See also [myApplicationForJob].
  const MyApplicationForJobFamily();

  /// See also [myApplicationForJob].
  MyApplicationForJobProvider call(String jobId) {
    return MyApplicationForJobProvider(jobId);
  }

  @override
  MyApplicationForJobProvider getProviderOverride(
    covariant MyApplicationForJobProvider provider,
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
  String? get name => r'myApplicationForJobProvider';
}

/// See also [myApplicationForJob].
class MyApplicationForJobProvider
    extends AutoDisposeFutureProvider<Application?> {
  /// See also [myApplicationForJob].
  MyApplicationForJobProvider(String jobId)
    : this._internal(
        (ref) => myApplicationForJob(ref as MyApplicationForJobRef, jobId),
        from: myApplicationForJobProvider,
        name: r'myApplicationForJobProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myApplicationForJobHash,
        dependencies: MyApplicationForJobFamily._dependencies,
        allTransitiveDependencies:
            MyApplicationForJobFamily._allTransitiveDependencies,
        jobId: jobId,
      );

  MyApplicationForJobProvider._internal(
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
    FutureOr<Application?> Function(MyApplicationForJobRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyApplicationForJobProvider._internal(
        (ref) => create(ref as MyApplicationForJobRef),
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
  AutoDisposeFutureProviderElement<Application?> createElement() {
    return _MyApplicationForJobProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyApplicationForJobProvider && other.jobId == jobId;
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
mixin MyApplicationForJobRef on AutoDisposeFutureProviderRef<Application?> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _MyApplicationForJobProviderElement
    extends AutoDisposeFutureProviderElement<Application?>
    with MyApplicationForJobRef {
  _MyApplicationForJobProviderElement(super.provider);

  @override
  String get jobId => (origin as MyApplicationForJobProvider).jobId;
}

String _$myApplicationDetailHash() =>
    r'5fe5751c39e22171332c735cc87074e3a1464891';

/// See also [myApplicationDetail].
@ProviderFor(myApplicationDetail)
const myApplicationDetailProvider = MyApplicationDetailFamily();

/// See also [myApplicationDetail].
class MyApplicationDetailFamily extends Family<AsyncValue<Application?>> {
  /// See also [myApplicationDetail].
  const MyApplicationDetailFamily();

  /// See also [myApplicationDetail].
  MyApplicationDetailProvider call(String applicationId) {
    return MyApplicationDetailProvider(applicationId);
  }

  @override
  MyApplicationDetailProvider getProviderOverride(
    covariant MyApplicationDetailProvider provider,
  ) {
    return call(provider.applicationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myApplicationDetailProvider';
}

/// See also [myApplicationDetail].
class MyApplicationDetailProvider
    extends AutoDisposeFutureProvider<Application?> {
  /// See also [myApplicationDetail].
  MyApplicationDetailProvider(String applicationId)
    : this._internal(
        (ref) =>
            myApplicationDetail(ref as MyApplicationDetailRef, applicationId),
        from: myApplicationDetailProvider,
        name: r'myApplicationDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myApplicationDetailHash,
        dependencies: MyApplicationDetailFamily._dependencies,
        allTransitiveDependencies:
            MyApplicationDetailFamily._allTransitiveDependencies,
        applicationId: applicationId,
      );

  MyApplicationDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.applicationId,
  }) : super.internal();

  final String applicationId;

  @override
  Override overrideWith(
    FutureOr<Application?> Function(MyApplicationDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyApplicationDetailProvider._internal(
        (ref) => create(ref as MyApplicationDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        applicationId: applicationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Application?> createElement() {
    return _MyApplicationDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyApplicationDetailProvider &&
        other.applicationId == applicationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, applicationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyApplicationDetailRef on AutoDisposeFutureProviderRef<Application?> {
  /// The parameter `applicationId` of this provider.
  String get applicationId;
}

class _MyApplicationDetailProviderElement
    extends AutoDisposeFutureProviderElement<Application?>
    with MyApplicationDetailRef {
  _MyApplicationDetailProviderElement(super.provider);

  @override
  String get applicationId =>
      (origin as MyApplicationDetailProvider).applicationId;
}

String _$applicantsHash() => r'59064d0b5d75f6f5c6d5b1a366f28b2c11058e5f';

/// See also [applicants].
@ProviderFor(applicants)
const applicantsProvider = ApplicantsFamily();

/// See also [applicants].
class ApplicantsFamily extends Family<AsyncValue<List<RecruiterApplication>>> {
  /// See also [applicants].
  const ApplicantsFamily();

  /// See also [applicants].
  ApplicantsProvider call(String jobId) {
    return ApplicantsProvider(jobId);
  }

  @override
  ApplicantsProvider getProviderOverride(
    covariant ApplicantsProvider provider,
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
  String? get name => r'applicantsProvider';
}

/// See also [applicants].
class ApplicantsProvider
    extends AutoDisposeFutureProvider<List<RecruiterApplication>> {
  /// See also [applicants].
  ApplicantsProvider(String jobId)
    : this._internal(
        (ref) => applicants(ref as ApplicantsRef, jobId),
        from: applicantsProvider,
        name: r'applicantsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$applicantsHash,
        dependencies: ApplicantsFamily._dependencies,
        allTransitiveDependencies: ApplicantsFamily._allTransitiveDependencies,
        jobId: jobId,
      );

  ApplicantsProvider._internal(
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
    FutureOr<List<RecruiterApplication>> Function(ApplicantsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ApplicantsProvider._internal(
        (ref) => create(ref as ApplicantsRef),
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
  AutoDisposeFutureProviderElement<List<RecruiterApplication>> createElement() {
    return _ApplicantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicantsProvider && other.jobId == jobId;
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
mixin ApplicantsRef
    on AutoDisposeFutureProviderRef<List<RecruiterApplication>> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _ApplicantsProviderElement
    extends AutoDisposeFutureProviderElement<List<RecruiterApplication>>
    with ApplicantsRef {
  _ApplicantsProviderElement(super.provider);

  @override
  String get jobId => (origin as ApplicantsProvider).jobId;
}

String _$applicantDetailHash() => r'75ffc384d5e5c29e592a0516a27ffa8d81550709';

/// See also [applicantDetail].
@ProviderFor(applicantDetail)
const applicantDetailProvider = ApplicantDetailFamily();

/// See also [applicantDetail].
class ApplicantDetailFamily extends Family<AsyncValue<RecruiterApplication?>> {
  /// See also [applicantDetail].
  const ApplicantDetailFamily();

  /// See also [applicantDetail].
  ApplicantDetailProvider call(String applicationId) {
    return ApplicantDetailProvider(applicationId);
  }

  @override
  ApplicantDetailProvider getProviderOverride(
    covariant ApplicantDetailProvider provider,
  ) {
    return call(provider.applicationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'applicantDetailProvider';
}

/// See also [applicantDetail].
class ApplicantDetailProvider
    extends AutoDisposeFutureProvider<RecruiterApplication?> {
  /// See also [applicantDetail].
  ApplicantDetailProvider(String applicationId)
    : this._internal(
        (ref) => applicantDetail(ref as ApplicantDetailRef, applicationId),
        from: applicantDetailProvider,
        name: r'applicantDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$applicantDetailHash,
        dependencies: ApplicantDetailFamily._dependencies,
        allTransitiveDependencies:
            ApplicantDetailFamily._allTransitiveDependencies,
        applicationId: applicationId,
      );

  ApplicantDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.applicationId,
  }) : super.internal();

  final String applicationId;

  @override
  Override overrideWith(
    FutureOr<RecruiterApplication?> Function(ApplicantDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ApplicantDetailProvider._internal(
        (ref) => create(ref as ApplicantDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        applicationId: applicationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RecruiterApplication?> createElement() {
    return _ApplicantDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicantDetailProvider &&
        other.applicationId == applicationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, applicationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ApplicantDetailRef
    on AutoDisposeFutureProviderRef<RecruiterApplication?> {
  /// The parameter `applicationId` of this provider.
  String get applicationId;
}

class _ApplicantDetailProviderElement
    extends AutoDisposeFutureProviderElement<RecruiterApplication?>
    with ApplicantDetailRef {
  _ApplicantDetailProviderElement(super.provider);

  @override
  String get applicationId => (origin as ApplicantDetailProvider).applicationId;
}

String _$resumeActionNotifierHash() =>
    r'adbd7045f8724786cfdd225bb419210a2e25a0b4';

/// See also [ResumeActionNotifier].
@ProviderFor(ResumeActionNotifier)
final resumeActionNotifierProvider =
    AutoDisposeNotifierProvider<
      ResumeActionNotifier,
      AsyncValue<void>
    >.internal(
      ResumeActionNotifier.new,
      name: r'resumeActionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resumeActionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResumeActionNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$applicationActionNotifierHash() =>
    r'4a0c0d9a2aef341979c7430b29b86a00dcbbbd78';

/// See also [ApplicationActionNotifier].
@ProviderFor(ApplicationActionNotifier)
final applicationActionNotifierProvider =
    AutoDisposeNotifierProvider<
      ApplicationActionNotifier,
      AsyncValue<void>
    >.internal(
      ApplicationActionNotifier.new,
      name: r'applicationActionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$applicationActionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ApplicationActionNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
