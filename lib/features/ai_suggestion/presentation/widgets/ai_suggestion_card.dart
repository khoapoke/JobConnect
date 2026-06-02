import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import 'match_score_badge.dart';

/// A job card enriched with an AI Match Score badge.
///
/// The card is wrapped in a subtle violet-tinted container to signal AI
/// curation, and enters with a gentle fade + slide on first appearance.
class AiSuggestionCard extends StatefulWidget {
  const AiSuggestionCard({
    super.key,
    required this.suggestion,
    this.onBookmarkRemoved,
  });

  final AiSuggestion suggestion;
  final VoidCallback? onBookmarkRemoved;

  @override
  State<AiSuggestionCard> createState() => _AiSuggestionCardState();
}

class _AiSuggestionCardState extends State<AiSuggestionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!reducedMotion && _controller.value == 0) {
      _controller.forward();
    } else if (reducedMotion) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - _animation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.aiAccent.withValues(alpha: 0.07),
              AppColors.background.withValues(alpha: 0.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: AppColors.aiAccent.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.aiAccent.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MatchScoreBadge(matchScore: widget.suggestion.matchScore),
            const SizedBox(height: AppSpacing.space2),
            JobCard(
              result: widget.suggestion.result,
              onBookmarkRemoved: widget.onBookmarkRemoved,
              onTap: () => context.push(
                '/search/${widget.suggestion.result.jobPost.id}',
                extra: widget.suggestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
