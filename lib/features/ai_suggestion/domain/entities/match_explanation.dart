class MatchExplanation {
  const MatchExplanation({
    required this.suggestionId,
    required this.reason,
    required this.isCached,
  });

  final String suggestionId;
  final String reason;
  final bool isCached;
}
