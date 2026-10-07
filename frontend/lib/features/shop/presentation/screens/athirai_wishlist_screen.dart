import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../widgets/athirai_royal_drawer.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_profile_dashboard_screen.dart';

/// Screen: Customer Royal Wishlist ("Your Curated Heirlooms")
/// Complete luxury customer experience:
/// - Top App Bar with back navigation, piece count badge, and clear wishlist option
/// - Live Bullion Rates Ticker Bar
/// - Rich jewel cards with purity badges, weights, and dynamic live pricing
/// - Dedicated "Add to Cart", "Buy Now", and "Remove" actions per item
/// - "Add All to Cart" batch action
/// - Elegant empty state with "Discover Masterpieces" CTA
class AthiraiWishlistScreen extends StatelessWidget {
  const AthiraiWishlistScreen({
    super.key,
    required this.store,
    required this.onBack,
    required this.onOpenProduct,
    required this.onOpenBag,
    required this.onBuyNow,
    required this.onExplore,
  });

  final ShopStore store;
  final VoidCallback onBack;
  final ValueChanged<ShopProduct> onOpenProduct;
  final VoidCallback onOpenBag;
  final ValueChanged<ShopProduct> onBuyNow;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final wishlistItems = store.wishlist;
        final totalWishlistValue = wishlistItems.fold<int>(
          0,
          (sum, p) => sum + p.price,
        );

        return Scaffold(
          backgroundColor: HeritageTheme.darkBg,
          body: Stack(
            children: [
              // Background atmospheric dark emerald gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.3, -0.3),
                    radius: 1.2,
                    colors: [
                      Color(0xFF09201A),
                      Color(0xFF04100D),
                      Color(0xFF020706),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top App Bar
                    _buildTopAppBar(context, wishlistItems.length),

                    // Live Metal Rates Ticker
                    _buildLiveRatesBar(),

                    const SizedBox(height: 8),

                    // Main Content: Empty State or Wishlist Grid
                    Expanded(
                      child: wishlistItems.isEmpty
                          ? _buildEmptyState(context)
                          : _buildWishlistList(
                              context,
                              wishlistItems,
                              totalWishlistValue,
                            ),
                    ),

                    // Bottom Floating Action Bar if items exist
                    if (wishlistItems.isNotEmpty)
                      _buildBottomActionBar(context, wishlistItems.length),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Top App Bar with Royal Styling
  Widget _buildTopAppBar(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: HeritageTheme.textLight,
              size: 19,
            ),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Royal Wishlist',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.textLight,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: HeritageTheme.goldPrimary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: HeritageTheme.goldBorderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'Piece' : 'Pieces'}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.goldBright,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Saved Heirlooms & Masterpieces',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: HeritageTheme.textMutedDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Shopping Bag Icon with Cart Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: HeritageTheme.goldPrimary,
                  size: 22,
                ),
                onPressed: onOpenBag,
              ),
              if (store.count > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC7A45B),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '${store.count}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF061B18),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (count > 0)
            PopupMenuButton<String>(
              color: const Color(0xF2071B16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: HeritageTheme.goldBorderSubtle,
                  width: 0.9,
                ),
              ),
              icon: const Icon(
                Icons.more_vert_rounded,
                color: HeritageTheme.textMutedDark,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'clear') {
                  store.clearWishlist();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wishlist cleared'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Clear Wishlist',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: HeritageTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          // Three-line menu button (☰) in top-right corner (Step 10 Point 2)
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: HeritageTheme.goldBright,
              size: 23,
            ),
            tooltip: 'Menu (Order Summary & Vault)',
            onPressed: () {
              AthiraiRoyalDrawer.show(
                context,
                store: store,
                onSelectHome: onBack,
                onSelectProfile: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiProfileDashboardScreen(
                        store: store,
                      ),
                    ),
                  );
                },
                onSelectOrders: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiOrderSummaryScreen(
                        store: store,
                      ),
                    ),
                  );
                },
                onSelectWishlist: () {},
                onSelectCart: onOpenBag,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Live Metal Rates Ticker Bar
  Widget _buildLiveRatesBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE6061814),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: store.isLiveBackend
                  ? const Color(0xFF00E676)
                  : HeritageTheme.goldBright,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (store.isLiveBackend
                          ? const Color(0xFF00E676)
                          : HeritageTheme.goldBright)
                      .withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE BULLION',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: HeritageTheme.goldPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '22K: ₹${store.rates.gold22k}/g   24K: ₹${store.rates.gold24k}/g',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: HeritageTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State Screen
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gold Lotus / Crest Icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HeritageTheme.goldPrimary.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: HeritageTheme.goldBorder,
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: HeritageTheme.goldBright,
                  size: 44,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Your Wishlist is Empty',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: HeritageTheme.textLight,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Curate your personal vault of timeless royal jewellery. Tap the heart on any jewel to preserve your dream heirloom.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: HeritageTheme.textMutedDark,
              ),
            ),

            const SizedBox(height: 28),

            // "Explore Collections" Gold Button
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: HeritageTheme.goldGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: HeritageTheme.goldPrimary.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onExplore,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: Color(0xFF1A1203),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Explore Collections',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1203),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Wishlist Items List View
  Widget _buildWishlistList(
    BuildContext context,
    List<ShopProduct> items,
    int totalValue,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Summary Banner at Top
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x990A221C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: HeritageTheme.goldBorderSubtle,
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL CURATED VALUE',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: HeritageTheme.goldPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rupees(totalValue),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.textLight,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    store.addAllWishlistToCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All ${items.length} items added to your Cart!',
                        ),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'VIEW CART',
                          textColor: HeritageTheme.goldBright,
                          onPressed: onOpenBag,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: HeritageTheme.goldBright,
                    size: 16,
                  ),
                  label: Text(
                    'Add All to Cart',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.goldBright,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final product = items[index - 1];
        return _buildWishlistItemCard(context, product);
      },
    );
  }

  /// Individual Wishlist Jewel Card with "Add to Cart" and "Buy Now"
  Widget _buildWishlistItemCard(BuildContext context, ShopProduct product) {
    final inCart = store.quantity(product.id) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC071B16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Jewel Thumbnail + Details + Remove Heart
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail
                  GestureDetector(
                    onTap: () => onOpenProduct(product),
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0x55040F0D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HeritageTheme.goldBorderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.image.startsWith('http')
                            ? Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(
                                    Icons.diamond_outlined,
                                    color: HeritageTheme.goldPrimary,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Image.asset(
                                product.image.isNotEmpty
                                    ? product.image
                                    : AppAssets.pedestalNecklace,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(
                                    Icons.diamond_outlined,
                                    color: HeritageTheme.goldPrimary,
                                    size: 28,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Jewel Information
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onOpenProduct(product),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: HeritageTheme.goldPrimary
                                      .withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: HeritageTheme.goldBorderSubtle,
                                    width: 0.7,
                                  ),
                                ),
                                child: Text(
                                  '${product.purity} ${product.metal.toUpperCase()}',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: HeritageTheme.goldBright,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${product.weightGrams}g',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: HeritageTheme.textMutedDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: HeritageTheme.textLight,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rupees(product.price),
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: HeritageTheme.goldBright,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Remove from Wishlist Button (Filled Heart)
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: HeritageTheme.goldBright,
                      size: 22,
                    ),
                    tooltip: 'Remove from Wishlist',
                    onPressed: () {
                      store.removeFromWishlist(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed "${product.name}" from Wishlist'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(
              color: HeritageTheme.goldBorderSubtle,
              height: 1,
              thickness: 0.6,
            ),

            // Bottom Action Row: "Add to Cart" + "Buy Now"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // 1. "Add to Cart" Capsule Button
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: inCart
                            ? HeritageTheme.goldPrimary.withOpacity(0.18)
                            : const Color(0xCC051814),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: inCart
                              ? HeritageTheme.goldBright
                              : HeritageTheme.goldBorder,
                          width: 0.9,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            store.addToCart(product.id, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "${product.name}" to Cart (Qty: ${store.quantity(product.id)})',
                                ),
                                duration: const Duration(seconds: 1),
                                action: SnackBarAction(
                                  label: 'VIEW CART',
                                  textColor: HeritageTheme.goldBright,
                                  onPressed: onOpenBag,
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  inCart
                                      ? Icons.check_circle_rounded
                                      : Icons.shopping_bag_outlined,
                                  color: inCart
                                      ? HeritageTheme.goldBright
                                      : HeritageTheme.textLight,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  inCart ? 'In Cart (${store.quantity(product.id)})' : 'Add to Cart',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: inCart
                                        ? HeritageTheme.goldBright
                                        : HeritageTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 2. "Buy Now" Gold Gradient Pill Button
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: HeritageTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: HeritageTheme.goldPrimary.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            store.addToCart(product.id, 1);
                            onBuyNow(product);
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.flash_on_rounded,
                                  color: Color(0xFF1A1203),
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Buy Now',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1203),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sticky Bar: "Proceed to Cart"
  Widget _buildBottomActionBar(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xF2040D0B),
        border: const Border(
          top: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cart Items: ${store.count}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: HeritageTheme.textMutedDark,
                  ),
                ),
                Text(
                  rupees(store.subtotal),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HeritageTheme.goldBright,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: HeritageTheme.goldGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: HeritageTheme.goldPrimary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onOpenBag,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF1A1203),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View Cart',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1203),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
