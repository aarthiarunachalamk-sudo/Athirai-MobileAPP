import 'package:flutter/material.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_cart_screen.dart';
import 'athirai_collection_screen.dart';
import 'athirai_home_screen.dart';
import 'athirai_product_detail_screen.dart';
import 'athirai_splash_screen.dart';
import '../../../auth/presentation/screens/athirai_otp_verification_screen.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../auth/data/services/secure_storage_service.dart';

/// Master container providing exact fidelity for all Athirai Screens:
/// 01 Splash / Onboarding ("Enter the Heritage")
/// 02 Home Screen ("Discover Your Legacy")
/// 03 Collection Explorer ("Curated for Generations")
/// 04 Product Detail ("Crafted in Every Detail")
/// 05 Styling / Checkout ("Your Jewel Vault")
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
  late int _currentScreen; // 0: Splash, 1: Home, 2: Collection, 3: Product, 4: Vault/Checkout, 5: OTP
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
          onOpenWishlist: () => _navigateTo(2),
          onOpenSearch: () => _navigateTo(2),
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
        );
      case 3:
        return AthiraiProductDetailScreen(
          store: store,
          product: _activeProduct,
          onBack: _navigateBack,
          onBuyNow: () => _navigateTo(4),
          onOpenBag: () => _navigateTo(4),
        );
      case 4:
        return AthiraiCartScreen(
          store: store,
          onBack: _navigateBack,
          onOpenProduct: (product) => _navigateTo(3, product: product),
        );
      case 5:
        return AthiraiOtpVerificationScreen(
          phoneNumber: '+91 98765 43210',
          onVerified: () => _navigateTo(1),
        );
      default:
        return AthiraiHomeScreen(
          store: store,
          onOpenCollection: () => _navigateTo(2),
          onOpenProduct: (product) => _navigateTo(3, product: product),
          onOpenBag: () => _navigateTo(4),
          onOpenWishlist: () => _navigateTo(2),
          onOpenSearch: () => _navigateTo(2),
          onLotusTap: () => _navigateTo(3),
          onOpenStudio: () => _navigateTo(3),
          onSignOut: _handleSignOut,
        );
    }
  }

  /// Floating discrete switcher pill allowing instant jumping between all 6 screens
  Widget _buildFloatingQuickSwitcher() {
    final screenTitles = [
      '01 Onboarding',
      '02 Home',
      '03 Collections',
      '04 Product Detail',
      '05 Vault & Pay',
      'OTP Verification',
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
          onSelected: (index) => _navigateTo(index),
          itemBuilder: (context) => List.generate(screenTitles.length, (i) {
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
          }),
        ),
      ),
    );
  }
}
