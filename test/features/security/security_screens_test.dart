import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_money/core/services/security_service.dart';
import 'package:my_money/core/theme/app_theme.dart';
import 'package:my_money/features/security/providers/security_providers.dart';
import 'package:my_money/features/security/screens/lock_screen.dart';
import 'package:my_money/features/settings/screens/pin_setup_screen.dart';
import 'package:my_money/l10n/app_localizations.dart';

class _InMemoryStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  Widget buildTestApp(SecurityService service, Widget child) {
    return ProviderScope(
      overrides: [
        securityServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  Future<void> tapPin(WidgetTester tester, String digits) async {
    for (final ch in digits.split('')) {
      await tester.tap(find.byKey(Key('pin_key_$ch')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('PinSetupScreen sets up a 4-digit PIN and passes WCAG checks',
      (tester) async {
    final service = LocalSecurityService(store: _InMemoryStore());

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildTestApp(service, const PinSetupScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Activer le code PIN'), findsOneWidget);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Open PIN creation flow
    await tester.tap(find.text('Activer le code PIN'));
    await tester.pumpAndSettle();

    // Enter mismatched PINs first
    await tapPin(tester, '1234');
    await tapPin(tester, '9999');
    expect(find.text('Les codes PIN ne correspondent pas.'), findsOneWidget);

    // Enter matching PINs
    await tapPin(tester, '2580');
    await tapPin(tester, '2580');

    expect(find.text('Code PIN activé'), findsOneWidget);
    expect(await service.verifyPin('2580'), isTrue);

    semantics.dispose();
  });

  testWidgets('LockScreen rejects wrong PIN, unlocks on right PIN, passes a11y',
      (tester) async {
    final service = LocalSecurityService(store: _InMemoryStore());
    await service.setPin('1357');

    final container = ProviderContainer(
      overrides: [securityServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LockScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(securityProvider).isLocked, isTrue);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Wrong PIN shows error and keeps app locked
    await tapPin(tester, '0000');
    expect(find.textContaining('Code PIN incorrect'), findsOneWidget);
    expect(container.read(securityProvider).isLocked, isTrue);

    // Correct PIN unlocks app
    await tapPin(tester, '1357');
    expect(container.read(securityProvider).isLocked, isFalse);

    semantics.dispose();
  });
}
