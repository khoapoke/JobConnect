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
import '../../features/recruiter/presentation/pages/create_job_post_page.dart';
import '../../features/recruiter/presentation/pages/my_job_posts_page.dart';
import '../../features/recruiter/presentation/pages/edit_job_post_page.dart';
import '../../features/recruiter/presentation/providers/company_provider.dart';
import '../../features/jobs/presentation/pages/job_search_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../features/jobs/presentation/pages/bookmarks_page.dart';
import '../../features/application/domain/entities/resume.dart';
import '../../features/application/presentation/pages/application_detail_page.dart';
import '../../features/application/presentation/pages/applicant_detail_page.dart';
import '../../features/application/presentation/pages/applicants_page.dart';
import '../../features/application/presentation/pages/apply_page.dart';
import '../../features/application/presentation/pages/my_applications_page.dart';
import '../../features/application/presentation/pages/resume_builder_page.dart';
import '../../features/application/presentation/pages/resume_preview_page.dart';
import '../../features/application/presentation/pages/resumes_page.dart';
import '../../features/application/presentation/pages/schedule_interview_page.dart';
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
  ref.listen(authProvider, (_, __) => listenable.value = !listenable.value);

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
          return authState.role == UserRole.recruiter ? '/recruiter/home' : '/';
        }
        // Company guard for job post creation
        if (state.matchedLocation == '/recruiter/posts/new') {
          final companyAsync = ref.read(currentCompanyProvider);
          // Only redirect if we have confirmed data that company is null
          // Don't redirect while loading (valueOrNull is null during loading)
          if (companyAsync.hasValue && companyAsync.valueOrNull == null) {
            return '/recruiter/company/edit?onboarding=true';
          }
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: AppStrings.home,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: AppStrings.search,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work),
                    label: AppStrings.applications,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message),
                    label: AppStrings.conversations,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: AppStrings.profile,
                  ),
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: AppStrings.home,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: AppStrings.search,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work),
                    label: AppStrings.applications,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message),
                    label: AppStrings.conversations,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: AppStrings.profile,
                  ),
                ],
              ),
            ),
            UserRole.recruiter => RecruiterShell(
              navigationShell: navigationShell,
            ),
          };
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const PlaceholderPage(title: AppStrings.home),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const JobSearchPage(),
                routes: [
                  GoRoute(
                    path: 'bookmarks',
                    builder: (context, state) => const BookmarksPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return JobDetailPage(jobPostId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'apply',
                        builder: (context, state) =>
                            ApplyPage(jobId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/applications',
                builder: (context, state) => const MyApplicationsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ApplicationDetailPage(
                      applicationId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/conversations',
                builder: (context, state) =>
                    const PlaceholderPage(title: AppStrings.conversations),
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
                builder: (context, state) => const MyJobPostsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CreateJobPostPage(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EditJobPostPage(jobId: id);
                    },
                  ),
                  GoRoute(
                    path: ':id/applicants',
                    builder: (context, state) =>
                        ApplicantsPage(jobId: state.pathParameters['id']!),
                  ),
                ],
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
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
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
      GoRoute(
        path: '/resumes',
        builder: (context, state) => const ResumesPage(),
        routes: [
          GoRoute(
            path: 'builder',
            builder: (context, state) =>
                ResumeBuilderPage(initialResume: state.extra as Resume?),
          ),
          GoRoute(
            path: 'preview',
            builder: (context, state) {
              final resume = state.extra! as Resume;
              return ResumePreviewPage(
                resumePath: resume.fileUrl!,
                title: resume.title,
              );
            },
          ),
          GoRoute(
            path: 'preview-path',
            builder: (context, state) {
              final resumePath = state.extra! as String;
              return ResumePreviewPage(resumePath: resumePath);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/recruiter/applications/:id',
        builder: (context, state) =>
            ApplicantDetailPage(applicationId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) => ScheduleInterviewPage(
              applicationId: state.pathParameters['id']!,
              jobId: state.extra! as String,
            ),
          ),
        ],
      ),
    ],
  );
}
