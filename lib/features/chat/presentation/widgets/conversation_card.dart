import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/presentation/widgets/animated_pressable.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../domain/entities/conversation.dart';

class ConversationCard extends StatelessWidget {
  const ConversationCard({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.isSeeker,
    required this.onTap,
  });

  final Conversation conversation;
  final String currentUserId;
  final bool isSeeker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryName = isSeeker
        ? (conversation.companyName?.isNotEmpty == true
            ? conversation.companyName!
            : conversation.recruiterName)
        : conversation.seekerName;

    final secondaryText = isSeeker
        ? '${conversation.recruiterName} · ${conversation.jobTitle}'
        : '${conversation.jobTitle}${conversation.seekerHeadline?.isNotEmpty == true ? ' · ${conversation.seekerHeadline}' : ''}';

    final avatarUrl = isSeeker
        ? (conversation.companyLogoUrl ?? conversation.recruiterAvatarUrl)
        : conversation.seekerAvatarUrl;

    final fallbackInitial = isSeeker
        ? (conversation.companyName?.isNotEmpty == true
            ? conversation.companyName![0].toUpperCase()
            : conversation.recruiterName[0].toUpperCase())
        : (conversation.seekerName.isNotEmpty
            ? conversation.seekerName[0].toUpperCase()
            : '?');

    final time = conversation.lastMessageCreatedAt ?? conversation.createdAt;
    final hasUnread = conversation.unreadCount > 0;

    return AnimatedPressable(
      onTap: onTap,
      borderRadius: AppRadii.lg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      child: GlassSurface(
        borderRadius: AppRadii.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        backgroundColor: hasUnread
            ? AppColors.surface.withAlpha(220)
            : null,
        child: Row(
          children: [
            _Avatar(
              url: avatarUrl,
              fallback: fallbackInitial,
              hasUnread: hasUnread,
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          primaryName,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight:
                                hasUnread ? FontWeight.w800 : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        _formatTime(time),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: hasUnread
                              ? AppColors.primarySoft
                              : AppColors.textSecondary,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageContent ?? secondaryText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: AppSpacing.space2),
                        _UnreadBadge(count: conversation.unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return DateFormat('dd/MM').format(time);
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'Vừa xong';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    this.url,
    required this.fallback,
    required this.hasUnread,
  });

  final String? url;
  final String fallback;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();
    if (!hasUnread) return avatar;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: avatar,
    );
  }

  Widget _buildAvatar() {
    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: StorageUtils.publicUrl(url!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _fallback(),
          errorWidget: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withAlpha(30),
      child: Text(
        fallback,
        style: AppTextStyles.title.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final display = count > 99 ? '99+' : count.toString();
    final isSingleDigit = display.length == 1;

    return Container(
      padding: isSingleDigit
          ? const EdgeInsets.all(5)
          : const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        display,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontSize: isSingleDigit ? 11 : 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
