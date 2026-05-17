import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../auth/data/models/profile_model.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/entities/work_experience.dart';
import '../models/certificate_model.dart';
import '../models/education_model.dart';
import '../models/skill_model.dart';
import '../models/user_skill_model.dart';
import '../models/work_experience_model.dart';

/// Supabase calls for profile operations.
abstract class ProfileDatasource {
  Future<Either<Failure, UserProfile>> getProfile(String userId);
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  );
  Future<Either<Failure, String>> uploadAvatar(Uint8List bytes, String ext);

  // T-11: Work Experiences
  Future<List<WorkExperienceModel>> getWorkExperiences(String userId);
  Future<void> addWorkExperience(WorkExperience entity);
  Future<void> updateWorkExperience(WorkExperience entity);
  Future<void> deleteWorkExperience(String id);

  // T-11: Educations
  Future<List<EducationModel>> getEducations(String userId);
  Future<void> addEducation(Education entity);
  Future<void> updateEducation(Education entity);
  Future<void> deleteEducation(String id);

  // T-11: Certificates
  Future<List<CertificateModel>> getCertificates(String userId);
  Future<void> addCertificate(Certificate entity);
  Future<void> updateCertificate(Certificate entity);
  Future<void> deleteCertificate(String id);

  // T-12: Skills
  Future<List<SkillModel>> getAvailableSkills();
  Future<List<UserSkillModel>> getUserSkills(String userId);
  Future<void> addUserSkill(String userId, String skillId, String level);
  Future<void> updateUserSkillLevel(
    String userId,
    String skillId,
    String level,
  );
  Future<void> deleteUserSkill(String userId, String skillId);
}

class ProfileDatasourceImpl implements ProfileDatasource {
  const ProfileDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = ProfileModel.fromJson(response).toEntity();
      return Right(profile);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update(update.toJson())
          .eq('id', userId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(
    Uint8List bytes,
    String ext,
  ) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final storagePath = 'avatars/$userId/avatar.$ext';

      // 1. Delete existing avatar files
      final existingFiles = await _supabase.storage
          .from('public-assets')
          .list(path: 'avatars/$userId');
      if (existingFiles.isNotEmpty) {
        await _supabase.storage.from('public-assets').remove(
              existingFiles
                  .map((f) => 'avatars/$userId/${f.name}')
                  .toList(),
            );
      }

      // 2. Upload new avatar
      await _supabase.storage.from('public-assets').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

      return Right(storagePath);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  // ─── T-11: Work Experiences ─────────────────────────────────────────

  @override
  Future<List<WorkExperienceModel>> getWorkExperiences(String userId) async {
    final data = await _supabase
        .from('work_experiences')
        .select()
        .eq('user_id', userId)
        .order('from_date', ascending: false);
    return data.map(WorkExperienceModel.fromJson).toList();
  }

  @override
  Future<void> addWorkExperience(WorkExperience entity) async {
    await _supabase.from('work_experiences').insert({
      'user_id': entity.userId,
      'company': entity.company,
      'role': entity.role,
      'from_date': entity.fromDate.toIso8601String().split('T')[0],
      'to_date': entity.toDate?.toIso8601String().split('T')[0],
      'description': entity.description,
      'is_current': entity.isCurrent,
    });
  }

  @override
  Future<void> updateWorkExperience(WorkExperience entity) async {
    await _supabase.from('work_experiences').update({
      'company': entity.company,
      'role': entity.role,
      'from_date': entity.fromDate.toIso8601String().split('T')[0],
      'to_date': entity.toDate?.toIso8601String().split('T')[0],
      'description': entity.description,
      'is_current': entity.isCurrent,
    }).eq('id', entity.id);
  }

  @override
  Future<void> deleteWorkExperience(String id) async {
    await _supabase.from('work_experiences').delete().eq('id', id);
  }

  // ─── T-11: Educations ──────────────────────────────────────────────

  @override
  Future<List<EducationModel>> getEducations(String userId) async {
    final data = await _supabase
        .from('educations')
        .select()
        .eq('user_id', userId)
        .order('from_date', ascending: false);
    return data.map(EducationModel.fromJson).toList();
  }

  @override
  Future<void> addEducation(Education entity) async {
    await _supabase.from('educations').insert({
      'user_id': entity.userId,
      'school': entity.school,
      'from_date': entity.fromDate.toIso8601String().split('T')[0],
      'to_date': entity.toDate?.toIso8601String().split('T')[0],
      'degree': entity.degree,
      'major': entity.major,
    });
  }

  @override
  Future<void> updateEducation(Education entity) async {
    await _supabase.from('educations').update({
      'school': entity.school,
      'from_date': entity.fromDate.toIso8601String().split('T')[0],
      'to_date': entity.toDate?.toIso8601String().split('T')[0],
      'degree': entity.degree,
      'major': entity.major,
    }).eq('id', entity.id);
  }

  @override
  Future<void> deleteEducation(String id) async {
    await _supabase.from('educations').delete().eq('id', id);
  }

  // ─── T-11: Certificates ────────────────────────────────────────────

  @override
  Future<List<CertificateModel>> getCertificates(String userId) async {
    final data = await _supabase
        .from('certificates')
        .select()
        .eq('user_id', userId)
        .order('issued_at', ascending: false);
    return data.map(CertificateModel.fromJson).toList();
  }

  @override
  Future<void> addCertificate(Certificate entity) async {
    await _supabase.from('certificates').insert({
      'user_id': entity.userId,
      'name': entity.name,
      'issuer': entity.issuer,
      'issued_at': entity.issuedAt?.toIso8601String().split('T')[0],
      'credential_url': entity.credentialUrl,
    });
  }

  @override
  Future<void> updateCertificate(Certificate entity) async {
    await _supabase.from('certificates').update({
      'name': entity.name,
      'issuer': entity.issuer,
      'issued_at': entity.issuedAt?.toIso8601String().split('T')[0],
      'credential_url': entity.credentialUrl,
    }).eq('id', entity.id);
  }

  @override
  Future<void> deleteCertificate(String id) async {
    await _supabase.from('certificates').delete().eq('id', id);
  }

  // ─── T-12: Skills ───────────────────────────────────────────────────

  @override
  Future<List<SkillModel>> getAvailableSkills() async {
    final data = await _supabase
        .from('skills')
        .select('*, job_categories(name)')
        .order('name');
    return data.map(SkillModel.fromJson).toList();
  }

  @override
  Future<List<UserSkillModel>> getUserSkills(String userId) async {
    final data = await _supabase
        .from('user_skills')
        .select('*, skills(name, category_id)')
        .eq('user_id', userId);
    // Sort in Dart — .order('skills(name)') is unreliable
    data.sort((a, b) {
      final aSkills = a['skills'] as Map<String, dynamic>?;
      final bSkills = b['skills'] as Map<String, dynamic>?;
      final aName = (aSkills?['name'] as String?) ?? '';
      final bName = (bSkills?['name'] as String?) ?? '';
      return aName.compareTo(bName);
    });
    return data.map(UserSkillModel.fromJson).toList();
  }

  @override
  Future<void> addUserSkill(
    String userId,
    String skillId,
    String level,
  ) async {
    await _supabase.from('user_skills').insert({
      'user_id': userId,
      'skill_id': skillId,
      'level': level,
    });
  }

  @override
  Future<void> updateUserSkillLevel(
    String userId,
    String skillId,
    String level,
  ) async {
    // DELETE + INSERT instead of UPDATE because the user_skills table
    // may lack an UPDATE RLS policy. PostgREST silently returns success
    // with 0 rows affected when UPDATE is blocked by RLS.
    await _supabase
        .from('user_skills')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId);
    await _supabase.from('user_skills').insert({
      'user_id': userId,
      'skill_id': skillId,
      'level': level,
    });
  }

  @override
  Future<void> deleteUserSkill(String userId, String skillId) async {
    await _supabase
        .from('user_skills')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId);
  }
}
