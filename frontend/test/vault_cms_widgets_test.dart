import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_step_indicator.dart';

void main() {
  group('Vault CMS Luxury Widgets', () {
    testWidgets('LuxuryGoldPillButton renders label and fires callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LuxuryGoldPillButton(
              label: 'ENTER VAULT',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ENTER VAULT'), findsOneWidget);
      await tester.tap(find.text('ENTER VAULT'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('LuxuryStatusBadge renders correct status and dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LuxuryStatusBadge(status: 'Published'),
          ),
        ),
      );

      expect(find.text('Published'), findsOneWidget);
    });

    testWidgets('LuxuryStepIndicator renders all 9 steps in product creation workflow', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int tappedStep = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              child: LuxuryStepIndicator(
                currentStep: 3,
                onStepTapped: (step) => tappedStep = step,
              ),
            ),
          ),
        ),
      );



      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('Pricing'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Variants'), findsOneWidget);
      expect(find.text('SEO'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);

      await tester.tap(find.text('Pricing'));
      await tester.pump();
      expect(tappedStep, 4);
    });
  });
}
