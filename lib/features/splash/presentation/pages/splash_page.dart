import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/user_role.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/connection_loop_logo.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initNavigation();
  }

  Future<void> _initNavigation() async {
    final minimumDelay = Future.delayed(
      AppDurations.splash + const Duration(milliseconds: 200),
    );

    await minimumDelay;

    while (ref.read(authProvider) is AuthInitial) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (!mounted || _navigated) return;
    _navigated = true;

    final auth = ref.read(authProvider);

    switch (auth) {
      case AuthAuthenticated():
        if (!auth.isOnboardingComplete) {
          context.go('/onboarding');
        } else if (auth.role == UserRole.recruiter) {
          context.go('/recruiter/home');
        } else {
          context.go('/');
        }
      case AuthUnauthenticated():
      case AuthError():
        context.go('/login');
      case AuthInitial():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppGradientBackground(
        child: Center(
          child: ConnectionLoopLogo(
            size: 88,
            animated: true,
            showWordmark: true,
          ),
        ),
      ),
    );
  }
}
