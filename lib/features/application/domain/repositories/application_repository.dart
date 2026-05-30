import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/application.dart';
import '../entities/recruiter_application.dart';
import '../entities/resume.dart';
import '../entities/resume_content.dart';

abstract class ApplicationRepository {
  Future<Either<Failure, List<Resume>>> getMyResumes(String userId);
  Future<Either<Failure, Resume>> createBuilderResume({
    required String userId,
    required String title,
    required ResumeContent content,
    required List<int> pdfBytes,
    required bool isDefault,
  });
  Future<Either<Failure, Resume>> uploadResumePdf({
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
    required bool isDefault,
  });
  Future<Either<Failure, Resume>> updateBuilderResume({
    required String resumeId,
    required String userId,
    required String title,
    required ResumeContent content,
    required List<int> pdfBytes,
    required String currentFileUrl,
  });
  Future<Either<Failure, Resume>> updateUploadedResume({
    required String resumeId,
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
    required String currentFileUrl,
  });
  Future<Either<Failure, void>> deleteResume({
    required String userId,
    required String resumeId,
  });
  Future<Either<Failure, void>> setDefaultResume({
    required String userId,
    required String resumeId,
  });
  Future<Either<Failure, List<int>>> downloadResumeBytes(String relativePath);
  Future<Either<Failure, Application?>> getApplicationForJob({
    required String seekerId,
    required String jobId,
  });
  Future<Either<Failure, void>> applyToJob({
    required String seekerId,
    required String jobId,
    required String resumeUrl,
    String? coverLetter,
  });
  Future<Either<Failure, void>> updateJobApplication({
    required String seekerId,
    required String applicationId,
    required String resumeUrl,
    String? coverLetter,
    required bool resetToPending,
  });
  Future<Either<Failure, List<Application>>> getMyApplications({
    required String seekerId,
    String? status,
  });
  Future<Either<Failure, Application?>> getApplicationByIdForSeeker({
    required String seekerId,
    required String applicationId,
  });
  Future<Either<Failure, void>> withdrawApplication({
    required String seekerId,
    required String applicationId,
  });
  Future<Either<Failure, List<RecruiterApplication>>> getApplicants(
    String jobId,
  );
  Future<Either<Failure, RecruiterApplication?>> getApplicantDetail({
    required String applicationId,
  });
  Future<Either<Failure, void>> updateApplicationWithNote({
    required String applicationId,
    required String status,
    required String note,
  });
  Future<Either<Failure, void>> updateApplicationWithInterview({
    required String applicationId,
    required DateTime scheduledAt,
    required String location,
    required String note,
  });
}
