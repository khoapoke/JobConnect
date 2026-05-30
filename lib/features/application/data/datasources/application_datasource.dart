import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/storage_utils.dart';
import '../mappers/application_error_mapper.dart';
import '../models/application_model.dart';
import '../models/recruiter_application_model.dart';
import '../models/resume_model.dart';

abstract class ApplicationDatasource {
  Future<Either<Failure, List<ResumeModel>>> getMyResumes(String userId);
  Future<Either<Failure, ResumeModel>> createResume({
    required String userId,
    required String title,
    required Map<String, dynamic>? contentJson,
    required Uint8List pdfBytes,
    required String fileName,
    required bool isDefault,
  });
  Future<Either<Failure, ResumeModel>> updateResume({
    required String resumeId,
    required String userId,
    required String title,
    required Map<String, dynamic>? contentJson,
    required Uint8List pdfBytes,
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
  Future<Either<Failure, ApplicationModel?>> getApplicationForJob({
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
  Future<Either<Failure, List<ApplicationModel>>> getMyApplications({
    required String seekerId,
    String? status,
  });
  Future<Either<Failure, ApplicationModel?>> getApplicationByIdForSeeker({
    required String seekerId,
    required String applicationId,
  });
  Future<Either<Failure, void>> withdrawApplication({
    required String seekerId,
    required String applicationId,
  });
  Future<Either<Failure, List<RecruiterApplicationModel>>> getApplicants(
    String jobId,
  );
  Future<Either<Failure, RecruiterApplicationModel?>> getApplicantDetail({
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

class ApplicationDatasourceImpl implements ApplicationDatasource {
  const ApplicationDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, List<ResumeModel>>> getMyResumes(String userId) async {
    try {
      final data = await _supabase
          .from('resumes')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('updated_at', ascending: false);

      final resumes = (data as List<dynamic>)
          .map((json) => ResumeModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(resumes);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, ResumeModel>> createResume({
    required String userId,
    required String title,
    required Map<String, dynamic>? contentJson,
    required Uint8List pdfBytes,
    required String fileName,
    required bool isDefault,
  }) async {
    try {
      final path = await _uploadResumePdf(
        userId: userId,
        fileName: fileName,
        pdfBytes: pdfBytes,
      );

      final response = await _supabase
          .from('resumes')
          .insert({
            'user_id': userId,
            'title': title,
            'content_json': contentJson,
            'file_url': path,
            'is_default': isDefault,
          })
          .select()
          .single();

      return Right(ResumeModel.fromJson(response));
    } on StorageException catch (e) {
      return Left(ApplicationErrorMapper.fromStorage(e));
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, ResumeModel>> updateResume({
    required String resumeId,
    required String userId,
    required String title,
    required Map<String, dynamic>? contentJson,
    required Uint8List pdfBytes,
    required String fileName,
    required String currentFileUrl,
  }) async {
    try {
      final path = await _uploadResumePdf(
        userId: userId,
        fileName: fileName,
        pdfBytes: pdfBytes,
      );

      final response = await _supabase
          .from('resumes')
          .update({
            'title': title,
            'content_json': contentJson,
            'file_url': path,
          })
          .eq('user_id', userId)
          .eq('id', resumeId)
          .select()
          .maybeSingle();

      if (response == null) {
        return const Left(
          DatabaseFailure(message: 'Không thể cập nhật Resume.'),
        );
      }

      if (currentFileUrl != path) {
        await _supabase.storage.from('private-files').remove([currentFileUrl]);
      }

      return Right(ResumeModel.fromJson(response));
    } on StorageException catch (e) {
      return Left(ApplicationErrorMapper.fromStorage(e));
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume({
    required String userId,
    required String resumeId,
  }) async {
    try {
      final existing = await _supabase
          .from('resumes')
          .select('file_url, is_default')
          .eq('user_id', userId)
          .eq('id', resumeId)
          .maybeSingle();

      if (existing == null) {
        return const Left(DatabaseFailure(message: 'Resume không tồn tại.'));
      }

      final response = await _supabase
          .from('resumes')
          .delete()
          .eq('user_id', userId)
          .eq('id', resumeId)
          .select();

      if ((response as List<dynamic>).isEmpty) {
        return const Left(DatabaseFailure(message: 'Không thể xóa Resume.'));
      }

      final fileUrl = existing['file_url'] as String?;
      final isDefault = existing['is_default'] as bool? ?? false;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        await _supabase.storage.from('private-files').remove([fileUrl]);
      }
      if (isDefault) {
        await _reassignDefaultResume(userId);
      }

      return const Right(null);
    } on StorageException catch (e) {
      return Left(ApplicationErrorMapper.fromStorage(e));
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultResume({
    required String userId,
    required String resumeId,
  }) async {
    try {
      await _supabase
          .from('resumes')
          .update({'is_default': false})
          .eq('user_id', userId);
      final response = await _supabase
          .from('resumes')
          .update({'is_default': true})
          .eq('user_id', userId)
          .eq('id', resumeId)
          .select();

      if ((response as List<dynamic>).isEmpty) {
        return const Left(
          DatabaseFailure(message: 'Không thể cập nhật Resume mặc định.'),
        );
      }

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadResumeBytes(
    String relativePath,
  ) async {
    try {
      final url = await StorageUtils.signedUrl(relativePath);
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytesBuilder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        bytesBuilder.add(chunk);
      }
      client.close();
      return Right(bytesBuilder.takeBytes());
    } on StorageException catch (e) {
      return Left(ApplicationErrorMapper.fromStorage(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, ApplicationModel?>> getApplicationForJob({
    required String seekerId,
    required String jobId,
  }) async {
    try {
      final data = await _supabase
          .from('applications')
          .select(
            'id, job_id, seeker_id, resume_url, cover_letter, status, created_at, updated_at, '
            'job_posts!inner(id, title, status, companies!inner(name, logo_url)), '
            'interview_schedules(id, application_id, scheduled_at, location, note, status, created_at, updated_at)',
          )
          .eq('seeker_id', seekerId)
          .eq('job_id', jobId)
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(ApplicationModel.fromJson(data));
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> applyToJob({
    required String seekerId,
    required String jobId,
    required String resumeUrl,
    String? coverLetter,
  }) async {
    try {
      await _supabase.from('applications').insert({
        'seeker_id': seekerId,
        'job_id': jobId,
        'resume_url': resumeUrl,
        'cover_letter': coverLetter,
        'status': 'pending',
      });
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> updateJobApplication({
    required String seekerId,
    required String applicationId,
    required String resumeUrl,
    String? coverLetter,
    required bool resetToPending,
  }) async {
    try {
      final payload = <String, dynamic>{
        'resume_url': resumeUrl,
        'cover_letter': coverLetter,
      };
      if (resetToPending) {
        payload['status'] = 'pending';
      }

      final response = await _supabase
          .from('applications')
          .update(payload)
          .eq('seeker_id', seekerId)
          .eq('id', applicationId)
          .select();

      if ((response as List<dynamic>).isEmpty) {
        return const Left(
          DatabaseFailure(message: 'Không thể cập nhật Application.'),
        );
      }

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationModel>>> getMyApplications({
    required String seekerId,
    String? status,
  }) async {
    try {
      final baseQuery = _supabase
          .from('applications')
          .select(
            'id, job_id, seeker_id, resume_url, cover_letter, status, created_at, updated_at, '
            'job_posts!inner(id, title, status, companies!inner(name, logo_url)), '
            'interview_schedules(id, application_id, scheduled_at, location, note, status, created_at, updated_at)',
          )
          .eq('seeker_id', seekerId);

      final data =
          await (status == null ? baseQuery : baseQuery.eq('status', status))
              .order('created_at', ascending: false);
      final applications = (data as List<dynamic>)
          .map(
            (json) => ApplicationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Right(applications);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, ApplicationModel?>> getApplicationByIdForSeeker({
    required String seekerId,
    required String applicationId,
  }) async {
    try {
      final data = await _supabase
          .from('applications')
          .select(
            'id, job_id, seeker_id, resume_url, cover_letter, status, created_at, updated_at, '
            'job_posts!inner(id, title, status, companies!inner(name, logo_url)), '
            'interview_schedules(id, application_id, scheduled_at, location, note, status, created_at, updated_at)',
          )
          .eq('seeker_id', seekerId)
          .eq('id', applicationId)
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(ApplicationModel.fromJson(data));
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawApplication({
    required String seekerId,
    required String applicationId,
  }) async {
    try {
      final response = await _supabase
          .from('applications')
          .update({'status': 'withdrawn'})
          .eq('seeker_id', seekerId)
          .eq('id', applicationId)
          .eq('status', 'pending')
          .select();

      if ((response as List<dynamic>).isEmpty) {
        return const Left(
          DatabaseFailure(message: 'Không thể rút Application này.'),
        );
      }

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, List<RecruiterApplicationModel>>> getApplicants(
    String jobId,
  ) async {
    try {
      final data = await _supabase
          .from('applications')
          .select(
            'id, job_id, seeker_id, resume_url, cover_letter, status, created_at, '
            'profiles!applications_seeker_id_fkey(full_name, headline, avatar_url), '
            'job_posts!inner(title), '
            'application_notes(note, created_at), '
            'interview_schedules(id, application_id, scheduled_at, location, note, status, created_at, updated_at)',
          )
          .eq('job_id', jobId)
          .order('created_at', ascending: false);

      final applicants = (data as List<dynamic>)
          .map(
            (json) => RecruiterApplicationModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
      return Right(applicants);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, RecruiterApplicationModel?>> getApplicantDetail({
    required String applicationId,
  }) async {
    try {
      final data = await _supabase
          .from('applications')
          .select(
            'id, job_id, seeker_id, resume_url, cover_letter, status, created_at, '
            'profiles!applications_seeker_id_fkey(full_name, headline, avatar_url), '
            'job_posts!inner(title), '
            'application_notes(note, created_at), '
            'interview_schedules(id, application_id, scheduled_at, location, note, status, created_at, updated_at)',
          )
          .eq('id', applicationId)
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(RecruiterApplicationModel.fromJson(data));
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationWithNote({
    required String applicationId,
    required String status,
    required String note,
  }) async {
    try {
      await _supabase.rpc(
        'update_application_with_note',
        params: {
          'p_application_id': applicationId,
          'p_status': status,
          'p_note': note,
        },
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationWithInterview({
    required String applicationId,
    required DateTime scheduledAt,
    required String location,
    required String note,
  }) async {
    try {
      await _supabase.rpc(
        'update_application_with_interview',
        params: {
          'p_application_id': applicationId,
          'p_scheduled_at': scheduledAt.toIso8601String(),
          'p_location': location,
          'p_note': note,
        },
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ApplicationErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(ApplicationErrorMapper.fromUnknown(e, st));
    }
  }

  Future<String> _uploadResumePdf({
    required String userId,
    required String fileName,
    required Uint8List pdfBytes,
  }) async {
    final path = 'resumes/$userId/$fileName';
    await _supabase.storage
        .from('private-files')
        .uploadBinary(
          path,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
    return path;
  }

  Future<void> _reassignDefaultResume(String userId) async {
    final remaining = await _supabase
        .from('resumes')
        .select('id')
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (remaining == null) return;

    await _supabase
        .from('resumes')
        .update({'is_default': true})
        .eq('user_id', userId)
        .eq('id', remaining['id'] as String);
  }
}
