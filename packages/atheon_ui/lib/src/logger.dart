import 'package:atheon_ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AtheonLogger {
  static const String _TAG = "<AtheonUI>";
  static bool get _isDev =>
      AtheonConstants.SERVICE_ENVIRONMENT == "development";

  static void log(String message) {
    if (_isDev) debugPrint("[INFO] - [$_TAG] - $message");
  }

  static void warn(String message) {
    if (_isDev) debugPrint("[WARN] - [$_TAG] - $message");
  }

  static void error(String message, [Object? error]) {
    if (_isDev) {
      debugPrint("[ERROR] - [$_TAG] - $message");
      if (error != null) debugPrint("Error: $error");
    }
  }
}
