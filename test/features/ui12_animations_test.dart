import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/core/constants/app_strings.dart';
import 'package:job_connect/core/theme/app_colors.dart';
import 'package:job_connect/features/ai_suggestion/presentation/widgets/match_score_badge.dart';
import 'package:job_connect/features/auth/domain/entities/auth_state.dart';
import 'package:job_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:job_connect/features/splash/presentation/pages/splash_page.dart';
import 'package:job_connect/shared/presentation/widgets/connection_loop_logo.dart';

/// Auth override that never touches Supabase — keeps the splash test hermetic.
class _TestAuth extends Auth {
  @override
  AuthState build() => const AuthUnauthenticated();
}

void main() {
  group('ConnectionLoopSpinner', () {
    testWidgets('renders a CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: ConnectionLoopSpinner())),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(ConnectionLoopSpinner),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      // Let the repeating controller settle without hanging the test.
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('SplashPage', () {
    testWidgets('renders the tagline caption', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const SplashPage()),
          GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_TestAuth.new)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.splashTagline), findsOneWidget);

      // Advance past the navigation delay so the pending timer resolves and
      // the splash routes to /login — no dangling timers at teardown.
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  group('MatchScoreBadge', () {
    testWidgets('renders a CustomPaint ring', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: MatchScoreBadge(matchScore: 0.8))),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(MatchScoreBadge),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion shows final percentage immediately',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: MatchScoreBadge(matchScore: 0.8)),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('80%'), findsOneWidget);
    });

    test('high score resolves to the success ring tone', () {
      expect(
        MatchScoreBadge.ringColorFor(0.9, Brightness.light),
        AppColors.success,
      );
      expect(
        MatchScoreBadge.ringColorFor(0.65, Brightness.light),
        AppColors.accent,
      );
      expect(
        MatchScoreBadge.ringColorFor(0.5, Brightness.light),
        AppColors.warning,
      );
      expect(
        MatchScoreBadge.ringColorFor(0.2, Brightness.light),
        AppColors.gray400,
      );
    });
  });
}
