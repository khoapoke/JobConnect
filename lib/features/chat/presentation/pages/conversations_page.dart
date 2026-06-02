import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../../../shared/presentation/widgets/connection_loop_logo.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_card.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isSeeker =
        auth is AuthAuthenticated && auth.role == UserRole.seeker;
    final userId = auth is AuthAuthenticated ? auth.userId : '';

    final conversationsAsync = ref.watch(conversationListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space4,
                    AppSpacing.space4,
                    AppSpacing.space4,
                    AppSpacing.space2,
                  ),
                  child: Text(
                    AppStrings.conversations,
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                sliver: conversationsAsync.when(
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyConversationsState(),
                      );
                    }
                    return SliverList.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        height: AppSpacing.space2,
                      ),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ConversationCard(
                          conversation: conversation,
                          currentUserId: userId,
                          isSeeker: isSeeker,
                          onTap: () {
                            final route = isSeeker
                                ? '/conversations/${conversation.id}'
                                : '/recruiter/conversations/${conversation.id}';
                            context.push(route, extra: conversation);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ConversationListSkeleton(),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ConversationsErrorState(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(
                        conversationListNotifierProvider,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyConversationsState extends StatelessWidget {
  const _EmptyConversationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ConnectionLoopLogo(
              size: 80,
              animated: true,
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              AppStrings.noConversations,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              AppStrings.noConversationsSubtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationListSkeleton extends StatelessWidget {
  const _ConversationListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(180),
                borderRadius: AppRadii.lg,
                border: Border.all(
                  color: AppColors.divider.withAlpha(40),
                ),
              ),
              child: const Row(
                children: [
                  AppSkeleton(
                    width: 48,
                    height: 48,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppSkeleton(
                                width: 120,
                                height: 16,
                              ),
                            ),
                            SizedBox(width: AppSpacing.space2),
                            AppSkeleton(
                              width: 36,
                              height: 12,
                              borderRadius: AppRadii.sm,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.space2),
                        AppSkeleton(
                          width: double.infinity,
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationsErrorState extends StatelessWidget {
  const _ConversationsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error.withAlpha(140),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              AppStrings.errorGeneral,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space4),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
