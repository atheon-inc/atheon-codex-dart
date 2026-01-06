class AtheonUnitFetchAndIntegrateModel {
  /// The search query string. Must be at least 2 characters long.
  final String query;

  /// The base content for integration. Must be at least 10 characters long.
  final String baseContent;

  /// Should include 'ad_units' or not.
  final bool includeAdUnits;

  /// Should 'user_intent' be used as filter or not.
  final bool useUserIntentAsFilter;

  AtheonUnitFetchAndIntegrateModel({
    required this.query,
    required this.baseContent,
    required this.includeAdUnits,
    required this.useUserIntentAsFilter,
  });

  Map<String, dynamic> toJson() {
    return {
      "query": query,
      "base_content": baseContent,
      "include_ad_units": includeAdUnits,
      "use_user_intent_as_filter": useUserIntentAsFilter,
    };
  }
}
