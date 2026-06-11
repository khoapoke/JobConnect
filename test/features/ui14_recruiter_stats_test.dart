import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/core/errors/failure.dart';
import 'package:job_connect/core/utils/either.dart';
import 'package:job_connect/features/recruiter/data/datasources/recruiter_stats_datasource.dart';
import 'package:job_connect/features/recruiter/data/repositories/recruiter_stats_repository_impl.dart';
import 'package:job_connect/features/recruiter/domain/entities/recruiter_stats.dart';

/// Fake datasource so the repository can be exercised without Supabase —
/// proving the layer fix: presentation no longer talks to Supabase directly.
class _FakeDatasource implements RecruiterStatsDatasource {
  _FakeDatasource(this._result);
  final Either<Failure, RecruiterStats> _result;

  @override
  Future<Either<Failure, RecruiterStats>> getStats(String recruiterId) async =>
      _result;
}

void main() {
  group('RecruiterStatsRepositoryImpl', () {
    test('passes the datasource success through unchanged', () async {
      const stats = RecruiterStats(
        activePosts: 3,
        pendingApplications: 7,
        upcomingInterviews: 1,
        recentApplicants: [
          RecentApplicant(id: 'a1', fullName: 'Ngọc', jobTitle: 'Dev'),
        ],
        activeJobPosts: [
          ActiveJobPostSummary(id: 'p1', title: 'Flutter Dev', applicantCount: 4),
        ],
      );
      final repo = RecruiterStatsRepositoryImpl(
        _FakeDatasource(const Right(stats)),
      );

      final result = await repo.getStats('recruiter-1');

      final value = result.fold<RecruiterStats?>((_) => null, (r) => r);
      expect(value, isNotNull);
      expect(value!.activePosts, 3);
      expect(value.pendingApplications, 7);
      expect(value.recentApplicants.single.fullName, 'Ngọc');
      expect(value.activeJobPosts.single.applicantCount, 4);
    });

    test('passes a datasource failure through unchanged', () async {
      final repo = RecruiterStatsRepositoryImpl(
        _FakeDatasource(const Left(DatabaseFailure(message: 'boom'))),
      );

      final result = await repo.getStats('recruiter-1');

      final message = result.fold<String?>((f) => f.message, (_) => null);
      expect(message, 'boom');
    });
  });

  test('RecruiterStats.empty is all-zero with no rows', () {
    const empty = RecruiterStats.empty;
    expect(empty.activePosts, 0);
    expect(empty.pendingApplications, 0);
    expect(empty.upcomingInterviews, 0);
    expect(empty.recentApplicants, isEmpty);
    expect(empty.activeJobPosts, isEmpty);
  });
}
