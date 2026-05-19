import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/placeholder_page.dart';
import '../../shared/widgets/recruiter_shell.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/recruiter/presentation/pages/company_profile_page.dart';
import '../../features/recruiter/presentation/pages/edit_company_page.dart';
import 'user_role.dart';

part 'app_router.g.dart';

final publicRoutes = ['/login', '/register', '/forgot-password', '/onboarding'];

/// Resolves the current user's role from auth state.
UserRole _resolveRole(Ref ref) {
  final authState = ref.read(authProvider);
  if (authState is AuthAuthenticated) return authState.role;
  return UserRole.seeker; // fallback
}

@riverpod
GoRouter appRouter(Ref ref) {
  final listenable = ValueNotifier<bool>(false);
  ref.listen(
    authProvider,
    (_, __) => listenable.value = !listenable.value,
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState is AuthInitial) return null;
      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (publicRoutes.contains(state.matchedLocation)) return null;
        return '/login';
      }
      if (authState is AuthAuthenticated) {
        if (!authState.isOnboardingComplete) return '/onboarding';
        if (publicRoutes.contains(state.matchedLocation)) {
          // Redirect to role-appropriate home
          return authState.role == UserRole.recruiter
              ? '/recruiter/home'
              : '/';
        }
        return null;
      }
      return null;
    },
    routes: [
      // ─── Seeker Shell ──────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final role = _resolveRole(ref);
          return switch (role) {
            UserRole.seeker => Scaffold(
                body: navigationShell,
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.surface,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.textSecondary,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: AppStrings.search),
                    BottomNavigationBarItem(icon: Icon(Icons.work), label: AppStrings.applications),
                    BottomNavigationBarItem(icon: Icon(Icons.message), label: AppStrings.conversations),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
                  ],
                ),
              ),
            // TODO(T-33): Replace with AdminShell when admin feature is built.
            // Admin borrows SeekerShell temporarily — cannot use PlaceholderPage
            // here because StatefulShellRoute builder expects a shell widget.
            UserRole.admin => Scaffold(
                body: navigationShell,
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.surface,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.textSecondary,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: AppStrings.search),
                    BottomNavigationBarItem(icon: Icon(Icons.work), label: AppStrings.applications),
                    BottomNavigationBarItem(icon: Icon(Icons.message), label: AppStrings.conversations),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
                  ],
                ),
              ),
            UserRole.recruiter => RecruiterShell(navigationShell: navigationShell),
          };
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const PlaceholderPage(title: AppStrings.home),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const PlaceholderPage(title: AppStrings.search),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/applications',
                builder: (context, state) => const PlaceholderPage(title: AppStrings.applications),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/conversations',
                builder: (context, state) => const PlaceholderPage(title: AppStrings.conversations),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ─── Recruiter Shell ───────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RecruiterShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/home',
                builder: (context, state) =>
                    const PlaceholderPage(title: AppStrings.recruiterHome),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/posts',
                builder: (context, state) =>
                    const PlaceholderPage(title: AppStrings.myPosts),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/conversations',
                builder: (context, state) =>
                    const PlaceholderPage(title: AppStrings.conversations),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ─── Auth routes (outside shell) ─────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // ─── Seeker push routes ─────────────────────────────────────
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),

      // ─── Recruiter push routes ──────────────────────────────────
      GoRoute(
        path: '/recruiter/company',
        builder: (context, state) => const CompanyProfilePage(),
      ),
      GoRoute(
        path: '/recruiter/company/edit',
        builder: (context, state) => const EditCompanyPage(),
      ),
      GoRoute(
        path: '/recruiter/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
}
