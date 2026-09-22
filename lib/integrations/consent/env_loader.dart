import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads host-app env from `.env` (bundled as a Flutter asset).
abstract final class EnvLoader {
  static const String fileName = '.env';

  static Future<Map<String, String>> load() async {
    try {
      await dotenv.load(fileName: fileName);
      return Map<String, String>.from(dotenv.env);
    } catch (_) {
      return const {};
    }
  }
}
