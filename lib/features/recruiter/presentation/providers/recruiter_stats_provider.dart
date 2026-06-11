import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/auth_state.dart';

part 'recruiter_stats_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> recruiterStats(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) {
    throw Exception('Not authenticated');
  }

  final client = Supabase.instance.client;
  final recruiterId = auth.userId;

  // Get company IDs for this recruiter
  final companiesRes = await client
      .from('companies')
      .select('id')
      .eq('recruiter_id', recruiterId);
  final companyIds = (companiesRes as List)
      .cast<Map<String, dynamic>>()
      .map((c) => c['id'] as String)
      .toList();

  if (companyIds.isEmpty) {
    return {
      'active_posts': 0,
      'pending_applications': 0,
      'upcoming_interviews': 0,
      'recent_applicants': <Map<String, dynamic>>[],
      'active_job_posts': <Map<String, dynamic>>[],
    };
  }

  // Active posts
  final activePostsRes = await client
      .from('job_posts')
      .select('id, title')
      .eq('status', 'active')
      .inFilter('company_id', companyIds);
  final activePosts = (activePostsRes as List).cast<Map<String, dynamic>>();

  // Get job IDs for pending applications
  final jobIds = activePosts.map((p) => p['id'] as String).toList();

  // Pending applications — count riêng, không bị giới hạn bởi limit(5) bên dưới
  int pendingCount = 0;
  List<Map<String, dynamic>> pendingApps = [];
  if (jobIds.isNotEmpty) {
    final pendingCountRes = await client
        .from('applications')
        .select('id')
        .eq('status', 'pending')
        .inFilter('job_id', jobIds)
        .count(CountOption.exact);
    pendingCount = pendingCountRes.count;

    final pendingAppsRes = await client
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
  final interviewsRes = await client
      .from('interview_schedules')
      .select('id')
      .gte('scheduled_at', DateTime.now().toIso8601String());
  final interviews = (interviewsRes as List).cast<Map<String, dynamic>>();

  // Build recent applicants
  final recentApplicants = pendingApps.map((a) {
    final profile = a['profiles'] as Map<String, dynamic>?;
    final job = a['job_posts'] as Map<String, dynamic>?;
    return {
      'id': a['id'],
      'full_name': profile?['full_name'] ?? 'Ứng viên',
      'avatar_url': profile?['avatar_url'],
      'job_title': job?['title'] ?? '',
      'created_at': a['created_at'],
      'job_id': a['job_id'],
    };
  }).toList();

  // Applicant counts per post
  final applicantCounts = <String, int>{};
  if (jobIds.isNotEmpty) {
    final countsRes = await client
        .from('applications')
        .select('job_id')
        .inFilter('job_id', jobIds);
    for (final c in (countsRes as List).cast<Map<String, dynamic>>()) {
      final jid = c['job_id'] as String;
      applicantCounts[jid] = (applicantCounts[jid] ?? 0) + 1;
    }
  }

  final activeJobPosts = activePosts.map((p) {
    return {
      'id': p['id'],
      'title': p['title'],
      'applicant_count': applicantCounts[p['id']] ?? 0,
    };
  }).toList();

  return {
    'active_posts': activePosts.length,
    'pending_applications': pendingCount,
    'upcoming_interviews': interviews.length,
    'recent_applicants': recentApplicants,
    'active_job_posts': activeJobPosts,
  };
}
