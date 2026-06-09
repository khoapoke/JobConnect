import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../../report/presentation/widgets/report_bottom_sheet.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markAsRead());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth is AuthAuthenticated) {
      final result = await ref
          .read(chatNotifierProvider(widget.conversationId).notifier)
          .markAsRead(userId: auth.userId);
      if (!mounted) return;
      result.fold(
        (_) {},
        (_) => ref.invalidate(conversationListNotifierProvider),
      );
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(max);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userId = auth is AuthAuthenticated ? auth.userId : '';
    final isSeeker =
        auth is AuthAuthenticated && auth.role == UserRole.seeker;

    final messagesAsync = ref.watch(
      chatNotifierProvider(widget.conversationId),
    );

    ref.listen<AsyncValue<dynamic>>(
      chatNotifierProvider(widget.conversationId),
      (_, next) {
        if (!mounted) return;
        if (next.hasValue) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _markAsRead(),
          );
        }
      },
    );

    final extra = GoRouterState.of(context).extra;
    final extraConversation = extra is Conversation ? extra : null;

    final appBarTitle = extraConversation != null
        ? (isSeeker
            ? (extraConversation.companyName?.isNotEmpty == true
                ? extraConversation.companyName!
                : extraConversation.recruiterName)
            : extraConversation.seekerName)
        : AppStrings.conversations;

    final appBarSubtitle = extraConversation?.jobTitle;

    final otherAvatarUrl = isSeeker
        ? (extraConversation?.companyLogoUrl ??
            extraConversation?.recruiterAvatarUrl)
        : extraConversation?.seekerAvatarUrl;

    final otherName = isSeeker
        ? (extraConversation?.companyName?.isNotEmpty == true
            ? extraConversation!.companyName!
            : extraConversation?.recruiterName ?? '')
        : (extraConversation?.seekerName ?? '');

    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          children: [
            _ChatAppBar(
              title: appBarTitle,
              subtitle: appBarSubtitle,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  color: AppColors.surface,
                  onSelected: (value) {
                    if (value == 'report') {
                      final otherId = extraConversation != null
                          ? (isSeeker
                              ? extraConversation.recruiterId
                              : extraConversation.seekerId)
                          : '';
                      ReportBottomSheet.show(
                        context: context,
                        targetType: 'user',
                        targetId: otherId,
                        targetSnapshot: {
                          'name': otherName,
                          'conversation_id': widget.conversationId,
                        },
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined,
                              color: AppColors.error, size: 20),
                          SizedBox(width: 12),
                          Text('Báo cáo người dùng'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return _ChatEmptyState(otherName: otherName);
                  }
                  return _MessageList(
                    scrollController: _scrollController,
                    messages: messages,
                    userId: userId,
                    otherAvatarUrl: otherAvatarUrl,
                    otherName: otherName,
                  );
                },
                loading: () => const _ChatLoadingState(),
                error: (error, _) => _ChatErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(
                    chatNotifierProvider(widget.conversationId),
                  ),
                ),
              ),
            ),
            ChatInputBar(
              onSend: (text) {
                if (userId.isEmpty) return;
                ref
                    .read(
                      chatNotifierProvider(widget.conversationId).notifier,
                    )
                    .sendMessage(
                      senderId: userId,
                      content: text,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({required this.title, this.subtitle, this.actions});

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(160),
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withAlpha(80),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              child: SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.scrollController,
    required this.messages,
    required this.userId,
    this.otherAvatarUrl,
    this.otherName,
  });

  final ScrollController scrollController;
  final List<dynamic> messages;
  final String userId;
  final String? otherAvatarUrl;
  final String? otherName;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _DateSeparatorItem) {
          return _DateSeparator(label: item.label);
        }
        final message = item as Message;
        return MessageBubble(
          message: message,
          isMine: message.senderId == userId,
          otherAvatarUrl: otherAvatarUrl,
          otherName: otherName,
        );
      },
    );
  }

  List<Object> _buildItems() {
    final result = <Object>[];
    DateTime? lastDate;

    for (final message in messages.cast<Message>()) {
      final date = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );
      if (lastDate == null || !lastDate.isAtSameMomentAs(date)) {
        lastDate = date;
        result.add(_DateSeparatorItem(_dateLabel(date)));
      }
      result.add(message);
    }

    return result;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) return AppStrings.chatToday;
    if (date.isAtSameMomentAs(yesterday)) return AppStrings.chatYesterday;
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class _DateSeparatorItem {
  const _DateSeparatorItem(this.label);
  final String label;
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.space3,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withAlpha(180),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({this.otherName});

  final String? otherName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ConnectionLoopLogo(
              size: 64,
              animated: true,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              AppStrings.noMessages,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              otherName?.isNotEmpty == true
                  ? 'Gửi tin nhắn đầu tiên đến $otherName.'
                  : 'Gửi tin nhắn đầu tiên để bắt đầu cuộc trò chuyện.',
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

class _ChatLoadingState extends StatelessWidget {
  const _ChatLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: Row(
              mainAxisAlignment: index.isEven
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (index.isEven)
                  const AppSkeleton(
                    width: 28,
                    height: 28,
                    shape: BoxShape.circle,
                  ),
                if (index.isEven) const SizedBox(width: AppSpacing.space2),
                AppSkeleton(
                  width: index.isEven ? 180.0 : 160.0,
                  height: 48,
                  borderRadius: AppRadii.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatErrorState extends StatelessWidget {
  const _ChatErrorState({required this.message, required this.onRetry});

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
