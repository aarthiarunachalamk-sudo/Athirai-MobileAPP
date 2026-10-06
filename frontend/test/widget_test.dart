import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/sign_in_screen.dart';

void main() {
  testWidgets('login screen shows credentials and registration action', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email / Mobile Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('registration starts with personal details', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RegisterScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Register User'), findsOneWidget);
    expect(find.text('PERSONAL DETAILS'), findsOneWidget);
    expect(find.text('FIRST NAME'), findsOneWidget);
    expect(find.text('PHONE NUMBER'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('Sign in here'), findsOneWidget);
  });
}
