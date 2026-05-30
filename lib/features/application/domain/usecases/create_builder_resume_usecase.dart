import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/resume.dart';
import '../entities/resume_content.dart';
import '../repositories/application_repository.dart';

abstract class ResumePdfBuilder {
  Future<List<int>> buildPdf({
    required String title,
    required ResumeContent content,
  });
}

class CreateBuilderResumeUseCase {
  const CreateBuilderResumeUseCase({
    required ApplicationRepository repository,
    required ResumePdfBuilder pdfService,
  }) : _repository = repository,
       _pdfService = pdfService;

  final ApplicationRepository _repository;
  final ResumePdfBuilder _pdfService;

  Future<Either<Failure, Resume>> call({
    required String userId,
    required String title,
    required ResumeContent content,
  }) async {
    final resumesResult = await _repository.getMyResumes(userId);

    return switch (resumesResult) {
      Left<Failure, List<Resume>>(value: final failure) => Left(failure),
      Right<Failure, List<Resume>>(value: final resumes) => _createResume(
        userId: userId,
        title: title,
        content: content,
        isDefault: resumes.isEmpty,
      ),
    };
  }

  Future<Either<Failure, Resume>> _createResume({
    required String userId,
    required String title,
    required ResumeContent content,
    required bool isDefault,
  }) async {
    final pdfBytes = await _pdfService.buildPdf(title: title, content: content);
    return _repository.createBuilderResume(
      userId: userId,
      title: title,
      content: content,
      pdfBytes: pdfBytes,
      isDefault: isDefault,
    );
  }
}
