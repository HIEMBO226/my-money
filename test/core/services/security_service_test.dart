import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/services/security_service.dart';
import 'package:my_money/domain/entities/security_settings.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> data = {};

  @override
  Future<void> delete(String key) async => data.remove(key);

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

void main() {
  late _InMemorySecureStore store;
  late LocalSecurityService service;

  setUp(() {
    store = _InMemorySecureStore();
    service = LocalSecurityService(store: store);
  });

  group('LocalSecurityService', () {
    test('stores salted hash (never plaintext) and verifies PIN accurately',
        () async {
      await service.setPin('4829');

      // Raw PIN must never appear in stored values
      for (final value in store.data.values) {
        expect(value, isNot(contains('4829')));
      }

      expect(await service.verifyPin('4829'), isTrue);
      expect(await service.verifyPin('1111'), isFalse);

      final loaded = await service.loadSettings();
      expect(loaded.isPinEnabled, isTrue);
    });

    test('rejects invalid PIN format', () async {
      expect(
        () => service.setPin('12'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => service.setPin('abcd'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('persists security settings and disables PIN on removePin', () async {
      await service.setPin('2580');
      await service.saveSettings(
        const SecuritySettings(
          isPinEnabled: true,
          isBiometricsEnabled: true,
          hideInAppSwitcher: false,
          inactivityMinutes: 15,
        ),
      );

      final loaded = await service.loadSettings();
      expect(loaded.isPinEnabled, isTrue);
      expect(loaded.isBiometricsEnabled, isTrue);
      expect(loaded.hideInAppSwitcher, isFalse);
      expect(loaded.inactivityMinutes, 15);

      await service.removePin();
      final afterRemove = await service.loadSettings();
      expect(afterRemove.isPinEnabled, isFalse);
      expect(afterRemove.isBiometricsEnabled, isFalse);
      expect(await service.verifyPin('2580'), isFalse);
    });
  });
}
