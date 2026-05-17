import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../entities/certificate.dart';
import '../entities/education.dart';
import '../entities/profile_update.dart';
import '../entities/skill.dart';
import '../entities/user_skill.dart';
import '../entities/work_experience.dart';

/// Abstract interface for profile data operations.
abstract class ProfileRepository {
  /// Fetches the profile for the given [userId].
  Future<Either<Failure, UserProfile>> getProfile(String userId);

  /// Updates the profile with the given [update] data.
  Future<Either<Failure, void>> updateProfile(
    String userId,
    ProfileUpdate update,
  );

  /// Uploads an avatar image and returns the relative storage path.
  ///
  /// Flow: delete existing → upload new → return path.
  Future<Either<Failure, String>> uploadAvatar(Uint8List bytes, String ext);

  // ─── T-11: Work Experiences ─────────────────────────────────────────

  Future<Either<Failure, List<WorkExperience>>> getWorkExperiences(
    String userId,
  );
  Future<Either<Failure, void>> addWorkExperience(WorkExperience entity);
  Future<Either<Failure, void>> updateWorkExperience(WorkExperience entity);
  Future<Either<Failure, void>> deleteWorkExperience(String id);

  // ─── T-11: Educations ──────────────────────────────────────────────

  Future<Either<Failure, List<Education>>> getEducations(String userId);
  Future<Either<Failure, void>> addEducation(Education entity);
  Future<Either<Failure, void>> updateEducation(Education entity);
  Future<Either<Failure, void>> deleteEducation(String id);

  // ─── T-11: Certificates ────────────────────────────────────────────

  Future<Either<Failure, List<Certificate>>> getCertificates(String userId);
  Future<Either<Failure, void>> addCertificate(Certificate entity);
  Future<Either<Failure, void>> updateCertificate(Certificate entity);
  Future<Either<Failure, void>> deleteCertificate(String id);

  // ─── T-12: Skills ───────────────────────────────────────────────────

  Future<Either<Failure, List<Skill>>> getAvailableSkills();
  Future<Either<Failure, List<UserSkill>>> getUserSkills(String userId);
  Future<Either<Failure, void>> addUserSkill(
    String userId,
    String skillId,
    String level,
  );
  Future<Either<Failure, void>> updateUserSkillLevel(
    String userId,
    String skillId,
    String level,
  );
  Future<Either<Failure, void>> deleteUserSkill(
    String userId,
    String skillId,
  );
}
