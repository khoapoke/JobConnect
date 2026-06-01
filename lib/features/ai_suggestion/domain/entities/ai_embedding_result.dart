enum AiEmbeddingStatus {
  generated,
  unchanged,
  rateLimited,
  missingData,
  error,
}

class AiEmbeddingResult {
  const AiEmbeddingResult({
    required this.status,
    required this.message,
    this.sourceHash,
    this.updatedAt,
  });

  final AiEmbeddingStatus status;
  final String message;
  final String? sourceHash;
  final DateTime? updatedAt;
}
