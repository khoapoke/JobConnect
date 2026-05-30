import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/resume.dart';
import '../repositories/application_repository.dart';

class UploadResumePdfUseCase {
  const UploadResumePdfUseCase(this._repository);

  final ApplicationRepository _repository;

  static const int maxBytes = 5 * 1024 * 1024;

  Future<Either<Failure, Resume>> call({
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
  }) async {
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      return const Left(StorageFailure(message: 'Chỉ hỗ trợ file PDF'));
    }
    if (pdfBytes.length > maxBytes) {
      return const Left(
        StorageFailure(message: 'PDF phải nhỏ hơn hoặc bằng 5MB'),
      );
    }

    final resumesResult = await _repository.getMyResumes(userId);

    return switch (resumesResult) {
      Left<Failure, List<Resume>>(value: final failure) => Left(failure),
      Right<Failure, List<Resume>>(value: final resumes) =>
        _repository.uploadResumePdf(
          userId: userId,
          title: title,
          pdfBytes: pdfBytes,
          fileName: fileName,
          isDefault: resumes.isEmpty,
        ),
    };
  }
}
