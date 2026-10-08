import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/core/utils/numeric_utils.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_recharge_screen.dart';

void main() {
  group('numeric_utils tests', () {
    test('parseDouble handles num, String with decimals, null, and fallbacks', () {
      expect(parseDouble(100), 100.0);
      expect(parseDouble(100.5), 100.5);
      expect(parseDouble('10000.00'), 10000.0);
      expect(parseDouble('123.45'), 123.45);
      expect(parseDouble(' 500.25 '), 500.25);
      expect(parseDouble(null), 0.0);
      expect(parseDouble(null, 15.0), 15.0);
      expect(parseDouble('invalid', 99.0), 99.0);
    });

    test('parseInt handles num, decimal strings, integer strings, and null', () {
      expect(parseInt(100), 100);
      expect(parseInt(100.7), 100);
      expect(parseInt('10000.00'), 10000);
      expect(parseInt('42'), 42);
      expect(parseInt(' 75 '), 75);
      expect(parseInt(null), 0);
      expect(parseInt(null, 10), 10);
      expect(parseInt('invalid', 5), 5);
    });
  });

  group('AthiraiRechargeScreen transaction history rendering', () {
    testWidgets('renders transaction history with String decimal numbers without throwing', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final store = ShopStore(autoLoadBackend: false);
      // Simulate backend transactions returning Decimal strings (as DRF does)
      store.setWalletHistoryForTesting([
        {
          'id': 'tx-1',
          'type': 'recharge',
          'direction': 'credit',
          'coins_credited': '10000.00',
          'amount_paid': '100.00',
          'created_at': DateTime.now().toIso8601String(),
          'source': 'Wallet Recharge',
          'note': 'Vault Transaction',
        },
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiRechargeScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that no error screen occurred and the transaction tile renders
      expect(tester.takeException(), isNull);
      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.text('Wallet Recharge'), findsOneWidget);
      expect(find.text('+10,000 AUG'), findsOneWidget);
    });
  });
}
