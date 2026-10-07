import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/shop/domain/shop_store.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_wishlist_screen.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_product_detail_screen.dart';

void main() {
  group('Customer Wishlist & Cart Store Tests', () {
    test('Wishlist add, check, remove and clear operations', () {
      final store = ShopStore(autoLoadBackend: false);
      expect(store.wishlistCount, 0);
      expect(store.wishlist, isEmpty);

      final firstProduct = store.products.first;
      store.addToWishlist(firstProduct.id);

      expect(store.wishlistCount, 1);
      expect(store.isWishlisted(firstProduct.id), isTrue);
      expect(store.isSaved(firstProduct.id), isTrue);
      expect(store.wishlist.first.id, firstProduct.id);

      // Toggle removes
      store.toggleWishlist(firstProduct.id);
      expect(store.wishlistCount, 0);
      expect(store.isWishlisted(firstProduct.id), isFalse);

      // Add back and clear
      store.addToWishlist(firstProduct.id);
      expect(store.wishlistCount, 1);
      store.clearWishlist();
      expect(store.wishlistCount, 0);
    });

    test('Add to Cart, Buy Now, and addAllWishlistToCart operations', () {
      final store = ShopStore(autoLoadBackend: false);
      expect(store.count, 0);
      expect(store.cart, isEmpty);

      final p1 = store.products[0];
      final p2 = store.products[1];

      store.addToWishlist(p1.id);
      store.addToWishlist(p2.id);
      expect(store.wishlistCount, 2);

      // Batch add all wishlist items to cart
      store.addAllWishlistToCart();
      expect(store.quantity(p1.id), 1);
      expect(store.quantity(p2.id), 1);
      expect(store.count, 2);
      expect(store.cart.length, 2);
      expect(store.subtotal, greaterThan(0));

      // Individual add to cart increments
      store.addToCart(p1.id, 2);
      expect(store.quantity(p1.id), 3);
      expect(store.count, 4);

      // Remove from cart
      store.removeFromCart(p1.id);
      expect(store.quantity(p1.id), 0);
      expect(store.count, 1);
    });
  });

  group('AthiraiWishlistScreen Widget Tests', () {
    testWidgets('Renders empty state when wishlist is empty', (tester) async {
      final store = ShopStore(autoLoadBackend: false);
      bool exploreTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiWishlistScreen(
            store: store,
            onBack: () {},
            onOpenProduct: (_) {},
            onOpenBag: () {},
            onBuyNow: (_) {},
            onExplore: () => exploreTapped = true,
          ),
        ),
      );

      expect(find.text('Royal Wishlist'), findsOneWidget);
      expect(find.text('Your Wishlist is Empty'), findsOneWidget);
      expect(find.text('Explore Collections'), findsOneWidget);

      await tester.tap(find.text('Explore Collections'));
      expect(exploreTapped, isTrue);
    });

    testWidgets('Renders wishlisted item with Add to Cart and Buy Now buttons', (tester) async {
      final store = ShopStore(autoLoadBackend: false);
      final product = store.products.first;
      store.addToWishlist(product.id);

      bool buyNowTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiWishlistScreen(
            store: store,
            onBack: () {},
            onOpenProduct: (_) {},
            onOpenBag: () {},
            onBuyNow: (p) => buyNowTriggered = true,
            onExplore: () {},
          ),
        ),
      );

      expect(find.text('Royal Wishlist'), findsOneWidget);
      expect(find.text('1 Piece'), findsOneWidget);
      expect(find.text(product.name), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);

      // Tap Add to Cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();
      expect(store.quantity(product.id), 1);

      // Tap Buy Now
      await tester.tap(find.text('Buy Now'));
      await tester.pumpAndSettle();
      expect(buyNowTriggered, isTrue);
    });
  });

  group('AthiraiProductDetailScreen Widget Tests', () {
    testWidgets('Tapping Add to Cart updates store quantity', (tester) async {
      final store = ShopStore(autoLoadBackend: false);
      final product = store.products.first;

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiProductDetailScreen(
            store: store,
            product: product,
            onBack: () {},
            onBuyNow: () {},
            onOpenBag: () {},
          ),
        ),
      );

      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();
      expect(store.quantity(product.id), 1);
    });

    testWidgets('Tapping Buy Now invokes onBuyNow callback', (tester) async {
      final store = ShopStore(autoLoadBackend: false);
      final product = store.products.first;
      bool buyNowTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AthiraiProductDetailScreen(
            store: store,
            product: product,
            onBack: () {},
            onBuyNow: () => buyNowTapped = true,
            onOpenBag: () {},
          ),
        ),
      );

      await tester.tap(find.text('Buy Now'));
      await tester.pumpAndSettle();
      expect(buyNowTapped, isTrue);
      expect(store.quantity(product.id), 1);
    });
  });
}
