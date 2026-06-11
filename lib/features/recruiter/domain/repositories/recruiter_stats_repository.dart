import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/recruiter_stats.dart';

abstract class RecruiterStatsRepository {
  Future<Either<Failure, RecruiterStats>> getStats(String recruiterId);
}
