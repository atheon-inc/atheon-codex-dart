import 'package:flutter/foundation.dart';

class AtheonConstants {
  static String get SERVICE_ENVIRONMENT {
    if (kDebugMode) return "development";
    return "production";
  }

  static const Map<String, dynamic> REQUIRED_GLOBAL_FIELDS = {
    'track_fingerprint': {'type': String},
  };

  static const Map<String, dynamic> REQUIRED_AD_FIELDS = {
    'click_url': {'type': String},
    'keyword': {'type': String},
  };

  static const Map<String, dynamic> OPTIONAL_AD_FIELDS = {
    'injection_mode': {'default': "random", 'type': String},
    'keyword_start_idx': {'type': int},
    'keyword_end_idx': {'type': int},
  };

  static const Map<String, String> EVENT_TYPE = {
    'CLICK': "click",
    'IMPRESSION': "impression",
    'TAMPER': "tamper",
  };
}
