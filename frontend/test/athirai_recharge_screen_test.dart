import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_recharge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('recharge preview shows 100 coins per rupee', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiRechargeScreen(store: ShopStore(autoLoadBackend: false)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '100000');
    await tester.pump();

    expect(find.text('+1,00,00,000 AUG Coins'), findsOneWidget);
  });
}
