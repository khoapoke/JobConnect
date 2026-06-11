import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/recruiter_stats.dart';
import '../../domain/repositories/recruiter_stats_repository.dart';
import '../datasources/recruiter_stats_datasource.dart';

/// Thin pass-through to datasource (same pattern as CompanyRepositoryImpl).
class RecruiterStatsRepositoryImpl implements RecruiterStatsRepository {
  const RecruiterStatsRepositoryImpl(this._datasource);

  final RecruiterStatsDatasource _datasource;

  @override
  Future<Either<Failure, RecruiterStats>> getStats(String recruiterId) {
    return _datasource.getStats(recruiterId);
  }
}
