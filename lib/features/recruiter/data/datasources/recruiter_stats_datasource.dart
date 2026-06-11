import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/recruiter_stats.dart';
import '../mappers/recruiter_error_mapper.dart';

/// Supabase calls for the recruiter dashboard aggregate.
abstract class RecruiterStatsDatasource {
  Future<Either<Failure, RecruiterStats>> getStats(String recruiterId);
}

class RecruiterStatsDatasourceImpl implements RecruiterStatsDatasource {
  const RecruiterStatsDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, RecruiterStats>> getStats(String recruiterId) async {
    try {
      // Company IDs owned by this recruiter
      final companiesRes = await _supabase
          .from('companies')
          .select('id')
          .eq('recruiter_id', recruiterId);
      final companyIds = (companiesRes as List)
          .cast<Map<String, dynamic>>()
          .map((c) => c['id'] as String)
          .toList();

      if (companyIds.isEmpty) {
        return const Right(RecruiterStats.empty);
      }

      // Active posts
      final activePostsRes = await _supabase
          .from('job_posts')
          .select('id, title')
          .eq('status', 'active')
          .inFilter('company_id', companyIds);
      final activePosts = (activePostsRes as List).cast<Map<String, dynamic>>();
      final jobIds = activePosts.map((p) => p['id'] as String).toList();

      // Pending applications — counted separately so the limit(5) preview
      // below doesn't cap the badge number.
      var pendingCount = 0;
      var pendingApps = <Map<String, dynamic>>[];
      if (jobIds.isNotEmpty) {
        final pendingCountRes = await _supabase
            .from('applications')
            .select('id')
            .eq('status', 'pending')
            .inFilter('job_id', jobIds)
            .count(CountOption.exact);
        pendingCount = pendingCountRes.count;

        final pendingAppsRes = await _supabase
            .from('applications')
            .select(
                'id, seeker_id, job_id, created_at, status, profiles!inner(full_name, avatar_url), job_posts!inner(title)')
            .eq('status', 'pending')
            .inFilter('job_id', jobIds)
            .order('created_at', ascending: false)
            .limit(5);
        pendingApps = (pendingAppsRes as List).cast<Map<String, dynamic>>();
      }

      // Upcoming interviews
      final interviewsRes = await _supabase
          .from('interview_schedules')
          .select('id')
          .gte('scheduled_at', DateTime.now().toIso8601String());
      final interviews = (interviewsRes as List).cast<Map<String, dynamic>>();

      final recentApplicants = pendingApps.map((a) {
        final profile = a['profiles'] as Map<String, dynamic>?;
        final job = a['job_posts'] as Map<String, dynamic>?;
        return RecentApplicant(
          id: a['id'] as String,
          fullName: (profile?['full_name'] as String?) ?? 'Ứng viên',
          avatarUrl: profile?['avatar_url'] as String?,
          jobTitle: (job?['title'] as String?) ?? '',
          createdAt: a['created_at'] != null
              ? DateTime.tryParse(a['created_at'].toString())
              : null,
          jobId: a['job_id'] as String?,
        );
      }).toList();

      // Applicant counts per post
      final applicantCounts = <String, int>{};
      if (jobIds.isNotEmpty) {
        final countsRes = await _supabase
            .from('applications')
            .select('job_id')
            .inFilter('job_id', jobIds);
        for (final c in (countsRes as List).cast<Map<String, dynamic>>()) {
          final jid = c['job_id'] as String;
          applicantCounts[jid] = (applicantCounts[jid] ?? 0) + 1;
        }
      }

      final activeJobPosts = activePosts
          .map((p) => ActiveJobPostSummary(
                id: p['id'] as String,
                title: (p['title'] as String?) ?? '',
                applicantCount: applicantCounts[p['id']] ?? 0,
              ))
          .toList();

      return Right(RecruiterStats(
        activePosts: activePosts.length,
        pendingApplications: pendingCount,
        upcomingInterviews: interviews.length,
        recentApplicants: recentApplicants,
        activeJobPosts: activeJobPosts,
      ));
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }
}
