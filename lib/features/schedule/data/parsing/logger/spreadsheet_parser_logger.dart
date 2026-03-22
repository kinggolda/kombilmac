import 'package:flutter/foundation.dart';

class SpreadsheetParserLogger {
  const SpreadsheetParserLogger({
    required this.enabled,
  });

  final bool enabled;

  void log(String message) {
    if (!enabled) {
      return;
    }
    debugPrint('[SpreadsheetParser] $message');
  }
}

