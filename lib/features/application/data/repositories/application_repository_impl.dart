import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/recruiter_application.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_content.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_datasource.dart';
import '../models/resume_model.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  const ApplicationRepositoryImpl(this._datasource);

  final ApplicationDatasource _datasource;

  @override
  Future<Either<Failure, List<Resume>>> getMyResumes(String userId) async {
    final result = await _datasource.getMyResumes(userId);
    return result.fold(
      Left.new,
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, Resume>> createBuilderResume({
    required String userId,
    required String title,
    required ResumeContent content,
    required List<int> pdfBytes,
    required bool isDefault,
  }) async {
    final result = await _datasource.createResume(
      userId: userId,
      title: title,
      contentJson: ResumeContentModel.fromEntity(content).toJson(),
      pdfBytes: Uint8List.fromList(pdfBytes),
      fileName: _buildFileName(title),
      isDefault: isDefault,
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, Resume>> uploadResumePdf({
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
    required bool isDefault,
  }) async {
    final result = await _datasource.createResume(
      userId: userId,
      title: title,
      contentJson: null,
      pdfBytes: Uint8List.fromList(pdfBytes),
      fileName: fileName,
      isDefault: isDefault,
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, Resume>> updateBuilderResume({
    required String resumeId,
    required String userId,
    required String title,
    required ResumeContent content,
    required List<int> pdfBytes,
    required String currentFileUrl,
  }) async {
    final result = await _datasource.updateResume(
      resumeId: resumeId,
      userId: userId,
      title: title,
      contentJson: ResumeContentModel.fromEntity(content).toJson(),
      pdfBytes: Uint8List.fromList(pdfBytes),
      fileName: _buildFileName(title),
      currentFileUrl: currentFileUrl,
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, Resume>> updateUploadedResume({
    required String resumeId,
    required String userId,
    required String title,
    required List<int> pdfBytes,
    required String fileName,
    required String currentFileUrl,
  }) async {
    final result = await _datasource.updateResume(
      resumeId: resumeId,
      userId: userId,
      title: title,
      contentJson: null,
      pdfBytes: Uint8List.fromList(pdfBytes),
      fileName: fileName,
      currentFileUrl: currentFileUrl,
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, void>> deleteResume({
    required String userId,
    required String resumeId,
  }) {
    return _datasource.deleteResume(userId: userId, resumeId: resumeId);
  }

  @override
  Future<Either<Failure, void>> setDefaultResume({
    required String userId,
    required String resumeId,
  }) {
    return _datasource.setDefaultResume(userId: userId, resumeId: resumeId);
  }

  @override
  Future<Either<Failure, List<int>>> downloadResumeBytes(String relativePath) {
    return _datasource.downloadResumeBytes(relativePath);
  }

  @override
  Future<Either<Failure, Application?>> getApplicationForJob({
    required String seekerId,
    required String jobId,
  }) async {
    final result = await _datasource.getApplicationForJob(
      seekerId: seekerId,
      jobId: jobId,
    );
    return result.fold(Left.new, (model) => Right(model?.toEntity()));
  }

  @override
  Future<Either<Failure, void>> applyToJob({
    required String seekerId,
    required String jobId,
    required String resumeUrl,
    String? coverLetter,
  }) {
    return _datasource.applyToJob(
      seekerId: seekerId,
      jobId: jobId,
      resumeUrl: resumeUrl,
      coverLetter: coverLetter,
    );
  }

  @override
  Future<Either<Failure, void>> updateJobApplication({
    required String seekerId,
    required String applicationId,
    required String resumeUrl,
    String? coverLetter,
    required bool resetToPending,
  }) {
    return _datasource.updateJobApplication(
      seekerId: seekerId,
      applicationId: applicationId,
      resumeUrl: resumeUrl,
      coverLetter: coverLetter,
      resetToPending: resetToPending,
    );
  }

  @override
  Future<Either<Failure, List<Application>>> getMyApplications({
    required String seekerId,
    String? status,
  }) async {
    final result = await _datasource.getMyApplications(
      seekerId: seekerId,
      status: status,
    );
    return result.fold(
      Left.new,
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, Application?>> getApplicationByIdForSeeker({
    required String seekerId,
    required String applicationId,
  }) async {
    final result = await _datasource.getApplicationByIdForSeeker(
      seekerId: seekerId,
      applicationId: applicationId,
    );
    return result.fold(Left.new, (model) => Right(model?.toEntity()));
  }

  @override
  Future<Either<Failure, void>> withdrawApplication({
    required String seekerId,
    required String applicationId,
  }) {
    return _datasource.withdrawApplication(
      seekerId: seekerId,
      applicationId: applicationId,
    );
  }

  @override
  Future<Either<Failure, List<RecruiterApplication>>> getApplicants(
    String jobId,
  ) async {
    final result = await _datasource.getApplicants(jobId);
    return result.fold(
      Left.new,
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, RecruiterApplication?>> getApplicantDetail({
    required String applicationId,
  }) async {
    final result = await _datasource.getApplicantDetail(
      applicationId: applicationId,
    );
    return result.fold(Left.new, (model) => Right(model?.toEntity()));
  }

  @override
  Future<Either<Failure, void>> updateApplicationWithNote({
    required String applicationId,
    required String status,
    required String note,
  }) {
    return _datasource.updateApplicationWithNote(
      applicationId: applicationId,
      status: status,
      note: note,
    );
  }

  @override
  Future<Either<Failure, void>> updateApplicationWithInterview({
    required String applicationId,
    required DateTime scheduledAt,
    required String location,
    required String note,
  }) {
    return _datasource.updateApplicationWithInterview(
      applicationId: applicationId,
      scheduledAt: scheduledAt,
      location: location,
      note: note,
    );
  }

  String _buildFileName(String title) {
    final normalized = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${normalized.isEmpty ? 'resume' : normalized}-$timestamp.pdf';
  }
}
