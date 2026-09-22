import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Local password hashing (SHA-256 + per-user salt). Never store plaintext.
class PasswordHasher {
  PasswordHasher._();

  static final _random = Random.secure();

  static String generateSalt([int length = 32]) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final digest = sha256.convert(utf8.encode('$salt:${password.trim()}'));
    return digest.toString();
  }

  static bool verify({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    if (salt.isEmpty || expectedHash.isEmpty) return false;
    return hash(password, salt) == expectedHash;
  }
}
