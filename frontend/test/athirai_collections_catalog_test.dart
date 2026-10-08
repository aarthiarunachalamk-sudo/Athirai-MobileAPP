import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/shop/domain/models/athirai_collections_catalog.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/widgets/athirai_collections_megamenu_sheet.dart';

void main() {
  group('Athirai Collections Catalog Domain & Structure Tests', () {
    test('Catalog contains exact 8 collections matching reference design', () {
      expect(AthiraiCollectionsCatalog.columns.length, 8);

      final titles = AthiraiCollectionsCatalog.columns.map((c) => c.title).toList();
      expect(titles, containsAll([
        'Gold Jewellery',
        'Silver Jewellery',
        'Coins & Bars',
        'Daily Wear',
        'Wedding Jewellery',
        'Gifting Collection',
        'Mangalsutra',
        'Other Jewellery',
      ]));

      // Verify badges: G, S, C, D, W, G, M, O
      final badges = AthiraiCollectionsCatalog.columns.map((c) => c.badgeLetter).toList();
      expect(badges, ['G', 'S', 'C', 'D', 'W', 'G', 'M', 'O']);

      // Verify total items count across all 8 collections equals 64
      final totalItems = AthiraiCollectionsCatalog.columns.fold<int>(
        0,
        (sum, col) => sum + col.items.length,
      );
      expect(totalItems, 64);
    });

    test('Gold Jewellery has 16 items and Gold Rings', () {
      final gold = AthiraiCollectionsCatalog.columns.firstWhere((c) => c.id == 'gold');
      expect(gold.items.length, 16);
      expect(gold.items, contains('Gold Rings'));
      expect(gold.items, contains('Gold Bangles'));
      expect(gold.items, contains('Gold Armlets'));
      expect(gold.viewAllLabel, 'View All Gold →');
    });

    test('Silver Jewellery has 12 items', () {
      final silver = AthiraiCollectionsCatalog.columns.firstWhere((c) => c.id == 'silver');
      expect(silver.items.length, 12);
      expect(silver.items, contains('Silver Anklets'));
      expect(silver.items, contains('Silver Coins & Items'));
      expect(silver.viewAllLabel, 'View All Silver →');
    });

    test('Coins & Bars has 7 items', () {
      final coins = AthiraiCollectionsCatalog.columns.firstWhere((c) => c.id == 'coins');
      expect(coins.items.length, 7);
      expect(coins.items, contains('Gold Coins'));
      expect(coins.items, contains('Temple Coins'));
    });

    test('Category Navigation Tabs contains all 9 tabs from website', () {
      expect(AthiraiCollectionsCatalog.categoryTabs, [
        'ALL JEWELLERY',
        'GOLD',
        'SILVER',
        'COINS',
        'OFFERS',
        'TEAM369-LIVE',
        'WEDDING',
        'GIFTING',
        'NEARBY SHOP',
      ]);
    });
  });

  group('AthiraiCollectionsMegamenuSheet Widget Tests', () {
    testWidgets('Renders megamenu sheet with search, tabs, and columns', (tester) async {
      final store = ShopStore();
      String? selectedCol;
      String? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AthiraiCollectionsMegamenuSheet(
              store: store,
              onSelectItem: (col, item) {
                selectedCol = col;
                selectedItem = item;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Brand Crest / Tamil Logo
      expect(find.text('ஆதிரை'), findsOneWidget);
      expect(find.text('ATHIRAI JEWELS'), findsOneWidget);

      // Verify Search Bar hint
      expect(find.text('Search gold & silver jewellery...'), findsOneWidget);

      // Verify Tabs
      expect(find.text('ALL JEWELLERY'), findsOneWidget);
      expect(find.text('GOLD'), findsOneWidget);
      expect(find.text('SILVER'), findsOneWidget);

      // Verify Column titles & sub items
      expect(find.text('Gold Jewellery'), findsOneWidget);
      expect(find.text('Gold Rings'), findsOneWidget);

      // Tap on Gold Rings item
      await tester.tap(find.text('Gold Rings'));
      await tester.pumpAndSettle();

      expect(selectedCol, 'Gold Jewellery');
      expect(selectedItem, 'Gold Rings');
    });

    testWidgets('Tapping View All Gold selects All', (tester) async {
      final store = ShopStore();
      String? selectedCol;
      String? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AthiraiCollectionsMegamenuSheet(
              store: store,
              onSelectItem: (col, item) {
                selectedCol = col;
                selectedItem = item;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All Gold →'));
      await tester.pumpAndSettle();

      expect(selectedCol, 'Gold Jewellery');
      expect(selectedItem, 'All');
    });

    testWidgets('Filtering tabs switches visible collections', (tester) async {
      final store = ShopStore();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AthiraiCollectionsMegamenuSheet(
              store: store,
              onSelectItem: (_, _) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap SILVER tab
      await tester.tap(find.text('SILVER'));
      await tester.pumpAndSettle();

      expect(find.text('Silver Jewellery'), findsOneWidget);
      expect(find.text('Silver Anklets'), findsOneWidget);
    });
  });
}
