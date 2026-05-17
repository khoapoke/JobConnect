import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/user_skill.dart';
import '../../domain/entities/work_experience.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileDatasource _datasource;

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    return _datasource.getProfile(userId);
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  ) async {
    return _datasource.updateProfile(userId, update);
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(
    Uint8List bytes,
    String ext,
  ) async {
    return _datasource.uploadAvatar(bytes, ext);
  }

  // ─── T-11: Work Experiences ─────────────────────────────────────────

  @override
  Future<Either<Failure, List<WorkExperience>>> getWorkExperiences(
    String userId,
  ) async {
    try {
      final models = await _datasource.getWorkExperiences(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addWorkExperience(
    WorkExperience entity,
  ) async {
    try {
      await _datasource.addWorkExperience(entity);
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
  Future<Either<Failure, void>> updateWorkExperience(
    WorkExperience entity,
  ) async {
    try {
      await _datasource.updateWorkExperience(entity);
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
  Future<Either<Failure, void>> deleteWorkExperience(String id) async {
    try {
      await _datasource.deleteWorkExperience(id);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  // ─── T-11: Educations ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Education>>> getEducations(
    String userId,
  ) async {
    try {
      final models = await _datasource.getEducations(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addEducation(Education entity) async {
    try {
      await _datasource.addEducation(entity);
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
  Future<Either<Failure, void>> updateEducation(Education entity) async {
    try {
      await _datasource.updateEducation(entity);
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
  Future<Either<Failure, void>> deleteEducation(String id) async {
    try {
      await _datasource.deleteEducation(id);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  // ─── T-11: Certificates ────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Certificate>>> getCertificates(
    String userId,
  ) async {
    try {
      final models = await _datasource.getCertificates(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addCertificate(Certificate entity) async {
    try {
      await _datasource.addCertificate(entity);
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
  Future<Either<Failure, void>> updateCertificate(Certificate entity) async {
    try {
      await _datasource.updateCertificate(entity);
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
  Future<Either<Failure, void>> deleteCertificate(String id) async {
    try {
      await _datasource.deleteCertificate(id);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  // ─── T-12: Skills ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Skill>>> getAvailableSkills() async {
    try {
      final models = await _datasource.getAvailableSkills();
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, List<UserSkill>>> getUserSkills(
    String userId,
  ) async {
    try {
      final models = await _datasource.getUserSkills(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addUserSkill(
    String userId,
    String skillId,
    String level,
  ) async {
    try {
      await _datasource.addUserSkill(userId, skillId, level);
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
  Future<Either<Failure, void>> updateUserSkillLevel(
    String userId,
    String skillId,
    String level,
  ) async {
    try {
      await _datasource.updateUserSkillLevel(userId, skillId, level);
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
  Future<Either<Failure, void>> deleteUserSkill(
    String userId,
    String skillId,
  ) async {
    try {
      await _datasource.deleteUserSkill(userId, skillId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e, st) {
      return Left(
        NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st),
      );
    }
  }
}
