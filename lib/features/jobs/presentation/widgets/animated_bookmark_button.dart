import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/bookmark_provider.dart';

class AnimatedBookmarkButton extends ConsumerStatefulWidget {
  const AnimatedBookmarkButton({
    super.key,
    required this.jobPostId,
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
    this.onRemoved,
  });

  final String jobPostId;
  final double size;
  final EdgeInsets padding;
  final VoidCallback? onRemoved;

  @override
  ConsumerState<AnimatedBookmarkButton> createState() =>
      _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends ConsumerState<AnimatedBookmarkButton> {
  final ValueNotifier<bool> _locked = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _popping = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _locked.dispose();
    _popping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ids = ref.watch(activeBookmarkIdsProvider).valueOrNull ?? <String>{};
    final isBookmarked = ids.contains(widget.jobPostId);

    return ValueListenableBuilder<bool>(
      valueListenable: _locked,
      builder: (context, locked, _) {
        return Semantics(
          button: true,
          label: isBookmarked ? 'Bỏ Bookmark' : 'Lưu Bookmark',
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: locked ? null : () => _toggle(isBookmarked),
              child: Padding(
                padding: widget.padding,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _popping,
                      builder: (context, popping, child) {
                        return AnimatedScale(
                          scale: popping ? 1.18 : 1,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutCubic,
                          child: child,
                        );
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          key: ValueKey<bool>(isBookmarked),
                          color: isBookmarked
                              ? AppColors.primary
                              : AppColors.textSecondary.withAlpha(150),
                          size: widget.size,
                        ),
                      ),
                    ),
                    if (locked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggle(bool wasBookmarked) async {
    _locked.value = true;
    _popping.value = true;

    final toggleFuture = ref
        .read(activeBookmarkIdsProvider.notifier)
        .toggleBookmark(widget.jobPostId);
    final animationFuture = Future<void>.delayed(
      const Duration(milliseconds: 180),
      () {
        if (mounted) _popping.value = false;
      },
    );

    final results = await Future.wait<Object?>([
      toggleFuture,
      animationFuture.then((_) => null),
    ]);
    if (!mounted) return;

    final success = results.first as bool;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bookmarkFailureMessage(adding: !wasBookmarked),
            style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (wasBookmarked) {
      widget.onRemoved?.call();
    }

    _locked.value = false;
  }
}
