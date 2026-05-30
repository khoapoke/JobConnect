import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/application.dart';
import '../repositories/application_repository.dart';

class ApplyToJobUseCase {
  const ApplyToJobUseCase(this._repository);

  final ApplicationRepository _repository;

  Future<Either<Failure, ({String action})>> call({
    required String seekerId,
    required String jobId,
    required String resumeUrl,
    String? coverLetter,
  }) async {
    final existingResult = await _repository.getApplicationForJob(
      seekerId: seekerId,
      jobId: jobId,
    );

    return switch (existingResult) {
      Left<Failure, Application?>(value: final failure) => Left(failure),
      Right<Failure, Application?>(value: final application)
          when application == null =>
        _create(
          seekerId: seekerId,
          jobId: jobId,
          resumeUrl: resumeUrl,
          coverLetter: coverLetter,
        ),
      Right<Failure, Application?>(value: final application)
          when application!.status == 'pending' =>
        _update(
          seekerId: seekerId,
          applicationId: application.id,
          resumeUrl: resumeUrl,
          coverLetter: coverLetter,
          resetToPending: false,
          action: 'updated',
        ),
      Right<Failure, Application?>(value: final application)
          when application!.status == 'withdrawn' ||
              application.status == 'rejected' =>
        _update(
          seekerId: seekerId,
          applicationId: application.id,
          resumeUrl: resumeUrl,
          coverLetter: coverLetter,
          resetToPending: true,
          action: 'resubmitted',
        ),
      Right<Failure, Application?>(value: _) => const Left(
        DatabaseFailure(
          message: 'Bạn không thể chỉnh sửa Application ở trạng thái hiện tại',
        ),
      ),
    };
  }

  Future<Either<Failure, ({String action})>> _create({
    required String seekerId,
    required String jobId,
    required String resumeUrl,
    String? coverLetter,
  }) async {
    final result = await _repository.applyToJob(
      seekerId: seekerId,
      jobId: jobId,
      resumeUrl: resumeUrl,
      coverLetter: coverLetter,
    );
    return result.fold(Left.new, (_) => const Right((action: 'submitted')));
  }

  Future<Either<Failure, ({String action})>> _update({
    required String seekerId,
    required String applicationId,
    required String resumeUrl,
    String? coverLetter,
    required bool resetToPending,
    required String action,
  }) async {
    final result = await _repository.updateJobApplication(
      seekerId: seekerId,
      applicationId: applicationId,
      resumeUrl: resumeUrl,
      coverLetter: coverLetter,
      resetToPending: resetToPending,
    );
    return result.fold(Left.new, (_) => Right((action: action)));
  }
}
