import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:job_connect/core/errors/failure.dart';
import 'package:job_connect/core/utils/either.dart';
import 'package:job_connect/features/jobs/data/repositories/job_search_repository_impl.dart';
import 'package:job_connect/features/jobs/domain/entities/job_filter.dart';
import 'package:job_connect/features/jobs/domain/entities/job_search_result.dart';
import 'package:job_connect/features/jobs/domain/repositories/job_search_repository.dart';
import 'package:job_connect/features/jobs/presentation/pages/job_search_page.dart';
import 'package:job_connect/features/recruiter/domain/entities/company.dart';
import 'package:job_connect/features/recruiter/domain/entities/job_location.dart';
import 'package:job_connect/features/recruiter/domain/entities/job_post.dart';

void main() {
  testWidgets('does not show load-more spinner after a complete first page', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobSearchRepositoryProvider.overrideWithValue(
            _FakeJobSearchRepository([_jobSearchResult()]),
          ),
        ],
        child: const MaterialApp(home: JobSearchPage()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('1 việc làm'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _FakeJobSearchRepository implements JobSearchRepository {
  const _FakeJobSearchRepository(this._results);

  final List<JobSearchResult> _results;

  @override
  Future<Either<Failure, List<JobSearchResult>>> searchJobs({
    String? searchQuery,
    required JobFilter filter,
    String? cursor,
    int limit = 20,
  }) async {
    return Right(_results);
  }
}

JobSearchResult _jobSearchResult() {
  final now = DateTime(2026, 5, 29, 10);
  return JobSearchResult(
    jobPost: JobPost(
      id: 'job-1',
      companyId: 'company-1',
      title: 'Flutter Developer',
      salaryMin: 15000000,
      salaryMax: 25000000,
      isSalaryVisible: true,
      type: 'full_time',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    ),
    company: Company(
      id: 'company-1',
      recruiterId: 'recruiter-1',
      name: 'NAB',
      createdAt: now,
      updatedAt: now,
    ),
    location: JobLocation(
      id: 'location-1',
      jobId: 'job-1',
      province: 'Thành phố Hồ Chí Minh',
      isRemote: false,
      createdAt: now,
    ),
    skills: const [],
  );
}
