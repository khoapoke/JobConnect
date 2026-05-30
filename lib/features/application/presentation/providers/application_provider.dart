import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/application_datasource.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../data/services/resume_pdf_service.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/application_status_filter.dart';
import '../../domain/entities/recruiter_application.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_content.dart';
import '../../domain/repositories/application_repository.dart';
import '../../domain/usecases/apply_to_job_usecase.dart';
import '../../domain/usecases/create_builder_resume_usecase.dart';
import '../../domain/usecases/upload_resume_pdf_usecase.dart';

part 'application_provider.g.dart';

@riverpod
ApplicationRepository applicationRepository(Ref ref) {
  return ApplicationRepositoryImpl(
    ApplicationDatasourceImpl(Supabase.instance.client),
  );
}

@riverpod
ResumePdfService resumePdfService(Ref ref) => const ResumePdfService();

@riverpod
CreateBuilderResumeUseCase createBuilderResumeUseCase(Ref ref) {
  return CreateBuilderResumeUseCase(
    repository: ref.watch(applicationRepositoryProvider),
    pdfService: ref.watch(resumePdfServiceProvider),
  );
}

@riverpod
UploadResumePdfUseCase uploadResumePdfUseCase(Ref ref) {
  return UploadResumePdfUseCase(ref.watch(applicationRepositoryProvider));
}

@riverpod
ApplyToJobUseCase applyToJobUseCase(Ref ref) {
  return ApplyToJobUseCase(ref.watch(applicationRepositoryProvider));
}

@riverpod
Future<List<Resume>> myResumes(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref
      .watch(applicationRepositoryProvider)
      .getMyResumes(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

@riverpod
Future<List<int>> resumeBytes(Ref ref, String relativePath) async {
  final result = await ref
      .watch(applicationRepositoryProvider)
      .downloadResumeBytes(relativePath);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bytes) => bytes,
  );
}

@riverpod
Future<List<Application>> myApplications(
  Ref ref,
  ApplicationStatusFilter filter,
) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref
      .watch(applicationRepositoryProvider)
      .getMyApplications(seekerId: auth.userId, status: filter.value);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

@riverpod
Future<Application?> myApplicationForJob(Ref ref, String jobId) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return null;
  final result = await ref
      .watch(applicationRepositoryProvider)
      .getApplicationForJob(seekerId: auth.userId, jobId: jobId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

@riverpod
Future<Application?> myApplicationDetail(Ref ref, String applicationId) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return null;
  final result = await ref
      .watch(applicationRepositoryProvider)
      .getApplicationByIdForSeeker(
        seekerId: auth.userId,
        applicationId: applicationId,
      );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

@riverpod
Future<List<RecruiterApplication>> applicants(Ref ref, String jobId) async {
  final result = await ref
      .watch(applicationRepositoryProvider)
      .getApplicants(jobId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

@riverpod
Future<RecruiterApplication?> applicantDetail(
  Ref ref,
  String applicationId,
) async {
  final result = await ref
      .watch(applicationRepositoryProvider)
      .getApplicantDetail(applicationId: applicationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}

@riverpod
class ResumeActionNotifier extends _$ResumeActionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Either<Failure, Resume>> createBuilderResume({
    required String userId,
    required String title,
    required ResumeContent content,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(createBuilderResumeUseCaseProvider)
        .call(userId: userId, title: title, content: content);
    state = const AsyncData(null);
    if (result is Right<Failure, Resume>) {
      ref.invalidate(myResumesProvider);
    }
    return result;
  }

  Future<Either<Failure, Resume>> uploadResumePdf({
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(uploadResumePdfUseCaseProvider)
        .call(
          userId: userId,
          title: title,
          pdfBytes: pdfBytes,
          fileName: fileName,
        );
    state = const AsyncData(null);
    if (result is Right<Failure, Resume>) {
      ref.invalidate(myResumesProvider);
    }
    return result;
  }

  Future<Either<Failure, Resume>> updateBuilderResume({
    required String resumeId,
    required String userId,
    required String title,
    required ResumeContent content,
    required String currentFileUrl,
  }) async {
    state = const AsyncLoading();
    final pdfBytes = await ref
        .read(resumePdfServiceProvider)
        .buildPdf(title: title, content: content);
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateBuilderResume(
          resumeId: resumeId,
          userId: userId,
          title: title,
          content: content,
          pdfBytes: pdfBytes,
          currentFileUrl: currentFileUrl,
        );
    state = const AsyncData(null);
    if (result is Right<Failure, Resume>) {
      ref.invalidate(myResumesProvider);
    }
    return result;
  }

  Future<Either<Failure, Resume>> updateUploadedResume({
    required String resumeId,
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
    required String currentFileUrl,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateUploadedResume(
          resumeId: resumeId,
          userId: userId,
          title: title,
          pdfBytes: pdfBytes,
          fileName: fileName,
          currentFileUrl: currentFileUrl,
        );
    state = const AsyncData(null);
    if (result is Right<Failure, Resume>) {
      ref.invalidate(myResumesProvider);
    }
    return result;
  }

  Future<Either<Failure, void>> deleteResume({
    required String userId,
    required String resumeId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applicationRepositoryProvider)
        .deleteResume(userId: userId, resumeId: resumeId);
    state = const AsyncData(null);
    result.fold((_) {}, (_) => ref.invalidate(myResumesProvider));
    return result;
  }

  Future<Either<Failure, void>> setDefaultResume({
    required String userId,
    required String resumeId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applicationRepositoryProvider)
        .setDefaultResume(userId: userId, resumeId: resumeId);
    state = const AsyncData(null);
    result.fold((_) {}, (_) => ref.invalidate(myResumesProvider));
    return result;
  }
}

@riverpod
class ApplicationActionNotifier extends _$ApplicationActionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Either<Failure, ({String action})>> apply({
    required String seekerId,
    required String jobId,
    required String resumeUrl,
    String? coverLetter,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applyToJobUseCaseProvider)
        .call(
          seekerId: seekerId,
          jobId: jobId,
          resumeUrl: resumeUrl,
          coverLetter: coverLetter,
        );
    state = const AsyncData(null);
    result.fold((_) {}, (_) {
      ref.invalidate(myApplicationsProvider);
      ref.invalidate(myApplicationForJobProvider(jobId));
      ref.invalidate(applicantsProvider(jobId));
    });
    return result;
  }

  Future<Either<Failure, void>> withdraw({
    required String seekerId,
    required String applicationId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applicationRepositoryProvider)
        .withdrawApplication(seekerId: seekerId, applicationId: applicationId);
    state = const AsyncData(null);
    result.fold((_) {}, (_) {
      ref.invalidate(myApplicationsProvider);
      ref.invalidate(myApplicationDetailProvider(applicationId));
    });
    return result;
  }

  Future<Either<Failure, void>> updateWithNote({
    required String applicationId,
    required String status,
    required String note,
    String? jobId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateApplicationWithNote(
          applicationId: applicationId,
          status: status,
          note: note,
        );
    state = const AsyncData(null);
    result.fold((_) {}, (_) {
      ref.invalidate(applicantDetailProvider(applicationId));
      if (jobId != null) ref.invalidate(applicantsProvider(jobId));
      ref.invalidate(myApplicationsProvider);
    });
    return result;
  }

  Future<Either<Failure, void>> scheduleInterview({
    required String applicationId,
    required DateTime scheduledAt,
    required String location,
    required String note,
    String? jobId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateApplicationWithInterview(
          applicationId: applicationId,
          scheduledAt: scheduledAt,
          location: location,
          note: note,
        );
    state = const AsyncData(null);
    result.fold((_) {}, (_) {
      ref.invalidate(applicantDetailProvider(applicationId));
      if (jobId != null) ref.invalidate(applicantsProvider(jobId));
      ref.invalidate(myApplicationsProvider);
    });
    return result;
  }
}
