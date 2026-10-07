import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_profile_dashboard_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_order_summary_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/widgets/athirai_receipt_helper.dart';
import 'package:athirai_mobile/features/shop/presentation/widgets/athirai_royal_drawer.dart';

void main() {
  group('Athirai Steps 5-11 End-to-End Tests', () {
    late ShopStore store;

    setUp(() {
      store = ShopStore(autoLoadBackend: false);
    });

    test('Step 7: 1 Rupee = 100 AUG Coins ratio and conversion utilities', () {
      expect(store.augCoinsPerRupee, 100);
      expect(store.inrToCoins(3059), 305900.0);
      expect(store.coinsToInr(305900), 3059.0);
    });

    test('Step 7 Point 5: Manual Coin Creation / Generation credits vault', () async {
      final initialCoins = store.augCoins;
      final ok = await store.manualCreditAUGCoins(
        coins: 50000.0,
        amountInr: 500.0,
        source: 'Festival Patron Bonus',
      );
      expect(ok, isTrue);
      expect(store.augCoins, initialCoins + 50000.0);
    });

    test('Step 8 & 10: Place order strictly with AUG Coins', () async {
      // Provide adequate coins
      await store.manualCreditAUGCoins(coins: 400000.0);
      final coinsBefore = store.augCoins;

      final result = await store.placeOrderWithCoins(
        productName: 'Chola Dynasty Haram',
        totalAmountInr: 3000,
        productImage: 'assets/images/shop_necklace.png',
        metalPurity: '22K Gold',
        weightGrams: 18.4,
        quantity: 1,
      );

      expect(result['success'], isTrue);
      expect(result['order'], isNotNull);
      expect(store.myOrders.length, 1);
      expect(store.myOrders.first['product_name'], 'Chola Dynasty Haram');
      expect(store.myOrders.first['coins_used'], 300000.0);
      expect(store.augCoins, coinsBefore - 300000.0);
    });

    test('Step 9: Insufficient coins returns shortfall and Buy AUG Coins via Razorpay credits coins', () async {
      // Ensure zero or insufficient coins
      store.resetSessionForTest();

      final result = await store.placeOrderWithCoins(
        productName: 'Royal Choker',
        totalAmountInr: 5000, // needs 500,000 coins
      );

      expect(result['success'], isFalse);
      expect(result['error'], 'INSUFFICIENT_COINS');
      expect(result['coins_needed'], 500000.0);

      // Recharging via Razorpay (Step 9)
      final rechargeOk = await store.buyAUGCoinsViaRazorpay(
        amountInr: 5000.0,
        mobileNumber: '+91 98765 43210',
      );

      expect(rechargeOk, isTrue);
      expect(store.augCoins >= 500000.0, isTrue);
    });

    test('Step 11: AthiraiReceiptHelper generates valid luxury receipt PDF bytes', () async {
      final order = {
        'order_id': 'ATH-9842',
        'invoice_number': 'INV-ATH-20261007-001',
        'product_name': 'Temple Heritage Haram',
        'metal_purity': '22K Gold (916 Hallmark)',
        'weight_grams': 22.5,
        'total_amount': 4500,
        'coins_used': 450000,
        'delivery_name': 'Ananya Sundaram',
        'delivery_phone': '+91 98765 43210',
        'delivery_address': '12/4 Temple View Road, T Nagar, Chennai - 600017, Tamil Nadu',
        'created_at': DateTime.now().toIso8601String(),
      };

      final pdfBytes = await AthiraiReceiptHelper.getOrGenerateReceiptPdf(order);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('Step 11: AthiraiReceiptHelper saves receipt to disk with valid file', () async {
      final order = {
        'order_id': 'ATH-9842',
        'invoice_number': 'INV-ATH-20261007-001',
        'product_name': 'Temple Heritage Haram',
        'metal_purity': '22K Gold (916 Hallmark)',
        'weight_grams': 22.5,
        'total_amount': 4500,
        'coins_used': 450000,
        'delivery_name': 'Ananya Sundaram',
        'delivery_phone': '+91 98765 43210',
        'delivery_address': '12/4 Temple View Road, T Nagar, Chennai - 600017, Tamil Nadu',
        'created_at': DateTime.now().toIso8601String(),
      };

      final file = await AthiraiReceiptHelper.saveReceiptToDisk(
        order,
        customDirectory: Directory.systemTemp,
      );
      expect(file, isNotNull);
      expect(file!.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(1000));
      expect(file.path.endsWith('.pdf'), isTrue);
    });

    testWidgets('Step 6 & 7: AthiraiProfileDashboardScreen renders vault and services', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await store.manualCreditAUGCoins(coins: 150000.0);

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiProfileDashboardScreen(
            store: store,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Profile Dashboard'), findsOneWidget);
      expect(find.text('AUG COINS VAULT'), findsOneWidget);
      expect(find.text('Buy AUG Coins'), findsOneWidget);
      expect(find.text('+ Manual'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Default Delivery Address'), findsOneWidget);
    });

    testWidgets('Step 10 & 11: AthiraiOrderSummaryScreen displays orders and Download Receipt button', (tester) async {
      await store.manualCreditAUGCoins(coins: 500000.0);
      await store.placeOrderWithCoins(
        productName: 'Kaveri Lotus Choker',
        totalAmountInr: 2500,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiOrderSummaryScreen(
            store: store,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Kaveri Lotus Choker'), findsOneWidget);
      expect(find.text('Download Receipt'), findsOneWidget);
      expect(find.text('100% BIS Hallmarked'), findsOneWidget);
    });

    testWidgets('Step 10 Point 2: AthiraiRoyalDrawer renders all required tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AthiraiRoyalDrawer(
              store: store,
              onSelectHome: () {},
              onSelectProfile: () {},
              onSelectOrders: () {},
              onSelectRecharge: () {},
              onSelectCollections: () {},
              onSelectWishlist: () {},
              onSelectCart: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Profile Dashboard'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Buy AUG Coins'), findsOneWidget);
      expect(find.text('Jewellery Collections'), findsOneWidget);
      expect(find.text('Royal Wishlist'), findsOneWidget);
      expect(find.text('Jewel Vault Bag'), findsOneWidget);
    });
  });
}
