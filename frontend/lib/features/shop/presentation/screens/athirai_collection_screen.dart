import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_recharge_screen.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_profile_dashboard_screen.dart';
import '../widgets/athirai_royal_drawer.dart';


/// Screen 03: Collection Explorer ("Curated for Generations")
/// Exact match for Mockup Screen 03:
/// - `< Collections` with Search and Filter buttons
/// - Category filter chips: All, Necklaces (active), Rings, Bangles, Earrings
/// - "Heritage Dial" astrolabe banner card ("Timeless Designs Rooted in Tradition")
/// - Large "Featured" card: Temple Blossom Necklace (₹ 3,65,000)
/// - 2-Column Product Grid: Chola Dynasty Necklace (₹ 2,85,000), Lotus Grace Necklace (₹ 4,10,000)
/// - Bottom bar with gold compass emblem
class AthiraiCollectionScreen extends StatefulWidget {
  const AthiraiCollectionScreen({
    super.key,
    required this.store,
    required this.onBack,
    required this.onOpenProduct,
    required this.onOpenBag,
    this.onOpenWishlist,
    this.onBuyNow,
  });

  final ShopStore store;
  final VoidCallback onBack;
  final ValueChanged<ShopProduct> onOpenProduct;
  final VoidCallback onOpenBag;
  final VoidCallback? onOpenWishlist;
  final ValueChanged<ShopProduct>? onBuyNow;

  @override
  State<AthiraiCollectionScreen> createState() =>
      _AthiraiCollectionScreenState();
}

class _AthiraiCollectionScreenState extends State<AthiraiCollectionScreen> {
  String _selectedCategory = 'Necklaces';

  List<String> get _categories {
    final list = <String>['All'];
    for (final c in widget.store.categories) {
      if (!list.contains(c.name)) list.add(c.name);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final categories = _categories;
        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }

        final filtered = _selectedCategory == 'All'
            ? widget.store.products
            : widget.store.products
                .where((p) =>
                    p.category.toLowerCase() == _selectedCategory.toLowerCase() ||
                    (_selectedCategory.toLowerCase() == 'coins' &&
                        (p.category.toLowerCase().contains('coin') ||
                            p.name.toLowerCase().contains('coin'))))
                .toList();
        final effectiveProducts = filtered.isNotEmpty ? filtered : widget.store.products;


        final featuredProduct = effectiveProducts.firstWhere(
          (p) => p.item.name.contains('Temple Blossom'),
          orElse: () => effectiveProducts.firstWhere(
            (p) => p.item.name.contains('Temple') || p.item.name.contains('Cosmic'),
            orElse: () => effectiveProducts.first,
          ),
        );

        final remainingProducts = effectiveProducts.where((p) => p.id != featuredProduct.id).toList();

        return Scaffold(
          backgroundColor: HeritageTheme.darkBg,
          body: Stack(
            children: [
              // Background subtle dark emerald gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.2, -0.3),
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
                    // 1. Top App Bar: < Collections, Search, Filter
                    _buildTopAppBar(context),

                    // 2. Filter Chips Row (Dynamic from backend)
                    _buildFilterChips(),

                    const SizedBox(height: 10),

                    // Scrollable Content with Pull-to-Refresh
                    Expanded(
                      child: RefreshIndicator(
                        color: HeritageTheme.goldBright,
                        backgroundColor: const Color(0xFF04100D),
                        onRefresh: () => widget.store.loadFromBackend(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 3. Hero Card: "Heritage Dial"
                              _buildHeritageDialCard(),

                              const SizedBox(height: 16),

                              // 4. Large Featured Card: Dynamic Temple Blossom Necklace
                              _buildFeaturedProductCard(context, featuredProduct),

                              const SizedBox(height: 16),

                              // 5. Dynamic 2-Column Product Grid from Backend
                              _buildTwoColumnGrid(context, remainingProducts),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 6. Minimalist Bottom Accent Bar with Gold Compass
                    _buildBottomCompassBar(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Top App Bar matching Screen 03 header with live Wishlist and Cart shortcuts
  Widget _buildTopAppBar(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final wishlistCount = widget.store.wishlistCount;
        final cartCount = widget.store.count;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: HeritageTheme.textLight,
                  size: 19,
                ),
                onPressed: widget.onBack,
              ),
              Text(
                'Collections',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: HeritageTheme.textLight,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              // AUG Coins Wallet shortcut
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiRechargeScreen(store: widget.store),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x66D4AF37), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        widget.store.augCoins.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFDF7A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Wishlist shortcut button with live badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(

                    icon: Icon(
                      wishlistCount > 0
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: wishlistCount > 0
                          ? HeritageTheme.goldBright
                          : HeritageTheme.textLight,
                      size: 21,
                    ),
                    tooltip: 'Wishlist',
                    onPressed: widget.onOpenWishlist,
                  ),
                  if (wishlistCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: HeritageTheme.goldBright,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Center(
                          child: Text(
                            '$wishlistCount',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF04100D),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Cart shortcut button with live badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: HeritageTheme.textLight,
                      size: 21,
                    ),
                    tooltip: 'Shopping Bag',
                    onPressed: widget.onOpenBag,
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: HeritageTheme.goldBright,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Center(
                          child: Text(
                            '$cartCount',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF04100D),
                            ),
                          ),
                        ),
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
                    store: widget.store,
                    onSelectHome: widget.onBack,
                    onSelectProfile: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AthiraiProfileDashboardScreen(
                            store: widget.store,
                          ),
                        ),
                      );
                    },
                    onSelectOrders: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AthiraiOrderSummaryScreen(
                            store: widget.store,
                          ),
                        ),
                      );
                    },
                    onSelectWishlist: widget.onOpenWishlist,
                    onSelectCart: widget.onOpenBag,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Horizontal category filter chips
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x33D4AF37) : const Color(0x80071C17),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? HeritageTheme.goldPrimary
                      : HeritageTheme.goldBorderSubtle,
                  width: isSelected ? 1.2 : 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: HeritageTheme.goldPrimary.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? HeritageTheme.goldBright
                        : HeritageTheme.textMutedDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Heritage Dial card: Astrolabe + "Timeless Designs Rooted in Tradition"
  Widget _buildHeritageDialCard() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xCC071B16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Left Astrolabe Dial Thumbnail
            Container(
              width: 110,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.8)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.heritageDial,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF09201A),
                      child: const Icon(Icons.explore, color: HeritageTheme.goldPrimary),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Heritage\nDial',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: HeritageTheme.goldPrimary,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Right Text: "Timeless Designs Rooted in Tradition"
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Timeless',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HeritageTheme.textLight,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Designs',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HeritageTheme.goldPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rooted in Tradition',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: HeritageTheme.textMutedDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Featured Product Card: Dynamic Temple Blossom Necklace with live rate calculation
  Widget _buildFeaturedProductCard(BuildContext context, ShopProduct product) {
    final isTempleBlossom = product.name.contains('Temple Blossom');
    final nameFirst = isTempleBlossom
        ? 'Temple Blossom'
        : (product.name.contains(' ')
            ? product.name.substring(0, product.name.lastIndexOf(' '))
            : product.name);
    final nameSecond = isTempleBlossom
        ? 'Necklace'
        : (product.name.contains(' ')
            ? product.name.substring(product.name.lastIndexOf(' ') + 1)
            : product.category);

    return GestureDetector(
      onTap: () => widget.onOpenProduct(product),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: HeritageTheme.emeraldGlow,
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Emerald velvet pedestal necklace image
              Image.asset(
                AppAssets.pedestalNecklace,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF071C17),
                  child: const Center(
                    child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary, size: 48),
                  ),
                ),
              ),

              // Gradient vignette for text readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // "Featured" Pill Badge at Top Left
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xD9061814),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
                  ),
                  child: Text(
                    'Featured',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: HeritageTheme.goldBright,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),

              // Bottom Details: Title, Specs, Price, and Actions (Wishlist, Add to Cart, Buy Now)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameFirst,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: HeritageTheme.textLight,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                nameSecond,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: HeritageTheme.textLight,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.purity} ${product.metal} • ${product.weightGrams}g',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: HeritageTheme.textMutedDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rupees(product.price),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: HeritageTheme.goldBright,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Wishlist Heart Toggle Icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xCC051814),
                            border: Border.all(
                              color: widget.store.isSaved(product.id)
                                  ? HeritageTheme.goldBright
                                  : HeritageTheme.goldBorderSubtle,
                              width: 0.8,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                widget.store.toggleWishlist(product.id);
                                final isSaved = widget.store.isSaved(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSaved
                                          ? 'Added "${product.name}" to Wishlist'
                                          : 'Removed from Wishlist',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Icon(
                                widget.store.isSaved(product.id)
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: widget.store.isSaved(product.id)
                                    ? HeritageTheme.goldBright
                                    : HeritageTheme.textLight,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Quick Action Buttons Row: "Add to Cart" + "Buy Now"
                    Row(
                      children: [
                        // "Add to Cart" Capsule
                        Expanded(
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xCC071B16),
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: HeritageTheme.goldBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(17),
                                onTap: () {
                                  widget.store.addToCart(product.id, 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added "${product.name}" to Cart',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      action: SnackBarAction(
                                        label: 'VIEW CART',
                                        textColor: HeritageTheme.goldBright,
                                        onPressed: widget.onOpenBag,
                                      ),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: HeritageTheme.goldPrimary,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add to Cart',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: HeritageTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // "Buy Now" Gold Gradient Pill
                        Expanded(
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: HeritageTheme.goldGradient,
                              borderRadius: BorderRadius.circular(17),
                              boxShadow: [
                                BoxShadow(
                                  color: HeritageTheme.goldPrimary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(17),
                                onTap: () {
                                  widget.store.addToCart(product.id, 1);
                                  if (widget.onBuyNow != null) {
                                    widget.onBuyNow!(product);
                                  } else {
                                    widget.onOpenBag();
                                  }
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.flash_on_rounded,
                                        color: Color(0xFF1A1203),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Buy Now',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1203),
                                          letterSpacing: 0.2,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2-Column Product Grid rendered dynamically from backend products
  Widget _buildTwoColumnGrid(BuildContext context, List<ShopProduct> products) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          'No other items in this category.',
          style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.textMutedDark),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = products[index];
        final titleFirst = item.name.contains(' ')
            ? item.name.substring(0, item.name.lastIndexOf(' '))
            : item.name;
        final titleSecond = item.name.contains(' ')
            ? item.name.substring(item.name.lastIndexOf(' ') + 1)
            : item.category;

        return GestureDetector(
          onTap: () => widget.onOpenProduct(item),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xCC071B16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0x55040F0D),
                      child: item.image.startsWith('http')
                          ? Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary),
                              ),
                            )
                          : Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary),
                              ),
                            ),
                    ),
                  ),

                  // Info & Direct Shopping Actions
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleFirst,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: HeritageTheme.textLight,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          titleSecond,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: HeritageTheme.textMutedDark,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Price + Wishlist Heart Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rupees(item.price),
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: HeritageTheme.goldBright,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.store.toggleWishlist(item.id);
                                final isSaved = widget.store.isSaved(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSaved
                                          ? 'Added "${item.name}" to Wishlist'
                                          : 'Removed from Wishlist',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Icon(
                                widget.store.isSaved(item.id)
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: widget.store.isSaved(item.id)
                                    ? HeritageTheme.goldBright
                                    : HeritageTheme.textMutedDark,
                                size: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        // Direct Action Buttons: "Add to Cart" + "Buy Now"
                        Row(
                          children: [
                            // "Add to Cart" mini button
                            Expanded(
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xCC051814),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: HeritageTheme.goldBorderSubtle,
                                    width: 0.8,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      widget.store.addToCart(item.id, 1);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Added "${item.name}" to Cart'),
                                          duration: const Duration(seconds: 1),
                                          action: SnackBarAction(
                                            label: 'CART',
                                            textColor: HeritageTheme.goldBright,
                                            onPressed: widget.onOpenBag,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_bag_outlined,
                                            color: HeritageTheme.goldPrimary,
                                            size: 11,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Cart',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: HeritageTheme.textLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            // "Buy Now" mini button
                            Expanded(
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: HeritageTheme.goldGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      widget.store.addToCart(item.id, 1);
                                      if (widget.onBuyNow != null) {
                                        widget.onBuyNow!(item);
                                      } else {
                                        widget.onOpenBag();
                                      }
                                    },
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.flash_on_rounded,
                                            color: Color(0xFF1A1203),
                                            size: 11,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'Buy',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1A1203),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Minimalist bottom accent bar with gold compass emblem
  Widget _buildBottomCompassBar() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
          ),
          child: const Center(
            child: Icon(
              Icons.explore_outlined,
              color: HeritageTheme.goldPrimary,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
