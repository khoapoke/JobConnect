import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/skill_gap_advice.dart';
import '../repositories/skill_gap_repository.dart';

class GetSkillGapAdviceUseCase {
  const GetSkillGapAdviceUseCase(this._repository);

  final SkillGapRepository _repository;

  Future<Either<Failure, SkillGapAdvice>> call(String jobId) {
    return _repository.getSkillGapAdvice(jobId);
  }
}
