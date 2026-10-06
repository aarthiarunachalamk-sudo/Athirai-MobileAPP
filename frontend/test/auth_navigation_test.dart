import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_flow_container.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_home_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_splash_screen.dart';

void main() {
  testWidgets('Splash Screen navigates to Login Screen on Enter the Heritage tap', (tester) async {
    bool navigatedToLogin = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiSplashScreen(
          onBeginJourney: () {
            navigatedToLogin = true;
          },
        ),
      ),
    );

    expect(find.text('Enter the Heritage'), findsOneWidget);
    await tester.tap(find.text('Enter the Heritage'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(navigatedToLogin, isTrue);
  });

  testWidgets('Login Screen performs complete input validation', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pump();

    // 1. Submit with empty inputs
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Please enter your email, phone or ID.'), findsOneWidget);

    // 2. Submit with invalid email format
    await tester.enterText(find.byType(TextField).first, 'bad@email');
    await tester.enterText(find.byType(TextField).last, 'pass123');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    // 3. Submit with short password
    await tester.enterText(find.byType(TextField).first, 'test@athirai.com');
    await tester.enterText(find.byType(TextField).last, '123');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
  });

  testWidgets('Login Screen navigates to Register Screen on register click', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pump();

    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Register User'), findsOneWidget);
  });

  testWidgets('Login Screen navigates to Dashboard on Skip', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pump();

    await tester.ensureVisible(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(AthiraiFlowContainer), findsOneWidget);
    expect(find.byType(AthiraiHomeScreen), findsOneWidget);
  });

  testWidgets('AthiraiHomeScreen profile opens modal with user details, settings, and logout button', (
    tester,
  ) async {
    final store = ShopStore();
    bool signedOut = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiHomeScreen(
          store: store,
          onOpenCollection: () {},
          onOpenProduct: (_) {},
          onOpenBag: () {},
          onOpenWishlist: () {},
          onOpenSearch: () {},
          onSignOut: () {
            signedOut = true;
          },
        ),
      ),
    );

    await tester.pump();

    // Tap on user greeting 'Ananya' to open profile modal
    expect(find.text('Ananya'), findsOneWidget);
    await tester.tap(find.text('Ananya'));
    await tester.pumpAndSettle();

    // Verify User Profile Modal elements
    expect(find.text('ROYAL VAULT & SETTINGS'), findsOneWidget);
    expect(find.text('Ananya Sharma'), findsOneWidget);
    expect(find.text('ROYAL PRIVILEGE MEMBER'), findsOneWidget);
    expect(find.text('PROFILE DETAILS'), findsOneWidget);
    expect(find.text('SETTINGS & PREFERENCES'), findsOneWidget);
    expect(find.text('Sign Out of Athirai'), findsOneWidget);

    // Tap Sign Out of Athirai button
    await tester.ensureVisible(find.text('Sign Out of Athirai'));
    await tester.tap(find.text('Sign Out of Athirai'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Sign Out of Athirai?'), findsOneWidget);
    expect(find.text('Are you sure you want to end your current session? You will be returned to the sign-in screen.'), findsOneWidget);

    // Confirm logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
    await tester.pumpAndSettle();

    expect(signedOut, isTrue);
  });
}
