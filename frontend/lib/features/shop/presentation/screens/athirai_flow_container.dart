import 'package:flutter/material.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_cart_screen.dart';
import 'athirai_collection_screen.dart';
import 'athirai_home_screen.dart';
import 'athirai_product_detail_screen.dart';
import 'athirai_splash_screen.dart';
import 'athirai_wishlist_screen.dart';
import 'athirai_recharge_screen.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_profile_dashboard_screen.dart';
import '../widgets/athirai_purchase_sheet.dart';
import '../widgets/athirai_royal_drawer.dart';
import '../../../auth/presentation/screens/athirai_otp_verification_screen.dart';

import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../auth/data/services/secure_storage_service.dart';
import 'package:athirai_mobile/features/vault_cms/presentation/screens/shell/vault_app_root.dart';



/// Master container providing exact fidelity for all Athirai Screens:
/// 01 Splash / Onboarding ("Enter the Heritage")
/// 02 Home Screen ("Discover Your Legacy")
/// 03 Collection Explorer ("Curated for Generations")
/// 04 Product Detail ("Crafted in Every Detail")
/// 05 Styling / Checkout ("Your Jewel Vault")
/// 06 Royal Wishlist ("Your Curated Heirlooms")
/// 07 Recharge & AUG Coins
/// 08 Order Summary & Receipts (Steps 10 & 11)
/// 09 Profile Dashboard & Vault (Steps 6 & 7)
/// + Verify Your Number (Image 2 Screen 4)
class AthiraiFlowContainer extends StatefulWidget {
  const AthiraiFlowContainer({
    super.key,
    this.initialScreenIndex = 0,
    this.store,
    this.onStylist,
    this.onSignOut,
  });

  final int initialScreenIndex;
  final ShopStore? store;
  final VoidCallback? onStylist;
  final VoidCallback? onSignOut;

  @override
  State<AthiraiFlowContainer> createState() => _AthiraiFlowContainerState();
}

class _AthiraiFlowContainerState extends State<AthiraiFlowContainer> {
  late final ShopStore store = widget.store ?? ShopStore.session;
  late int _currentScreen; // 0: Splash, 1: Home, 2: Collection, 3: Product, 4: Vault/Checkout, 5: OTP, 6: Wishlist, 7: Recharge, 8: Orders, 9: Profile
  ShopProduct? _activeProduct;
  final List<int> _screenHistory = [];

  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialScreenIndex;
    _activeProduct = store.products.firstWhere(
      (p) => p.item.name.contains('Temple') || p.item.name.contains('Cosmic'),
      orElse: () => store.products.first,
    );
  }

  void _navigateTo(int screenIndex, {ShopProduct? product}) {
    if (screenIndex != _currentScreen) {
      _screenHistory.add(_currentScreen);
    }
    setState(() {
      _currentScreen = screenIndex;
      if (product != null) _activeProduct = product;
    });
  }

  void _navigateBack() {
    if (_screenHistory.isNotEmpty) {
      final prev = _screenHistory.removeLast();
      setState(() => _currentScreen = prev);
    } else if (_currentScreen != 1) {
      setState(() => _currentScreen = 1);
    }
  }

  void _openRoyalDrawer() {
    AthiraiRoyalDrawer.show(
      context,
      store: store,
      onSelectHome: () => _navigateTo(1),
      onSelectProfile: () => _navigateTo(9),
      onSelectOrders: () => _navigateTo(8),
      onSelectRecharge: () => _navigateTo(7),
      onSelectCollections: () => _navigateTo(2),
      onSelectWishlist: () => _navigateTo(6),
      onSelectCart: () => _navigateTo(4),
      onSignOut: _handleSignOut,
    );
  }

  void _handleSignOut() async {
    await SecureStorageService().clearSession();
    widget.onSignOut?.call();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentScreen == 1 && _screenHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateBack();
        }
      },
      child: Scaffold(
        backgroundColor: HeritageTheme.darkBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildScreenContent(),

            // Floating Quick Switcher Pill (discreet at bottom right)
            Positioned(
              right: 12,
              bottom: 12,
              child: _buildFloatingQuickSwitcher(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenContent() {
    switch (_currentScreen) {
      case 0:
        return AthiraiSplashScreen(
          onBeginJourney: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          },
        );
      case 1:
        return AthiraiHomeScreen(
          store: store,
          onOpenCollection: () => _navigateTo(2),
          onOpenProduct: (product) => _navigateTo(3, product: product),
          onOpenBag: () => _navigateTo(4),
          onOpenWishlist: () => _navigateTo(6),
          onOpenSearch: () => _navigateTo(2),
          onOpenRecharge: () => _navigateTo(7),
          onLotusTap: () => _navigateTo(3),
          onOpenStudio: () => _navigateTo(3),
          onSignOut: _handleSignOut,
        );
      case 2:
        return AthiraiCollectionScreen(
          store: store,
          onBack: _navigateBack,
          onOpenProduct: (product) => _navigateTo(3, product: product),
          onOpenBag: () => _navigateTo(4),
          onOpenWishlist: () => _navigateTo(6),
          onBuyNow: (product) {
            AthiraiPurchaseSheet.show(
              context,
              product: product,
              store: store,
              onOrderCompleted: () => _navigateTo(8),
            );
          },
        );
      case 3:
        return AthiraiProductDetailScreen(
          store: store,
          product: _activeProduct,
          onBack: _navigateBack,
          onBuyNow: () {
            final prod = _activeProduct ?? store.products.first;
            AthiraiPurchaseSheet.show(
              context,
              product: prod,
              store: store,
              onOrderCompleted: () => _navigateTo(8),
            );
          },
          onOpenBag: () => _navigateTo(4),
          onOpenWishlist: () => _navigateTo(6),
        );
      case 4:
        return AthiraiCartScreen(
          store: store,
          onBack: _navigateBack,
          onOpenProduct: (product) => _navigateTo(3, product: product),
          onOpenWishlist: () => _navigateTo(6),
        );
      case 5:
        return AthiraiOtpVerificationScreen(
          phoneNumber: '+91 98765 43210',
          onVerified: () => _navigateTo(9),
        );
      case 6:
        return AthiraiWishlistScreen(
          store: store,
          onBack: _navigateBack,
          onOpenProduct: (product) => _navigateTo(3, product: product),
          onOpenBag: () => _navigateTo(4),
          onBuyNow: (product) {
            AthiraiPurchaseSheet.show(
              context,
              product: product,
              store: store,
              onOrderCompleted: () => _navigateTo(8),
            );
          },
          onExplore: () => _navigateTo(2),
        );
      case 7:
        return AthiraiRechargeScreen(
          store: store,
          onBack: _navigateBack,
          onBuyGoldWithCoins: () => _navigateTo(2),
        );
      case 8:
        return AthiraiOrderSummaryScreen(
          store: store,
          onBack: _navigateBack,
          onOpenMenu: _openRoyalDrawer,
          onExploreJewels: () => _navigateTo(2),
        );
      case 9:
        return AthiraiProfileDashboardScreen(
          store: store,
          onBack: _navigateBack,
          onOpenMenu: _openRoyalDrawer,
          onOpenOrders: () => _navigateTo(8),
          onOpenCollection: () => _navigateTo(2),
          onOpenRecharge: () => _navigateTo(7),
          onSignOut: _handleSignOut,
        );
      default:
        return AthiraiHomeScreen(
          store: store,
          onOpenCollection: () => _navigateTo(2),
          onOpenProduct: (product) => _navigateTo(3, product: product),
          onOpenBag: () => _navigateTo(4),
          onOpenWishlist: () => _navigateTo(6),
          onOpenSearch: () => _navigateTo(2),
          onOpenRecharge: () => _navigateTo(7),
          onLotusTap: () => _navigateTo(3),
          onOpenStudio: () => _navigateTo(3),
          onSignOut: _handleSignOut,
        );
    }
  }

  /// Floating discrete switcher pill allowing instant jumping between all screens
  Widget _buildFloatingQuickSwitcher() {
    final screenTitles = [
      '01 Onboarding',
      '02 Home',
      '03 Collections',
      '04 Product Detail',
      '05 Vault & Pay',
      'OTP Verification',
      '06 Royal Wishlist',
      '07 Recharge & AUG Coins',
      '08 Order Summary',
      '09 Profile Dashboard',
    ];


    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE6051512),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<int>(
          tooltip: 'Switch Screen',
          offset: const Offset(0, -220),
          color: const Color(0xF2071B16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HeritageTheme.goldBorder, width: 0.9),
          ),
          icon: const Icon(
            Icons.layers_outlined,
            color: HeritageTheme.goldPrimary,
            size: 19,
          ),
          onSelected: (index) {
            if (index == 99) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultAppRoot(startInClientExperience: false)),
              );
            } else {
              _navigateTo(index);
            }
          },
          itemBuilder: (context) {
            final items = List<PopupMenuEntry<int>>.generate(screenTitles.length, (i) {
              final isCurrent = i == _currentScreen;
              return PopupMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    Icon(
                      isCurrent
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isCurrent
                          ? HeritageTheme.goldBright
                          : HeritageTheme.textMutedDark,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      screenTitles[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                        color: isCurrent
                            ? HeritageTheme.goldBright
                            : HeritageTheme.textLight,
                      ),
                    ),
                  ],
                ),
              );
            });

            // Add Vault CMS Platform shortcut
            items.add(const PopupMenuDivider());
            items.add(
              const PopupMenuItem<int>(
                value: 99,
                child: Row(
                  children: [
                    Icon(Icons.dashboard_customize, color: HeritageTheme.goldBright, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Vault CMS Platform ↗',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.goldBright,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return items;
          },
        ),
      ),
    );
  }
}

