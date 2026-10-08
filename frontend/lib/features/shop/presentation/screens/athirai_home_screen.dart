import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import 'athirai_recharge_screen.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_profile_dashboard_screen.dart';
import '../widgets/athirai_royal_drawer.dart';

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
    this.onOpenRecharge,
    this.onOpenCoins,
    this.onLotusTap,
    this.onOpenStudio,
    this.onOpenPriceList,
    this.onOpenOrders,
    this.onOpenProfile,
    this.onOpenMenu,
    this.onSignOut,
  });

  final ShopStore store;
  final VoidCallback onOpenCollection;
  final ValueChanged<ShopProduct> onOpenProduct;
  final VoidCallback onOpenBag;
  final VoidCallback onOpenWishlist;
  final VoidCallback onOpenSearch;
  final VoidCallback? onOpenRecharge;
  final VoidCallback? onOpenCoins;
  final VoidCallback? onLotusTap;
  final VoidCallback? onOpenStudio;
  final VoidCallback? onOpenPriceList;
  final VoidCallback? onOpenOrders;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onSignOut;


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
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

              // Scrollable Content with Pull-to-Refresh from Backend
              SafeArea(
                child: RefreshIndicator(
                  color: HeritageTheme.goldBright,
                  backgroundColor: const Color(0xFF04100D),
                  onRefresh: () => store.loadFromBackend(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(left: 64, right: 16, top: 8, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header: Welcome, Notification, Avatar
                        _buildHeader(context),

                        // Live Rates Ticker Bar (connected to backend)
                        _buildLiveRatesBar(context),

                        const SizedBox(height: 14),

                        // "Discover Your Legacy" Title + Star
                        _buildTitleSection(),

                        const SizedBox(height: 14),

                        // Hero Sphere: Floating Necklace in Glass Orb
                        _buildHeroSphere(context, featuredProduct),

                        const SizedBox(height: 22),

                        // "Explore Categories" (Dynamic from backend)
                        _buildExploreCategories(context),

                        const SizedBox(height: 18),

                        // Bottom Banner: "A Legacy in Every Piece"
                        _buildLegacyBanner(context),
                      ],
                    ),
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
      },
    );
  }

  /// Live Metal Rates Ticker Bar connected to Django REST backend
  Widget _buildLiveRatesBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE6061814),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: store.isLiveBackend ? const Color(0xFF00E676) : HeritageTheme.goldBright,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (store.isLiveBackend ? const Color(0xFF00E676) : HeritageTheme.goldBright)
                      .withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE RATES',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: HeritageTheme.goldBright,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onOpenCoins ?? onOpenCollection,
                    child: _rateBadge('22K', '₹${store.rates.gold22k}/g'),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onOpenCoins ?? onOpenCollection,
                    child: _rateBadge('24K', '₹${store.rates.gold24k}/g'),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onOpenCoins ?? onOpenCollection,
                    child: _rateBadge('Silver', '₹${store.rates.silver999.toStringAsFixed(1)}/g'),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              store.loadFromBackend();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing live rates & products from backend...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Icon(
              store.isLoadingBackend ? Icons.sync : Icons.refresh_rounded,
              color: HeritageTheme.goldPrimary,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x33D4AF37),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: HeritageTheme.textLight,
        ),
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
          const SizedBox(height: 18),
          // Explore / Gem icon
          GestureDetector(
            onTap: onOpenCollection,
            child: const Icon(
              Icons.explore_outlined,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
          const SizedBox(height: 18),
          // Diamond / Studio icon
          GestureDetector(
            onTap: onLotusTap ?? onOpenCollection,
            child: const Icon(
              Icons.diamond_outlined,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
          const SizedBox(height: 18),
          // Wishlist Heart icon with live badge
          GestureDetector(
            onTap: onOpenWishlist,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  store.wishlistCount > 0
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: store.wishlistCount > 0
                      ? HeritageTheme.goldBright
                      : HeritageTheme.textMutedDark,
                  size: 20,
                ),
                if (store.wishlistCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: HeritageTheme.goldBright,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Center(
                        child: Text(
                          '${store.wishlistCount}',
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF04100D),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Shopping Bag icon with live badge
          GestureDetector(
            onTap: onOpenBag,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  store.count > 0
                      ? Icons.shopping_bag_rounded
                      : Icons.shopping_bag_outlined,
                  color: store.count > 0
                      ? HeritageTheme.goldBright
                      : HeritageTheme.textMutedDark,
                  size: 20,
                ),
                if (store.count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: HeritageTheme.goldBright,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Center(
                        child: Text(
                          '${store.count}',
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF04100D),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // AUG Coins Wallet & Recharge icon
          GestureDetector(
            onTap: onOpenRecharge ??
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiRechargeScreen(store: store),
                    ),
                  );
                },
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: HeritageTheme.textMutedDark,
              size: 20,
            ),
          ),
          const SizedBox(height: 18),
          // Profile / Account icon (Step 6)
          GestureDetector(
            onTap: () {
              if (onOpenProfile != null) {
                onOpenProfile!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AthiraiProfileDashboardScreen(
                      store: store,
                      onOpenOrders: onOpenOrders,
                      onOpenCollection: onOpenCollection,
                      onOpenRecharge: onOpenRecharge,
                      onSignOut: onSignOut,
                    ),
                  ),
                );
              }
            },
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

  /// Header with user greeting, wishlist shortcut, notification bell, profile avatar
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Star sparkle emblem
        const Icon(
          Icons.auto_awesome_rounded,
          color: HeritageTheme.goldPrimary,
          size: 15,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: GestureDetector(
            onTap: () => _showUserProfileModal(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back,',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: HeritageTheme.textMutedDark,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Ananya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HeritageTheme.textLight,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        // AUG Coins Wallet & Recharge Badge
        InkWell(
          onTap: onOpenRecharge ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AthiraiRechargeScreen(store: store),
                  ),
                );
              },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0x33D4AF37),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x88D4AF37), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 3),
                Text(
                  '${store.augCoins.toStringAsFixed(1)} AUG',
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
        // Notification bell with badge dot
        Stack(
          children: [
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: HeritageTheme.textLight,
                size: 20,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: HeritageTheme.goldPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        // User Profile Avatar with circular gold ring (Step 6)
        GestureDetector(
          onTap: () {
            if (onOpenProfile != null) {
              onOpenProfile!();
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AthiraiProfileDashboardScreen(
                    store: store,
                    onOpenOrders: onOpenOrders,
                    onOpenCollection: onOpenCollection,
                    onOpenRecharge: onOpenRecharge,
                    onSignOut: onSignOut,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: HeritageTheme.goldPrimary, width: 1.4),
              image: const DecorationImage(
                image: AssetImage(AppAssets.profileAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Three-line menu button (☰) in top-right corner (Step 10 Point 2)
        IconButton(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.menu_rounded,
            color: HeritageTheme.goldBright,
            size: 23,
          ),
          tooltip: 'Menu (Order Summary & Vault)',
          onPressed: () {
            if (onOpenMenu != null) {
              onOpenMenu!();
            } else {
              AthiraiRoyalDrawer.show(
                context,
                store: store,
                onSelectHome: () {},
                onSelectProfile: () {
                  if (onOpenProfile != null) {
                    onOpenProfile!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AthiraiProfileDashboardScreen(
                          store: store,
                          onOpenOrders: onOpenOrders,
                          onOpenCollection: onOpenCollection,
                          onOpenRecharge: onOpenRecharge,
                          onSignOut: onSignOut,
                        ),
                      ),
                    );
                  }
                },
                onSelectOrders: () {
                  if (onOpenOrders != null) {
                    onOpenOrders!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AthiraiOrderSummaryScreen(
                          store: store,
                          onOpenMenu: onOpenMenu,
                          onExploreJewels: onOpenCollection,
                        ),
                      ),
                    );
                  }
                },
                onSelectRecharge: onOpenRecharge,
                onSelectCoins: onOpenCoins,
                onSelectCollections: onOpenCollection,
                onSelectWishlist: onOpenWishlist,
                onSelectCart: onOpenBag,
                onSignOut: onSignOut,
              );
            }
          },
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

              // Bottom pill badge: "The Timeless Necklace" with dynamic price & play button
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
                          const SizedBox(height: 1),
                          Text(
                            rupees(product.price),
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: HeritageTheme.goldBright,
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

  /// "Explore Categories" section with dynamic categories from backend
  Widget _buildExploreCategories(BuildContext context) {
    // Dynamic categories from backend & store
    final categories = store.categories.take(6).toList();

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
            final iconData = switch (cat.name.toLowerCase()) {
              'necklaces' => Icons.circle_outlined,
              'rings' => Icons.circle_outlined,
              'bangles' => Icons.circle_outlined,
              'earrings' => Icons.circle_outlined,
              'heritage' => Icons.temple_hindu_outlined,
              'temple' => Icons.temple_hindu_rounded,
              'coins' => Icons.monetization_on_outlined,
              _ => Icons.auto_awesome,
            };

            return GestureDetector(
              onTap: () {
                if (cat.name.toLowerCase().contains('coin') && onOpenCoins != null) {
                  onOpenCoins!();
                } else {
                  onOpenCollection();
                }
              },
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
                        child: cat.image.startsWith('http')
                            ? Image.network(
                                cat.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  iconData,
                                  color: HeritageTheme.goldPrimary,
                                  size: 18,
                                ),
                              )
                            : Image.asset(
                                cat.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  iconData,
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
                        cat.name,
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

  /// Profile Details, Settings & Logout Modal Sheet
  void _showUserProfileModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        bool notificationAlerts = true;
        bool biometricEnabled = true;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xF7041410),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Handle pill
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HeritageTheme.goldBorderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Top Bar with Title and Close
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.diamond_outlined,
                            color: HeritageTheme.goldPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ROYAL VAULT & SETTINGS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: HeritageTheme.goldPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: HeritageTheme.textMutedDark,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: HeritageTheme.goldBorderSubtle, height: 1),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── User Profile Header Card ────────────────────────
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0x990A221C),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: HeritageTheme.goldBorderSubtle,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: HeritageTheme.goldPrimary,
                                        width: 1.8,
                                      ),
                                      image: const DecorationImage(
                                        image: AssetImage(AppAssets.profileAvatar),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ananya Sharma',
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: HeritageTheme.textLight,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'ananya@athirai.com  ·  +91 98765 43210',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.5,
                                            color: HeritageTheme.textMutedDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: HeritageTheme.goldPrimary.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: HeritageTheme.goldBorderSubtle,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.stars_rounded,
                                                color: HeritageTheme.goldBright,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'ROYAL PRIVILEGE MEMBER',
                                                style: GoogleFonts.inter(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1.0,
                                                  color: HeritageTheme.goldBright,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── User Details Section ────────────────────────────
                            Text(
                              'PROFILE DETAILS',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: HeritageTheme.goldPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildInfoTile(
                              icon: Icons.badge_outlined,
                              title: 'Member Identification',
                              subtitle: 'ATH-8842-IND (Verified Heirloom Collector)',
                            ),
                            _buildInfoTile(
                              icon: Icons.location_on_outlined,
                              title: 'Default Delivery Address',
                              subtitle: 'No. 42, Cathedral Road, Chennai - 600086',
                            ),
                            _buildInfoTile(
                              icon: Icons.lock_outline_rounded,
                              title: 'Saved in Jewel Vault',
                              subtitle: '${store.count} heirloom items currently in Bag',
                            ),
                            _buildInfoTile(
                              icon: Icons.verified_outlined,
                              title: 'Hallmarking Guarantee',
                              subtitle: '100% Certified 916 Gold & Platinum Authenticated',
                            ),

                            const SizedBox(height: 22),

                            // ── App Settings Section ────────────────────────────
                            Text(
                              'SETTINGS & PREFERENCES',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: HeritageTheme.goldPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildSettingSwitchTile(
                              icon: Icons.notifications_none_rounded,
                              title: 'Rate Alerts & Notifications',
                              subtitle: 'Instant updates on 22K/24K daily market rates',
                              value: notificationAlerts,
                              onChanged: (val) {
                                setModalState(() => notificationAlerts = val);
                              },
                            ),
                            _buildSettingSwitchTile(
                              icon: Icons.fingerprint_rounded,
                              title: 'Biometric & Face ID Unlock',
                              subtitle: 'Secure express authorization for vault items',
                              value: biometricEnabled,
                              onChanged: (val) {
                                setModalState(() => biometricEnabled = val);
                              },
                            ),
                            _buildActionSettingTile(
                              icon: Icons.currency_rupee_rounded,
                              title: 'Preferred Currency',
                              trailingText: 'INR (₹) - India',
                              onTap: () {},
                            ),
                            _buildActionSettingTile(
                              icon: Icons.history_edu_rounded,
                              title: 'Order History & Certificates',
                              trailingText: 'View Vault History  →',
                              onTap: () {
                                Navigator.pop(modalContext);
                                onOpenBag();
                              },
                            ),
                            _buildActionSettingTile(
                              icon: Icons.support_agent_rounded,
                              title: 'Athirai Concierge Service',
                              trailingText: 'concierge@athirai.com',
                              onTap: () {},
                            ),

                            const SizedBox(height: 28),

                            // ── LOGOUT BUTTON ──────────────────────────────────
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0x2BD32F2F),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: const Color(0xFFE57373).withOpacity(0.55),
                                  width: 1.2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(26),
                                  onTap: () => _confirmSignOut(context, modalContext),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.logout_rounded,
                                        color: Color(0xFFFF8A80),
                                        size: 19,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Sign Out of Athirai',
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: const Color(0xFFFFCDD2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'ATHIRAI APP v2.4  ·  TIMELESS LUXURY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: HeritageTheme.textMutedDark.withOpacity(0.7),
                                  letterSpacing: 1.2,
                                ),
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
          },
        );
      },
    );
  }

  Future<void> _confirmSignOut(
    BuildContext parentContext,
    BuildContext modalContext,
  ) async {
    final confirmed = await showDialog<bool>(
      context: modalContext,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xF7071B16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageTheme.goldBorder, width: 1.0),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF8A80),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Sign Out of Athirai?',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: HeritageTheme.textLight,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end your current session? You will be returned to the sign-in screen.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: HeritageTheme.textMutedDark,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: HeritageTheme.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (modalContext.mounted) {
        Navigator.pop(modalContext); // close bottom sheet
      }
      if (onSignOut != null) {
        onSignOut!();
      } else if (parentContext.mounted) {
        Navigator.of(parentContext).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x66061B16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: HeritageTheme.goldPrimary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: HeritageTheme.textMutedDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: HeritageTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x66061B16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: HeritageTheme.goldPrimary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HeritageTheme.textLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: HeritageTheme.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: HeritageTheme.goldBright,
            activeTrackColor: HeritageTheme.goldPrimary.withOpacity(0.35),
            inactiveThumbColor: HeritageTheme.textMutedDark,
            inactiveTrackColor: Colors.black26,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSettingTile({
    required IconData icon,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0x66061B16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: HeritageTheme.goldPrimary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HeritageTheme.textLight,
                    ),
                  ),
                ),
                Text(
                  trailingText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: HeritageTheme.goldBright,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: HeritageTheme.goldBorderSubtle,
                  size: 11,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
