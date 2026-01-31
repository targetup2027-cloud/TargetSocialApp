import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class PasswordHasher {
  static const int _iterations = 150000;
  static const int _saltBytes = 16;
  static const int _derivedKeyBytes = 32;

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _derivedKeyBytes * 8,
  );

  Future<({Uint8List salt, Uint8List hash})> hashPassword(String password) async {
    final random = SecureRandom.fast;
    final salt = Uint8List.fromList(
      List.generate(_saltBytes, (_) => random.nextInt(256)),
    );

    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );

    final hash = Uint8List.fromList(await secretKey.extractBytes());

    return (salt: salt, hash: hash);
  }

  Future<bool> verifyPassword(
    String password,
    Uint8List salt,
    Uint8List storedHash,
  ) async {
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );

    final derivedHash = Uint8List.fromList(await secretKey.extractBytes());

    return _constantTimeCompare(derivedHash, storedHash);
  }

  bool _constantTimeCompare(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }
}
