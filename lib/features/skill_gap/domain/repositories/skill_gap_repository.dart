import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/skill_gap_advice.dart';

/// Repository for Skill Gap analysis and AI learning advice.
abstract class SkillGapRepository {
  /// Fetches AI-generated learning advice for the given [jobId].
  Future<Either<Failure, SkillGapAdvice>> getSkillGapAdvice(String jobId);
}
