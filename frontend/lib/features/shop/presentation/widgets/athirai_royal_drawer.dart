import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../screens/athirai_profile_dashboard_screen.dart';
import '../screens/athirai_order_summary_screen.dart';
import '../screens/athirai_recharge_screen.dart';
import '../screens/athirai_certified_coins_screen.dart';
import 'athirai_collections_megamenu_sheet.dart';

/// Luxury Royal Three-line (☰) Menu Drawer (Step 10 Point 2)
/// Allows instant navigation to:
/// - Profile Dashboard (Step 6)
/// - Order Summary (Step 10 & 11)
/// - Buy AUG Coins (Step 9)
/// - Certified Coins (Silver & Gold)
/// - Jewellery Collections & Royal Wishlist
class AthiraiRoyalDrawer extends StatelessWidget {
  const AthiraiRoyalDrawer({
    super.key,
    required this.store,
    this.onSelectHome,
    this.onSelectProfile,
    this.onSelectOrders,
    this.onSelectRecharge,
    this.onSelectCoins,
    this.onSelectCollections,
    this.onSelectWishlist,
    this.onSelectCart,
    this.onSignOut,
  });

  final ShopStore store;
  final VoidCallback? onSelectHome;
  final VoidCallback? onSelectProfile;
  final VoidCallback? onSelectOrders;
  final VoidCallback? onSelectRecharge;
  final VoidCallback? onSelectCoins;
  final VoidCallback? onSelectCollections;
  final VoidCallback? onSelectWishlist;
  final VoidCallback? onSelectCart;
  final VoidCallback? onSignOut;

  /// Convenience launcher to open the Royal Drawer from any top-right ☰ button
  static void show(
    BuildContext context, {
    required ShopStore store,
    VoidCallback? onSelectHome,
    VoidCallback? onSelectProfile,
    VoidCallback? onSelectOrders,
    VoidCallback? onSelectRecharge,
    VoidCallback? onSelectCoins,
    VoidCallback? onSelectCollections,
    VoidCallback? onSelectWishlist,
    VoidCallback? onSelectCart,
    VoidCallback? onSignOut,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AthiraiRoyalDrawer(
        store: store,
        onSelectHome: () {
          Navigator.of(ctx).pop();
          onSelectHome?.call();
        },
        onSelectProfile: () {
          Navigator.of(ctx).pop();
          if (onSelectProfile != null) {
            onSelectProfile();
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AthiraiProfileDashboardScreen(
                  store: store,
                  onOpenOrders: onSelectOrders,
                  onOpenCollection: onSelectCollections,
                  onOpenRecharge: onSelectRecharge,
                  onSignOut: onSignOut,
                ),
              ),
            );
          }
        },
        onSelectOrders: () {
          Navigator.of(ctx).pop();
          if (onSelectOrders != null) {
            onSelectOrders();
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AthiraiOrderSummaryScreen(
                  store: store,
                  onOpenMenu: () => show(
                    context,
                    store: store,
                    onSelectHome: onSelectHome,
                    onSelectProfile: onSelectProfile,
                    onSelectOrders: onSelectOrders,
                    onSelectRecharge: onSelectRecharge,
                    onSelectCollections: onSelectCollections,
                    onSelectWishlist: onSelectWishlist,
                    onSelectCart: onSelectCart,
                    onSignOut: onSignOut,
                  ),
                ),
              ),
            );
          }
        },
        onSelectRecharge: () {
          Navigator.of(ctx).pop();
          if (onSelectRecharge != null) {
            onSelectRecharge();
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AthiraiRechargeScreen(store: store),
              ),
            );
          }
        },
        onSelectCoins: () {
          Navigator.of(ctx).pop();
          if (onSelectCoins != null) {
            onSelectCoins();
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AthiraiCertifiedCoinsScreen(store: store),
              ),
            );
          }
        },
        onSelectCollections: () {
          Navigator.of(ctx).pop();
          onSelectCollections?.call();
        },
        onSelectWishlist: () {
          Navigator.of(ctx).pop();
          onSelectWishlist?.call();
        },
        onSelectCart: () {
          Navigator.of(ctx).pop();
          onSelectCart?.call();
        },
        onSignOut: () {
          Navigator.of(ctx).pop();
          onSignOut?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF04120E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: HeritageTheme.goldBorder, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: HeritageTheme.goldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Top Header: Patron details & AUG Coin counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFFFFDF7A), Color(0xFFC7A45B), Color(0xFF7A5822)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Color(0xFF030D0A), size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.deliveryName,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: HeritageTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x33D4AF37),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: HeritageTheme.goldBorder, width: 0.5),
                          ),
                          child: Text(
                            '🪙 ${store.augCoins.toInt()} AUG Coins',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: HeritageTheme.goldBright,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: HeritageTheme.goldPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _drawerItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Profile Dashboard',
                    subtitle: 'Account, address & vault settings',
                    badge: 'Step 6',
                    onTap: onSelectProfile,
                  ),
                  _drawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Order Summary',
                    subtitle: 'Purchased jewellery & tax receipts',
                    badge: 'Step 10',
                    isHighlighted: true,
                    onTap: onSelectOrders,
                  ),
                  _drawerItem(
                    icon: Icons.bolt_rounded,
                    title: 'Buy AUG Coins',
                    subtitle: 'Recharge vault via Razorpay (1 ₹ = 100 Coins)',
                    badge: 'Step 9',
                    onTap: onSelectRecharge,
                  ),
                  _drawerItem(
                    icon: Icons.monetization_on_outlined,
                    title: 'Certified Coins',
                    subtitle: 'Silver & Gold coins from Rs. 275/gm',
                    badge: 'Certified',
                    onTap: onSelectCoins,
                  ),
                  _drawerItem(
                    icon: Icons.grid_view_rounded,
                    title: 'All Jewellery Directory',
                    subtitle: '8 Categories • 74 Sub-Items (Megamenu)',
                    badge: 'Directory',
                    isHighlighted: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      AthiraiCollectionsMegamenuSheet.show(
                        context,
                        store: store,
                        onSelectItem: (col, item) {
                          onSelectCollections?.call();
                        },
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.diamond_outlined,
                    title: 'Jewellery Collections',
                    subtitle: 'Handcrafted gold & silver heirlooms',
                    onTap: onSelectCollections,
                  ),
                  _drawerItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Royal Wishlist',
                    subtitle: '${store.wishlistCount} curated pieces',
                    onTap: onSelectWishlist,
                  ),
                  _drawerItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Jewel Vault Bag',
                    subtitle: 'Cart & checkout ready',
                    onTap: onSelectCart,
                  ),
                  if (onSignOut != null) ...[
                    const Divider(color: HeritageTheme.goldBorderSubtle, height: 24),
                    _drawerItem(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Exit customer session',
                      color: const Color(0xFFEF4444),
                      onTap: onSignOut,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    bool isHighlighted = false,
    Color? color,
    required VoidCallback? onTap,
  }) {
    final effectiveColor = color ?? (isHighlighted ? HeritageTheme.goldBright : HeritageTheme.textLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted ? Border.all(color: HeritageTheme.goldBorder, width: 0.8) : null,
      ),
      child: Material(
        color: isHighlighted ? const Color(0x22D4AF37) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          dense: true,
          leading: Icon(icon, color: effectiveColor, size: 22),
          title: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.5),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.goldBright,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: HeritageTheme.textMutedDark,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: HeritageTheme.goldBorder,
          ),
        ),
      ),
    );
  }
}
