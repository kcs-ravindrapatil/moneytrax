import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[MoneyTrax] $message');
    }
  }

  /// Never log personal profile or consent data.
  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[MoneyTrax][Error] $message');
      if (error != null) debugPrint(error.toString());
      if (stack != null) debugPrint(stack.toString());
    }
  }
}
