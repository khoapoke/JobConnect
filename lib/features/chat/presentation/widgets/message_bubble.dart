import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.otherAvatarUrl,
    this.otherName,
  });

  final Message message;
  final bool isMine;
  final String? otherAvatarUrl;
  final String? otherName;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space1,
        horizontal: AppSpacing.space4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            _OtherAvatar(url: otherAvatarUrl, name: otherName),
            const SizedBox(width: AppSpacing.space2),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.space3,
                horizontal: AppSpacing.space4,
              ),
              decoration: BoxDecoration(
                color: isMine
                    ? AppColors.inkFor(brightness)
                    : AppColors.surfaceFor(brightness),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadii.radiusLg),
                  topRight: const Radius.circular(AppRadii.radiusLg),
                  bottomLeft: Radius.circular(
                    isMine ? AppRadii.radiusLg : AppRadii.radiusSm,
                  ),
                  bottomRight: Radius.circular(
                    isMine ? AppRadii.radiusSm : AppRadii.radiusLg,
                  ),
                ),
                border: isMine
                    ? null
                    : Border.all(
                        color: AppColors.hairlineFor(brightness),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(
                      color: isMine
                          ? AppColors.canvasFor(brightness)
                          : AppColors.inkFor(brightness),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isMine
                              ? AppColors.canvasFor(brightness)
                                  .withValues(alpha: 0.6)
                              : AppColors.gray400For(brightness),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        _ReadStatus(
                          readAt: message.readAt,
                          brightness: brightness,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherAvatar extends StatelessWidget {
  const _OtherAvatar({this.url, this.name});

  final String? url;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';

    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.surfaceVariantFor(brightness),
        backgroundImage: NetworkImage(url!),
        onBackgroundImageError: (_, __) {},
        child: const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.surfaceVariantFor(brightness),
      child: Text(
        initial,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.gray600For(brightness),
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ReadStatus extends StatelessWidget {
  const _ReadStatus({this.readAt, required this.brightness});

  final DateTime? readAt;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final isRead = readAt != null;

    return Icon(
      isRead ? Icons.done_all_rounded : Icons.done_rounded,
      size: 13,
      color: isRead
          ? AppColors.successFor(brightness)
          : AppColors.canvasFor(brightness).withValues(alpha: 0.5),
    );
  }
}
