import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../errors/app_exception.dart';

/// Password-based AES-256-CBC + HMAC-SHA256 authenticated encryption
/// for offline My money JSON backups.
abstract final class CryptoUtils {
  static const String backupFormat = 'my_money_backup_v1';
  static const int minPasswordLength = 6;
  static const int _kdfIterations = 10000;

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Derives a 64-byte key material (32 bytes AES key + 32 bytes HMAC key)
  /// using iterated HMAC-SHA256 over [password] and [salt].
  static ({Uint8List encKey, Uint8List macKey}) _deriveKeys(
    String password,
    Uint8List salt,
  ) {
    final passwordBytes = utf8.encode(password);
    var block = Uint8List.fromList(
      Hmac(sha256, passwordBytes).convert([...salt, 0, 0, 0, 1]).bytes,
    );
    for (var i = 1; i < _kdfIterations; i++) {
      block = Uint8List.fromList(
        Hmac(sha256, passwordBytes).convert(block).bytes,
      );
    }
    final encKey = Uint8List.fromList(
      Hmac(sha256, block).convert(utf8.encode('my_money_aes_key')).bytes,
    );
    final macKey = Uint8List.fromList(
      Hmac(sha256, block).convert(utf8.encode('my_money_hmac_key')).bytes,
    );
    return (encKey: encKey, macKey: macKey);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Encrypts [plainText] into a JSON envelope protected with [password].
  static String encryptJson(String plainText, {required String password}) {
    if (password.length < minPasswordLength) {
      throw const SecurityException(
        'Password must contain at least 6 characters.',
      );
    }

    final salt = _randomBytes(16);
    final ivBytes = _randomBytes(16);
    final keys = _deriveKeys(password, salt);

    final encrypter = enc.Encrypter(
      enc.AES(enc.Key(keys.encKey), mode: enc.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plainText, iv: enc.IV(ivBytes));

    final macInput = <int>[...salt, ...ivBytes, ...encrypted.bytes];
    final mac = Hmac(sha256, keys.macKey).convert(macInput).bytes;

    return jsonEncode({
      'app': 'My money',
      'format': backupFormat,
      'encrypted': true,
      'salt': base64Encode(salt),
      'iv': base64Encode(ivBytes),
      'mac': base64Encode(mac),
      'payload': encrypted.base64,
    });
  }

  /// Verifies integrity and decrypts a JSON backup envelope using [password].
  static String decryptJson(String envelopeJson, {required String password}) {
    try {
      final decoded = jsonDecode(envelopeJson);
      if (decoded is! Map<String, dynamic> ||
          decoded['format'] != backupFormat ||
          decoded['encrypted'] != true) {
        throw const SecurityException('Unsupported or invalid backup format.');
      }

      final salt = base64Decode(decoded['salt'] as String);
      final ivBytes = base64Decode(decoded['iv'] as String);
      final expectedMac = base64Decode(decoded['mac'] as String);
      final payloadBytes = base64Decode(decoded['payload'] as String);

      final keys = _deriveKeys(password, salt);
      final macInput = <int>[...salt, ...ivBytes, ...payloadBytes];
      final actualMac = Hmac(sha256, keys.macKey).convert(macInput).bytes;

      if (!_constantTimeEquals(actualMac, expectedMac)) {
        throw const SecurityException(
          'Invalid password or corrupted backup file.',
        );
      }

      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(keys.encKey), mode: enc.AESMode.cbc),
      );
      return encrypter.decrypt(
        enc.Encrypted(payloadBytes),
        iv: enc.IV(ivBytes),
      );
    } on SecurityException {
      rethrow;
    } on Object {
      throw const SecurityException(
        'Invalid password or corrupted backup file.',
      );
    }
  }
}
