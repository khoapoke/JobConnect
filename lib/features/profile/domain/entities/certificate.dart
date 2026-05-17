/// Certificate entry for a seeker's profile.
class Certificate {
  const Certificate({
    required this.id,
    required this.userId,
    required this.name,
    this.issuer,
    this.issuedAt,
    this.credentialUrl,
  });

  final String id;
  final String userId;
  final String name;
  final String? issuer;
  final DateTime? issuedAt;
  final String? credentialUrl;
}
