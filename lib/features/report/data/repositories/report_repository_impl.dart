import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._datasource);

  final ReportDatasource _datasource;

  @override
  Future<Either<Failure, void>> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
    Map<String, dynamic>? targetSnapshot,
  }) async {
    try {
      await _datasource.submitReport(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        details: details,
        targetSnapshot: targetSnapshot,
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkDuplicate({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final dup = await _datasource.checkDuplicate(
        targetType: targetType,
        targetId: targetId,
      );
      return Right(dup);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
