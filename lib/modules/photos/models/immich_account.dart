/// One Immich server plus the API key used to read it.
class ImmichAccount {
  const ImmichAccount({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.apiKey,
    this.isDemo = false,
  });

  final String id;
  final String label;
  final String baseUrl;
  final String apiKey;

  /// The built-in demo account cannot be removed.
  final bool isDemo;
}
