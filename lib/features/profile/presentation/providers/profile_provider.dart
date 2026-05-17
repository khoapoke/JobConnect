import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/domain/entities/user_profile.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/user_skill.dart';
import '../../domain/entities/work_experience.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    ProfileDatasourceImpl(Supabase.instance.client),
  );
}

/// Watches [authProvider] and auto-rebuilds when auth state changes.
///
/// This is the single source of truth for the current user's profile data.
/// Separate from authProvider which only handles authentication state.
@riverpod
Future<UserProfile> currentProfile(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) throw Exception('Not authenticated');

  final result =
      await ref.watch(profileRepositoryProvider).getProfile(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
}

// ─── T-11: Work Experiences Provider ──────────────────────────────────

@riverpod
Future<List<WorkExperience>> workExperiences(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref
      .watch(profileRepositoryProvider)
      .getWorkExperiences(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}

// ─── T-11: Educations Provider ────────────────────────────────────────

@riverpod
Future<List<Education>> educations(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result =
      await ref.watch(profileRepositoryProvider).getEducations(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}

// ─── T-11: Certificates Provider ──────────────────────────────────────

@riverpod
Future<List<Certificate>> certificates(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result =
      await ref.watch(profileRepositoryProvider).getCertificates(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}

// ─── T-12: Available Skills Provider ──────────────────────────────────

@riverpod
Future<List<Skill>> availableSkills(Ref ref) async {
  // No auth check — skills are public lookup data
  final result =
      await ref.watch(profileRepositoryProvider).getAvailableSkills();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (skills) => skills,
  );
}

// ─── T-12: User Skills Provider ───────────────────────────────────────

@riverpod
Future<List<UserSkill>> userSkills(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result =
      await ref.watch(profileRepositoryProvider).getUserSkills(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}

