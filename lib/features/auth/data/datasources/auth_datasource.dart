import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/user_role.dart';

abstract class AuthDatasource {
  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
    String? inviteCode,
  });

  Future<void> login({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> completeOnboarding(UserRole role);
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class AuthDatasourceImpl implements AuthDatasource {
  const AuthDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
    String? inviteCode,
  }) async {
    // Validate invite code if provided
    if (inviteCode != null && inviteCode.isNotEmpty) {
      final inviteRes = await _supabase
          .from('admin_invites')
          .select('id, used_by, expires_at, role')
          .eq('code', inviteCode)
          .maybeSingle();

      if (inviteRes == null) {
        throw Exception('Mã mời không hợp lệ');
      }

      if (inviteRes['used_by'] != null) {
        throw Exception('Mã mời đã được sử dụng');
      }

      final expiresAt = DateTime.parse(inviteRes['expires_at'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Mã mời đã hết hạn');
      }

      // Use role from invite code if provided
      final inviteRole = inviteRes['role'] as String?;
      if (inviteRole != null) {
        role = UserRole.values.firstWhere(
          (r) => r.name == inviteRole,
          orElse: () => role,
        );
      }
    }

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role.name,
        'full_name': fullName,
      },
    );

    // Mark invite code as used after successful registration
    if (inviteCode != null && inviteCode.isNotEmpty && response.user != null) {
      await _supabase.from('admin_invites').update({
        'used_by': response.user!.id,
      }).eq('code', inviteCode);
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.jobconnect.job_connect://login-callback',
    );
  }

  @override
  Future<void> completeOnboarding(UserRole role) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('profiles').update({
      'role': role.name,
      'is_onboarding_complete': true,
    }).eq('id', userId);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
