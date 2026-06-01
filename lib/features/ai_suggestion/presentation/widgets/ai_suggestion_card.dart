import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import 'match_score_badge.dart';

/// A job card enriched with an AI Match Score badge.
/// Delegates the bulk of job display to [JobCard].
class AiSuggestionCard extends StatelessWidget {
  const AiSuggestionCard({
    super.key,
    required this.suggestion,
    this.onBookmarkRemoved,
  });

  final AiSuggestion suggestion;
  final VoidCallback? onBookmarkRemoved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MatchScoreBadge(matchScore: suggestion.matchScore),
        const SizedBox(height: AppSpacing.space2),
        JobCard(
          result: suggestion.result,
          onBookmarkRemoved: onBookmarkRemoved,
        ),
      ],
    );
  }
}
