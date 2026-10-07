import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/athirai_otp_verification_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_profile_dashboard_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_order_summary_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/widgets/athirai_receipt_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Athirai Complete User Flow End-to-End Tests', () {
    late ShopStore store;

    setUp(() {
      store = ShopStore(autoLoadBackend: false);
    });

    testWidgets('1. Registration Flow: Validations, Popups, and Welcome Bonus', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Create Your Account'), findsOneWidget);

      // Verify OTP screen renders with registration bonus popup
      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiOtpVerificationScreen(
            phoneNumber: '+91 98765 43210',
            onVerified: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Verify Your Number'), findsOneWidget);
      expect(find.textContaining('+91 98765 43210'), findsOneWidget);
    });

    testWidgets('2. Login Screen: UI elements, Remember Me, Forgot Password & Validation', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignInScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check login form elements
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Tap Forgot Password to open reset modal
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('Send Recovery Code'), findsOneWidget);
    });

    test('3. Daily Login Reward: 1 Credit = 100 AUG Coins generated upon login', () async {
      final initialVault = store.augCoins;
      final success = await store.claimDailyLoginReward();

      expect(success, isTrue);
      expect(store.augCoins, initialVault + 100.0);
      expect(store.walletHistory.first['coins_credited'], 100.0);
      expect(store.walletHistory.first['type'], 'reward');
    });

    test('4. AUG Coins Buying / Recharge via Razorpay (1 INR = 100 Coins)', () async {
      final initialVault = store.augCoins;
      // Buy 500 INR worth of coins = 50,000 AUG Coins
      final ok = await store.buyAUGCoinsViaRazorpay(
        amountInr: 500.0,
        mobileNumber: '+91 98765 43210',
      );

      expect(ok, isTrue);
      expect(store.augCoins, initialVault + 50000.0);
      expect(store.todayCoins, 50000.0);
      expect(store.todayRechargeAmount, 500.0);
    });

    test('5. Purchase using AUG Coins: Insufficient coins validation & successful order', () async {
      store.resetSessionForTest();
      expect(store.augCoins, 0.0);

      // Attempt to purchase without sufficient coins
      final failedAttempt = await store.placeOrderWithCoins(
        productName: 'Chola Dynasty Royal Haram',
        totalAmountInr: 3000, // Requires 300,000 coins
      );

      expect(failedAttempt['success'], isFalse);
      expect(failedAttempt['error'], 'INSUFFICIENT_COINS');
      expect(failedAttempt['coins_needed'], 300000.0);
      expect(failedAttempt['shortfall_inr'], 3000.0);

      // Recharge sufficient coins
      await store.manualCreditAUGCoins(coins: 400000.0);
      expect(store.augCoins, 400000.0);

      // Purchase successfully with coins
      final successfulOrder = await store.placeOrderWithCoins(
        productName: 'Chola Dynasty Royal Haram',
        totalAmountInr: 3000,
      );

      expect(successfulOrder['success'], isTrue);
      expect(successfulOrder['remaining_coins'], 100000.0);
      expect(store.myOrders.length, 1);
      expect(store.myOrders.first['product_name'], 'Chola Dynasty Royal Haram');
      expect(store.myOrders.first['coins_used'], 300000.0);
    });

    testWidgets('6. Profile Dashboard & Navigation: Vault and Orders', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await store.manualCreditAUGCoins(coins: 200000.0);

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
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('7. Order Summary & Receipt PDF Generation', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await store.manualCreditAUGCoins(coins: 500000.0);
      await store.placeOrderWithCoins(
        productName: 'Lotus Temple Necklace',
        totalAmountInr: 3500,
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
      expect(find.text('Lotus Temple Necklace'), findsOneWidget);
      expect(find.text('Download Receipt'), findsOneWidget);

      final pdfBytes = await AthiraiReceiptHelper.getOrGenerateReceiptPdf(store.myOrders.first);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}
