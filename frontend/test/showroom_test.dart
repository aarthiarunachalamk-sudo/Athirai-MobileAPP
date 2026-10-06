import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/athirai_entry_screen.dart';
import 'package:athirai_mobile/features/auth/presentation/screens/shopping_dashboard_screen.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_cart_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_collection_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_flow_container.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_home_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_product_detail_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_splash_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/shop_screen.dart';
import 'package:athirai_mobile/features/showroom/data/showroom_data.dart';
import 'package:athirai_mobile/features/showroom/presentation/screens/choose_showroom_screen.dart';
import 'package:athirai_mobile/features/showroom/presentation/screens/showroom_experience_screen.dart';

void main() {
  test(
    'coin search handles case, plurals, reordered words and exact weights',
    () {
      final products = ShopStore().products;
      final silver = products
          .where((p) => p.matchesSearch('  COINS silver 100 mg '))
          .toList();
      expect(silver, hasLength(1));
      expect(silver.single.metal, 'Silver');
      expect(silver.single.materialLabel, '999 silver');
      expect(silver.single.item.weightGrams, 0.1);
      expect(
        products.where((p) => p.matchesSearch('gold 24k coin 1g')),
        hasLength(1),
      );
      expect(
        products.where((p) => p.matchesSearch('silver 0.1g')),
        hasLength(1),
      );
      expect(products.where((p) => p.matchesSearch('gold rings')), isNotEmpty);
      expect(
        products.where((p) => p.matchesSearch('unavailable-coin')),
        isEmpty,
      );
    },
  );

  test('bag totals, quantity limits, removal and session reset', () {
    final store = ShopStore();
    final first = store.products.first;
    final second = store.products[1];
    store.setQuantity(first.id, 2);
    store.setQuantity(second.id, 1);
    expect(store.count, 3);
    expect(store.subtotal, first.price * 2 + second.price);
    store.setQuantity(first.id, 99);
    expect(store.quantity(first.id), 10);
    store.setQuantity(first.id, 0);
    expect(store.subtotal, second.price);
    store.toggleSaved(second.id);
    expect(store.isSaved(second.id), isTrue);
    store.clear();
    expect(store.count, 0);
    expect(store.isSaved(second.id), isFalse);
    expect(rupees(438000), '\u20B94,38,000');
  });

  testWidgets('Begin Journey opens shopping dashboard', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AthiraiEntryScreen())),
    );
    expect(find.byType(ShopScreen), findsNothing);
    await tester.ensureVisible(find.text('BEGIN JOURNEY'));
    await tester.tap(find.text('BEGIN JOURNEY'));
    await tester.pumpAndSettle();
    expect(find.byType(ShoppingDashboardScreen), findsOneWidget);
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.byType(AthiraiEntryScreen), findsNothing);
  });

  testWidgets('legacy routes open shopping instead of a 3D showroom', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChooseShowroomScreen()));
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Choose Your Universe'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: ShowroomExperienceScreen(showroom: ShowroomData.showrooms.first),
      ),
    );
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen 01 Splash/Onboarding renders branding and initiates journey', (
    tester,
  ) async {
    bool journeyStarted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiSplashScreen(
          onBeginJourney: () => journeyStarted = true,
        ),
      ),
    );

    expect(find.text('ATHIRAI'), findsOneWidget);
    expect(find.text('TIMELESS JEWELS'), findsOneWidget);
    expect(find.text('Enter the Heritage'), findsOneWidget);

    await tester.tap(find.text('Enter the Heritage'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(journeyStarted, isTrue);
  });

  testWidgets('Screen 02 Home Screen renders hero arch, categories and legacy banner', (
    tester,
  ) async {
    final store = ShopStore();
    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiHomeScreen(
          store: store,
          onOpenCollection: () {},
          onOpenProduct: (_) {},
          onOpenBag: () {},
          onOpenWishlist: () {},
          onOpenSearch: () {},
        ),
      ),
    );

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Ananya'), findsOneWidget);
    expect(find.text('Discover\nYour Legacy'), findsOneWidget);
    expect(find.text('Ancient Roots. Eternal Beauty.'), findsOneWidget);
    expect(find.text('Necklaces'), findsOneWidget);
  });

  testWidgets('Screen 03 Collection Page renders filter pills, hero banner and product cards', (
    tester,
  ) async {
    final store = ShopStore();
    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiCollectionScreen(
          store: store,
          onBack: () {},
          onOpenProduct: (_) {},
          onOpenBag: () {},
        ),
      ),
    );

    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Necklaces'), findsOneWidget);
    expect(find.text('Timeless'), findsOneWidget);
    expect(find.text('Designs'), findsOneWidget);
    expect(find.text('Rooted in Tradition'), findsOneWidget);
    expect(find.text('Temple Blossom'), findsOneWidget);
  });

  testWidgets('Screen 04 Product Page renders title, 3D controls, journey and action buttons', (
    tester,
  ) async {
    final store = ShopStore();
    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiProductDetailScreen(
          store: store,
          onBack: () {},
          onBuyNow: () {},
          onOpenBag: () {},
        ),
      ),
    );

    expect(find.text('Product Detail'), findsOneWidget);
    expect(find.text('Temple Blossom Necklace'), findsOneWidget);
    expect(find.text('Heritage Collection'), findsOneWidget);
    expect(find.text('360° View'), findsOneWidget);
    expect(find.text('AR Try-on'), findsOneWidget);
    expect(find.text('View on Avatar'), findsOneWidget);
    expect(find.text('Craftsmanship Journey'), findsOneWidget);
    expect(find.text('Add to Vault'), findsOneWidget);
    expect(find.text('Buy Now'), findsOneWidget);
  });

  testWidgets('Screen 05 Vault & Checkout renders orbit hub, rewards and payment', (
    tester,
  ) async {
    final store = ShopStore();
    await tester.pumpWidget(
      MaterialApp(
        home: AthiraiCartScreen(
          store: store,
          onBack: () {},
          onOpenProduct: (_) {},
        ),
      ),
    );

    expect(find.text('My Jewel Vault'), findsOneWidget);
    expect(find.text('Your Rewards'), findsOneWidget);
    expect(find.text('3.00'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Temple Blossom Necklace'), findsOneWidget);
    expect(find.text('Secure Payment'), findsOneWidget);
    expect(find.text('Pay Securely'), findsOneWidget);
  });

  testWidgets('AthiraiFlowContainer navigates through natural flow without overflow at 360px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AthiraiFlowContainer(initialScreenIndex: 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AthiraiHomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
