import 'dart:convert';

import 'package:atheon_ui/ui.dart';

class AtheonAdMeta {
  final String clickUrl;
  final String keyword;
  final String injectionMode;
  final int? keywordStartIdx;
  final int? keywordEndIdx;

  AtheonAdMeta({
    required this.clickUrl,
    required this.keyword,
    this.injectionMode = "random",
    this.keywordStartIdx,
    this.keywordEndIdx,
  });

  factory AtheonAdMeta.fromJson(Map<String, dynamic> json) {
    return AtheonAdMeta(
      clickUrl: json["click_url"] as String,
      keyword: json['keyword'] as String,
      injectionMode: json['injection_mode'] as String? ?? 'random',
      keywordStartIdx: json['keyword_start_idx'] as int?,
      keywordEndIdx: json['keyword_end_idx'] as int?,
    );
  }
}

class AtheonConfig {
  final String trackFingerprint;
  final AtheonAdMeta? adMeta;

  AtheonConfig({required this.trackFingerprint, this.adMeta});

  factory AtheonConfig.fromJson(Map<String, dynamic> json) {
    return AtheonConfig(
      trackFingerprint: json['track_fingerprint'] as String? ?? 'unknown',
      adMeta: json['ad_meta'] != null
          ? AtheonAdMeta.fromJson(json['ad_meta'] as Map<String, dynamic>)
          : null,
    );
  }

  static AtheonConfig validateParsedConfigData(
    Map<String, dynamic> json,
    int idx,
  ) {
    // Validate Global Fields
    for (var key in AtheonConstants.REQUIRED_GLOBAL_FIELDS.keys) {
      if (!json.containsKey(key)) {
        throw FormatException(
          "Item [$idx]; Missing required global field: '$key'",
        );
      }
    }

    // Validate Ad Meta Fields (Only if present)
    if (json.containsKey("ad_meta")) {
      final adMeta = json["ad_meta"] as Map<String, dynamic>;

      // Required Ad Fields
      for (var key in AtheonConstants.REQUIRED_AD_FIELDS.keys) {
        if (!adMeta.containsKey(key)) {
          throw FormatException(
            "Item [$idx]: Missing required ad field: '$key'",
          );
        }
      }

      // Optional Ad Fields
      for (var entry in AtheonConstants.OPTIONAL_AD_FIELDS.entries) {
        final key = entry.key;
        final rules = entry.value as Map<String, dynamic>;

        if (adMeta.containsKey(key)) {
          final value = adMeta[key];

          if (rules.containsKey('type')) {
            if (rules['type'] == int && value is! int) {
              throw FormatException('Item [$idx]: "$key" must be an Integer.');
            }
            if (rules['type'] == String && value is! String) {
              throw FormatException('Item [$idx]: "$key" must be a String.');
            }
          }

          if (key == 'injection_mode' && value is String) {
            const validModes = ['all', 'first', 'random'];
            if (!validModes.contains(value)) {
              throw FormatException(
                'Item [$idx]: Invalid value for "injection_mode": $value',
              );
            }
          }

          if ((key == 'keyword_start_idx' || key == 'keyword_end_idx') &&
              value is int) {
            if (value < 0) {
              throw FormatException('Item [$idx]: "$key" must be non-negative');
            }
          }
        }
      }

      // Cross-field validation
      if (adMeta.containsKey('keyword_start_idx') &&
          adMeta.containsKey('keyword_end_idx')) {
        final start = adMeta['keyword_start_idx'] as int;
        final end = adMeta['keyword_end_idx'] as int;
        if (start > end) {
          throw FormatException(
            "Item [$idx]: 'keyword_start_idx' ($start) cannot be greater than 'keyword_end_idx' ($end)",
          );
        }
      } else if (adMeta.containsKey('keyword_start_idx') ||
          adMeta.containsKey('keyword_end_idx')) {
        throw FormatException(
          "Item [$idx]: Both 'keyword_start_idx' and 'keyword_end_idx' must be defined together.",
        );
      }
    }

    return AtheonConfig.fromJson(json);
  }

  static List<AtheonConfig> loadAtheonData(dynamic rawAtheonData) {
    if (rawAtheonData == null) return [];

    dynamic parsed = rawAtheonData;
    if (rawAtheonData is String) {
      if (rawAtheonData.trim().isEmpty) return [];
      try {
        parsed = jsonDecode(rawAtheonData);
      } catch (e) {
        AtheonLogger.error("JSON parse error", e);
        return [];
      }
    }

    final List<dynamic> list = parsed is List ? parsed : [parsed];
    final List<AtheonConfig> validData = [];

    for (int i = 0; i < list.length; i++) {
      try {
        if (list[i] is Map<String, dynamic>) {
          validData.add(validateParsedConfigData(list[i], i));
        }
      } catch (e) {
        AtheonLogger.error("Validation Error", e);
      }
    }
    return validData;
  }
}
