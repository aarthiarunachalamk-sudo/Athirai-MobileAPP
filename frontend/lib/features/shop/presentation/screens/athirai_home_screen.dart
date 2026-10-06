import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';

/// Screen 02: Home / Experience Dashboard ("Discover Your Legacy")
/// Exact match for Mockup Screen 02:
/// - Left floating vertical navigation glass rail
/// - "Welcome back, Ananya" with notification bell & avatar
/// - "Discover Your Legacy" with 8-point celestial gold star
/// - Translucent emerald celestial sphere with floating "The Timeless Necklace"
/// - "Explore Categories" 6-item capsules (Necklaces, Rings, Bangles, Earrings, Heritage, Contemporary)
/// - Bottom banner: "A Legacy in Every Piece  →"
class AthiraiHomeScreen extends StatelessWidget {
  const AthiraiHomeScreen({
    super.key,
    required this.store,
    required this.onOpenCollection,
    required this.onOpenProduct,
    required this.onOpenBag,
    required this.onOpenWishlist,
    required this.onOpenSearch,
    this.onLotusTap,
    this.onOpenStudio,
    this.onOpenPriceList,
  });

  final ShopStore store;
  final VoidCallback onOpenCollection;
  final ValueChanged<ShopProduct> onOpenProduct;
  final VoidCallback onOpenBag;
  final VoidCallback onOpenWishlist;
  final VoidCallback onOpenSearch;
  final VoidCallback? onLotusTap;
  final VoidCallback? onOpenStudio;
  final VoidCallback? onOpenPriceList;

  @override
  Widget build(BuildContext context) {
    final featuredProduct = store.products.firstWhere(
      (p) => p.item.name.contains('Temple') || p.item.name.contains('Cosmic'),
      orElse: () => store.products.first,
    );

    return Scaffold(
      backgroundColor: HeritageTheme.darkBg,
      body: Stack(
        children: [
          // Background atmospheric dark emerald gradients
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.4, -0.2),
                radius: 1.1,
                colors: [
                  Color(0xFF09201A),
                  Color(0xFF04100D),
                  Color(0xFF020706),
                ],
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 64, right: 16, top: 8, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: Welcome, Notification, Avatar
                  _buildHeader(context),

                  const SizedBox(height: 18),

                  // "Discover Your Legacy" Title + Star
                  _buildTitleSection(),

                  const SizedBox(height: 14),

                  // Hero Sphere: Floating Necklace in Glass Orb
                  _buildHeroSphere(context, featuredProduct),

                  const SizedBox(height: 22),

                  // "Explore Categories"
                  _buildExploreCategories(context),

                  const SizedBox(height: 18),

                  // Bottom Banner: "A Legacy in Every Piece"
                  _buildLegacyBanner(context),
                ],
              ),
            ),
          ),

          // Left Floating Vertical Navigation Rail (Pinned on the left)
          Positioned(
            left: 12,
            top: 90,
            bottom: 90,
            child: _buildLeftNavRail(context),
          ),
        ],
      ),
    );
  }

  /// Left floating glass navigation capsule
  Widget _buildLeftNavRail(BuildContext context) {
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xE6061814),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(2, 4),
          ),
          BoxShadow(
            color: HeritageTheme.goldPrimary.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home icon (active filled gold)
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: HeritageTheme.goldPrimary.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_rounded,
              color: HeritageTheme.goldBright,
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          // Explore / Gem icon
          GestureDetector(
            onTap: onOpenCollection,
            child: const Icon(
              Icons.explore_outlined,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          // Diamond / Studio icon
          GestureDetector(
            onTap: onLotusTap ?? onOpenCollection,
            child: const Icon(
              Icons.diamond_outlined,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          // Sparkle / Wishlist icon
          GestureDetector(
            onTap: onOpenWishlist,
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          // Profile / Vault icon
          GestureDetector(
            onTap: onOpenBag,
            child: const Icon(
              Icons.person_outline_rounded,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Header with user greeting, notification bell, profile avatar
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Star sparkle emblem
        const Icon(
          Icons.auto_awesome_rounded,
          color: HeritageTheme.goldPrimary,
          size: 16,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back,',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: HeritageTheme.textMutedDark,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Ananya',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: HeritageTheme.textLight,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell with badge dot
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: HeritageTheme.textLight,
                size: 22,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: HeritageTheme.goldPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        // User Profile Avatar with circular gold ring
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: HeritageTheme.goldPrimary, width: 1.4),
            image: const DecorationImage(
              image: AssetImage(AppAssets.profileAvatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  /// "Discover Your Legacy" Title with 8-pointed gold star
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover\nYour Legacy',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: HeritageTheme.textLight,
                  height: 1.08,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.star_rounded,
                  color: HeritageTheme.goldPrimary.withOpacity(0.85),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Ancient Roots. Eternal Beauty.',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: HeritageTheme.goldPrimary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  /// Hero Sphere: Translucent glowing glass orb with floating necklace
  Widget _buildHeroSphere(BuildContext context, ShopProduct product) {
    return GestureDetector(
      onTap: () => onOpenProduct(product),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: HeritageTheme.emeraldGlow,
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // High-res hero sphere necklace image
              Image.asset(
                AppAssets.heroSphereNecklace,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF071C17),
                  child: const Center(
                    child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary, size: 48),
                  ),
                ),
              ),

              // Gradient vignette inside the card
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom pill badge: "The Timeless Necklace" with play button
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xD9061814),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'The Timeless',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: HeritageTheme.textMutedDark,
                            ),
                          ),
                          Text(
                            'Necklace',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: HeritageTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: HeritageTheme.goldPrimary.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: HeritageTheme.goldPrimary, width: 0.8),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: HeritageTheme.goldBright,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Explore Categories" section with 6 circular capsule items
  Widget _buildExploreCategories(BuildContext context) {
    final categories = [
      {'name': 'Necklaces', 'icon': Icons.circle_outlined, 'image': AppAssets.shopNecklace},
      {'name': 'Rings', 'icon': Icons.circle_outlined, 'image': AppAssets.shopRing},
      {'name': 'Bangles', 'icon': Icons.circle_outlined, 'image': AppAssets.shopBangle},
      {'name': 'Earrings', 'icon': Icons.circle_outlined, 'image': AppAssets.shopEarrings},
      {'name': 'Heritage', 'icon': Icons.temple_hindu_outlined, 'image': AppAssets.heritageNecklace},
      {'name': 'Contemporary', 'icon': Icons.auto_awesome, 'image': AppAssets.pedestalNecklace},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore\nCategories',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: HeritageTheme.textLight,
            height: 1.15,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        // 3x2 Grid of Category Capsule Cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.80,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: onOpenCollection,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Jewel Thumbnail / Icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: HeritageTheme.goldBorder, width: 1.0),
                        color: const Color(0x55040F0D),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          cat['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            cat['icon'] as IconData,
                            color: HeritageTheme.goldPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cat['name'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: HeritageTheme.textLight,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Bottom Banner: "A Legacy in Every Piece  →"
  Widget _buildLegacyBanner(BuildContext context) {
    return GestureDetector(
      onTap: onOpenCollection,
      child: Container(
        height: 80,
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
              // Ancient temple stone ruin thumbnail
              SizedBox(
                width: 80,
                height: double.infinity,
                child: Image.asset(
                  AppAssets.heritageHome,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF09201A),
                    child: const Icon(Icons.temple_hindu_rounded, color: HeritageTheme.goldPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A Legacy',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: HeritageTheme.textLight,
                        ),
                      ),
                      Text(
                        'in Every Piece',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: HeritageTheme.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HeritageTheme.goldPrimary.withOpacity(0.18),
                  border: Border.all(color: HeritageTheme.goldPrimary, width: 0.9),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: HeritageTheme.goldBright,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
