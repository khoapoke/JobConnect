import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/recruiter_stats_datasource.dart';
import '../../data/repositories/recruiter_stats_repository_impl.dart';
import '../../domain/entities/recruiter_stats.dart';
import '../../domain/repositories/recruiter_stats_repository.dart';

part 'recruiter_stats_provider.g.dart';

@riverpod
RecruiterStatsRepository recruiterStatsRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return RecruiterStatsRepositoryImpl(
    RecruiterStatsDatasourceImpl(supabase),
  );
}

@riverpod
Future<RecruiterStats> recruiterStats(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) {
    return RecruiterStats.empty;
  }

  final result =
      await ref.watch(recruiterStatsRepositoryProvider).getStats(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
}
