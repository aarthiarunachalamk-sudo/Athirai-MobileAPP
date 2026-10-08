import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_certified_coins_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_recharge_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ShopStore store;

  setUp(() {
    store = ShopStore(autoLoadBackend: false);
    store.rechargeWallet(amount: 137.02, coins: 13702); // Exact 13,705 AUG balance from video
  });

  group('Certified Coin Collection Tests (Video Parity)', () {
    testWidgets('Header displays Today\'s Gold rate and AUG balance from video', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiCertifiedCoinsScreen(store: store),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Top bar elements
      expect(find.text("Today's Gold Rate 22K: Rs. 14,250/-"), findsOneWidget);
      expect(find.text('AUG 13,705'), findsOneWidget);

      // Section title
      expect(find.text('CERTIFIED COIN COLLECTION'), findsOneWidget);

      // Live backend rate card
      expect(find.text('Live backend rate'), findsOneWidget);
      expect(find.text('Rs. 275'), findsOneWidget);
      expect(find.text('Silver 999 per gram'), findsOneWidget);
    });

    testWidgets('Metal tabs and explore by weight carousel render', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiCertifiedCoinsScreen(store: store),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Filter tabs
      expect(find.text('All Coins'), findsOneWidget);
      expect(find.text('Silver Coins'), findsNWidgets(2)); // Title & Tab
      expect(find.text('Gold Coins'), findsOneWidget);

      // Explore by weight carousel
      expect(find.text('EXPLORE BY WEIGHT'), findsOneWidget);
      expect(find.text('250 mg'), findsOneWidget);
      expect(find.text('500 mg'), findsOneWidget);
      expect(find.text('1 g'), findsOneWidget);
      expect(find.text('2 g'), findsOneWidget);
      expect(find.text('5 g'), findsOneWidget);
      expect(find.text('10 g'), findsOneWidget);
      expect(find.text('50 g'), findsOneWidget);
    });

    testWidgets('Renders video-matched certified products and allows Buy with Coins', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Add sufficient coins to complete purchase
      await store.rechargeWallet(amount: 3000, coins: 300000);

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiCertifiedCoinsScreen(store: store, initialTab: 'Silver Coins'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 50 gm Silver Bar and 2 gm Silver Coin from video
      expect(find.text('50 gm Silver Bar'), findsOneWidget);
      expect(find.text('2 gm Silver Coin'), findsOneWidget);

      // Find 'Buy with Coins' button
      final buyWithCoinsButtons = find.text('Buy with Coins');
      expect(buyWithCoinsButtons, findsWidgets);

      // Tap buy on the 2 gm Silver Coin
      final initialCoins = store.augCoins;
      await tester.tap(buyWithCoinsButtons.at(1));
      await tester.pumpAndSettle();

      // Opens AthiraiPurchaseSheet for order confirmation
      expect(find.text('Purchase with AUG Coins'), findsOneWidget);

      final payButton = find.textContaining('Pay 🪙');
      expect(payButton, findsOneWidget);
      await tester.scrollUntilVisible(
        payButton,
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(payButton);
      await tester.pump(const Duration(milliseconds: 600));

      // Coins balance deducted
      expect(store.augCoins, lessThan(initialCoins));
    });
  });

  group('Razorpay Recharge Modal & Exit Dialog Tests (Video Parity)', () {
    testWidgets('Recharge screen renders preset ₹1,000, 100 AUG coins per rupee, and Razorpay modal', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiRechargeScreen(store: store),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Buy Recharge'), findsOneWidget);
      expect(find.text('₹1,000'), findsOneWidget);
      expect(find.text('+1,00,000 AUG Coins'), findsOneWidget);
      expect(find.text('PAY ₹1000 & RECHARGE'), findsOneWidget);

      // Tap Pay & Recharge
      await tester.tap(find.text('PAY ₹1000 & RECHARGE'));
      await tester.pump(); // Start processing
      await tester.pump(const Duration(milliseconds: 600)); // Sheet opens
      await tester.pump(const Duration(milliseconds: 200));

      // Razorpay Checkout Sheet from video
      expect(find.text('BitByte Wallet Recharge'), findsOneWidget);
      expect(find.text('Test Mode'), findsOneWidget);
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Netbanking'), findsOneWidget);

      // Exit confirmation dialog when tapping '✕'
      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Are you sure you want to exit?'), findsOneWidget);
      expect(find.text('Continue to payment'), findsOneWidget);
      expect(find.text('Yes, exit'), findsOneWidget);

      // Tap 'Yes, exit' closes the checkout
      await tester.tap(find.text('Yes, exit'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Are you sure you want to exit?'), findsNothing);
    });
  });
}
