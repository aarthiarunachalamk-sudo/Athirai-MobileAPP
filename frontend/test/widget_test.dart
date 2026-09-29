import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athirai_mobile/main.dart';

void main() {
  testWidgets('Athirai Jewels App loads Sign In screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AthiraiJewelsApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify Sign In title and components render
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Sign in with SSO'), findsOneWidget);
  });
}
