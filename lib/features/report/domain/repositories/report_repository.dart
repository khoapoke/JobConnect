import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';

abstract class ReportRepository {
  Future<Either<Failure, void>> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
    Map<String, dynamic>? targetSnapshot,
  });

  Future<Either<Failure, bool>> checkDuplicate({
    required String targetType,
    required String targetId,
  });
}
