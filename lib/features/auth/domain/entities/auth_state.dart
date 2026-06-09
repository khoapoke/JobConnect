import '../../../../core/router/user_role.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.role,
    required this.isOnboardingComplete,
    this.bannedUntil,
  });
  final String userId;
  final UserRole role;
  final bool isOnboardingComplete;
  final DateTime? bannedUntil;

  bool get isBanned {
    if (bannedUntil == null) return false;
    return DateTime.now().isBefore(bannedUntil!);
  }
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}
