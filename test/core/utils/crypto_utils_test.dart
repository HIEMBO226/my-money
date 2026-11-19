import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils', () {
    test('encrypts and decrypts UTF-8 JSON round-trip with unique salt/IV', () {
      const secretPayload = '{"message":"Épargne mensuelle 50 000 FCFA"}';
      const password = 'strong-password-123';

      final encrypted1 = CryptoUtils.encryptJson(
        secretPayload,
        password: password,
      );
      final encrypted2 = CryptoUtils.encryptJson(
        secretPayload,
        password: password,
      );

      expect(encrypted1, isNot(encrypted2));
      expect(encrypted1, isNot(contains('Épargne')));

      final decrypted = CryptoUtils.decryptJson(
        encrypted1,
        password: password,
      );
      expect(decrypted, secretPayload);
    });

    test('throws SecurityException on short password', () {
      expect(
        () => CryptoUtils.encryptJson('{}', password: '123'),
        throwsA(isA<SecurityException>()),
      );
    });

    test('throws SecurityException on wrong password', () {
      final encrypted = CryptoUtils.encryptJson(
        '{"ok":true}',
        password: 'correct-password',
      );
      expect(
        () => CryptoUtils.decryptJson(encrypted, password: 'wrong-password'),
        throwsA(isA<SecurityException>()),
      );
    });

    test('throws SecurityException when ciphertext is tampered', () {
      final encrypted = CryptoUtils.encryptJson(
        '{"ok":true}',
        password: 'correct-password',
      );
      final map = jsonDecode(encrypted) as Map<String, dynamic>;
      final payload = base64Decode(map['payload'] as String);
      payload[0] ^= 0xFF;
      map['payload'] = base64Encode(payload);

      expect(
        () => CryptoUtils.decryptJson(
          jsonEncode(map),
          password: 'correct-password',
        ),
        throwsA(isA<SecurityException>()),
      );
    });
  });
}
