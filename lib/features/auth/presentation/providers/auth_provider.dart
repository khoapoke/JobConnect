import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../data/models/profile_model.dart';
import '../../domain/entities/auth_state.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  StreamSubscription<dynamic>? _subscription;

  @override
  AuthState build() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        state = const AuthUnauthenticated();
        return;
      }
      _fetchProfile(session.user.id);
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      _fetchProfile(currentSession.user.id);
      return const AuthInitial();
    } else {
      return const AuthUnauthenticated();
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthUnauthenticated();
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('AUTH ERROR: Profile not found for user $userId — treating as unauthenticated');
        // Don't error — force logout so user can try again or re-register
        await Supabase.instance.client.auth.signOut();
        state = const AuthUnauthenticated();
        return;
      }

      debugPrint('AUTH: Profile raw response: $response');
      final profile = ProfileModel.fromJson(response).toEntity();
      debugPrint('AUTH: Parsed profile — role=${profile.role}, onboarding=${profile.isOnboardingComplete}, bannedUntil=${profile.bannedUntil}');
      state = AuthAuthenticated(
        userId: profile.id,
        role: profile.role,
        isOnboardingComplete: profile.isOnboardingComplete,
        bannedUntil: profile.bannedUntil,
      );
    } catch (e, st) {
      debugPrint('AUTH ERROR in _fetchProfile: $e');
      debugPrint('Stack trace: $st');
      await Supabase.instance.client.auth.signOut();
      state = AuthError(message: 'Lỗi khi tải thông tin hồ sơ: $e');
    }
  }
}
