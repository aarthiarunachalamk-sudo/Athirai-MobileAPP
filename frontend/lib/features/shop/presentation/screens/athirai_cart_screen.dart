import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';

/// Screen 05: Styling / Checkout ("Your Jewel Vault")
/// Exact match for Mockup Screen 05:
/// - `< My Jewel Vault`, Settings gear icon
/// - Interactive Styling Avatar Hub: Silhouette mannequin with orbiting jewel nodes:
///   Necklace 1, Ring 1, Bangle 1, Earrings 2, + Add More
/// - "Your Rewards" card: Gold coins, "3.00 (100gm) Coins", "View Rewards" button
/// - "Checkout" section:
///   - 4-step line: Cart, Address, Payment, Confirm
///   - Item card: Temple Blossom Necklace, Heritage Collection, qty stepper [- 1 +], ₹ 3,65,000, "Delivery by 5-7 business days"
///   - Subtotal: ₹ 3,65,000, Shipping: FREE, Total: ₹ 3,65,000
///   - "Secure Payment" lock badge
///   - "Pay Securely  →" gold gradient button
class AthiraiCartScreen extends StatefulWidget {
  const AthiraiCartScreen({
    super.key,
    required this.store,
    required this.onBack,
    required this.onOpenProduct,
  });

  final ShopStore store;
  final VoidCallback onBack;
  final ValueChanged<ShopProduct> onOpenProduct;

  @override
  State<AthiraiCartScreen> createState() => _AthiraiCartScreenState();
}

class _AthiraiCartScreenState extends State<AthiraiCartScreen> {
  int _quantity = 1;
  final int _activeCheckoutStep = 0; // 0: Cart, 1: Address, 2: Payment, 3: Confirm
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    // Default quantity
    _quantity = widget.store.count > 0 ? widget.store.count : 1;
  }

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _onPaySecurely() {
    setState(() => _isProcessingPayment = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF071C17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: HeritageTheme.goldBorder, width: 1.2),
          ),
          title: Text(
            'Order Confirmed',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: HeritageTheme.goldBright,
            ),
          ),
          content: Text(
            'Thank you, Ananya! Your Temple Blossom Necklace has been securely ordered and reserved in your vault.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: HeritageTheme.textLight,
              height: 1.45,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onBack();
                },
                child: Text(
                  'Return to Dashboard',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: HeritageTheme.goldBright,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final cartProduct = widget.store.products.firstWhere(
          (p) => p.name.contains('Temple Blossom') || p.name.contains('Temple'),
          orElse: () => widget.store.products.first,
        );
        final itemPrice = cartProduct.price;
        final total = itemPrice * _quantity;

        return Scaffold(
          backgroundColor: HeritageTheme.darkBg,
          body: Stack(
            children: [
              // Background ambient dark emerald gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
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
                    // 1. Top App Bar: < My Jewel Vault, Settings gear
                    _buildTopAppBar(context),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 2. Interactive Virtual Mannequin / Styling Orbit Hub
                            _buildMannequinStylingHub(),

                            const SizedBox(height: 18),

                            // 3. "Your Rewards" Card
                            _buildRewardsCard(),

                            const SizedBox(height: 20),

                            // 4. "Checkout" Section
                            _buildCheckoutSection(total, cartProduct),

                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  /// Top App Bar
  Widget _buildTopAppBar(BuildContext context) {
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
            'My Jewel Vault',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: HeritageTheme.textLight,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: HeritageTheme.textLight,
              size: 21,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// Interactive Virtual Mannequin / Avatar Constellation Styling Hub
  Widget _buildMannequinStylingHub() {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: const Color(0x99071B16),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: HeritageTheme.emeraldGlow,
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background celestial orbit circles
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
            ),
          ),
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: HeritageTheme.goldBorder.withOpacity(0.4), width: 0.6),
            ),
          ),

          // Central Woman Silhouette / Avatar Bust
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: HeritageTheme.goldBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: HeritageTheme.goldPrimary.withOpacity(0.2),
                  blurRadius: 16,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                AppAssets.vaultMannequin,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF071C17),
                  child: const Icon(Icons.person, color: HeritageTheme.goldPrimary, size: 48),
                ),
              ),
            ),
          ),

          // Orbit Node 1: Top - "Necklace 1"
          Positioned(
            top: 10,
            child: _buildOrbitNode(
              label: 'Necklace 1',
              image: AppAssets.shopNecklace,
            ),
          ),

          // Orbit Node 2: Left - "Ring 1"
          Positioned(
            left: 14,
            top: 75,
            child: _buildOrbitNode(
              label: 'Ring 1',
              image: AppAssets.shopRing,
            ),
          ),

          // Orbit Node 3: Right - "Earrings 2"
          Positioned(
            right: 14,
            top: 75,
            child: _buildOrbitNode(
              label: 'Earrings 2',
              image: AppAssets.shopEarrings,
            ),
          ),

          // Orbit Node 4: Bottom Left - "Bangle 1"
          Positioned(
            left: 36,
            bottom: 12,
            child: _buildOrbitNode(
              label: 'Bangle 1',
              image: AppAssets.shopBangle,
            ),
          ),

          // Orbit Node 5: Bottom Right - "+ Add More"
          Positioned(
            right: 36,
            bottom: 12,
            child: _buildAddMoreNode(),
          ),
        ],
      ),
    );
  }

  /// Orbit Jewel Badge Node
  Widget _buildOrbitNode({required String label, required String image}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC071B16),
            border: Border.all(color: HeritageTheme.goldBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: HeritageTheme.goldPrimary.withOpacity(0.18),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.diamond_outlined,
                  color: HeritageTheme.goldPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: HeritageTheme.textMutedDark,
          ),
        ),
      ],
    );
  }

  /// "+ Add More" Orbit Node
  Widget _buildAddMoreNode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC071B16),
            border: Border.all(
              color: HeritageTheme.goldBorder.withOpacity(0.8),
              width: 0.9,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: HeritageTheme.goldPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Add More',
          style: GoogleFonts.inter(
            fontSize: 9,
            color: HeritageTheme.textMutedDark,
          ),
        ),
      ],
    );
  }

  /// "Your Rewards" Card: Gold Coins, 3.00 (100gm) Coins, "View Rewards"
  Widget _buildRewardsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xCC071B16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sparkling gold coin illustration
          SizedBox(
            width: 48,
            height: 48,
            child: Image.asset(
              AppAssets.shopGoldCoins,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.monetization_on_rounded,
                color: HeritageTheme.goldBright,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Your Rewards',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: HeritageTheme.textMutedDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.info_outline_rounded,
                      color: HeritageTheme.textMutedDark,
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '3.00',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.goldBright,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(100gm) Coins',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: HeritageTheme.textMutedDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // "View Rewards" Outline Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
            ),
            child: Text(
              'View Rewards',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: HeritageTheme.goldBright,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Checkout" Section with Stepper, Item Card, Breakdown, and "Pay Securely"
  Widget _buildCheckoutSection(int total, [ShopProduct? product]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC071B16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Checkout',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: HeritageTheme.textLight,
            ),
          ),

          const SizedBox(height: 14),

          // 4-Step Progress Line: Cart -> Address -> Payment -> Confirm
          _buildCheckoutStepper(),

          const SizedBox(height: 18),

          // Cart Item Card: Temple Blossom Necklace (dynamic)
          _buildCartItemRow(product),

          const SizedBox(height: 16),

          // Price Breakdown (Subtotal, Shipping, Total)
          _buildPriceBreakdown(total),

          const SizedBox(height: 16),

          // "Secure Payment" badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: HeritageTheme.goldPrimary,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                'Secure Payment',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: HeritageTheme.goldPrimary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // "Pay Securely  →" Gold Gradient Button
          _buildPaySecurelyButton(),
        ],
      ),
    );
  }

  /// Stepper: Cart ── Address ── Payment ── Confirm
  Widget _buildCheckoutStepper() {
    final steps = ['Cart', 'Address', 'Payment', 'Confirm'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isActive = index <= _activeCheckoutStep;
        return Expanded(
          child: Row(
            children: [
              // Step Dot / Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0x33D4AF37)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? HeritageTheme.goldPrimary
                        : HeritageTheme.goldBorderSubtle,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  steps[index],
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? HeritageTheme.goldBright
                        : HeritageTheme.textMutedDark,
                  ),
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    color: isActive
                        ? HeritageTheme.goldBorder
                        : HeritageTheme.goldBorderSubtle,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// Cart Item Row: Thumbnail, Title, Subtitle, Qty [- 1 +], Price, Delivery
  Widget _buildCartItemRow([ShopProduct? product]) {
    final name = product != null
        ? (product.name.contains('Temple Blossom') ? 'Temple Blossom Necklace' : product.name)
        : 'Temple Blossom Necklace';
    final collection = product != null && product.collection.isNotEmpty
        ? '${product.collection} Collection'
        : 'Heritage Collection';
    final priceStr = product != null ? rupees(product.price) : '₹ 3,65,000';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x80040F0D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Product Thumbnail
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
                  color: const Color(0x5509201A),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    AppAssets.pedestalNecklace,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.diamond_outlined,
                      color: HeritageTheme.goldPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: HeritageTheme.textLight,
                      ),
                    ),
                    Text(
                      collection,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        color: HeritageTheme.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Quantity Stepper: [- 1 +]
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStepperBtn(Icons.remove, _decrement),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '$_quantity',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: HeritageTheme.textLight,
                            ),
                          ),
                        ),
                        _buildStepperBtn(Icons.add, _increment),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                priceStr,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HeritageTheme.goldBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Delivery text
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: HeritageTheme.goldPrimary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Delivery by 5-7 business days',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: HeritageTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
          color: const Color(0x33D4AF37),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 12,
            color: HeritageTheme.goldBright,
          ),
        ),
      ),
    );
  }

  /// Price Breakdown (Subtotal, Shipping, Total)
  Widget _buildPriceBreakdown(int total) {
    return Column(
      children: [
        _buildPriceRow('Subtotal', '₹ ${_formatCurrency(total)}'),
        const SizedBox(height: 6),
        _buildPriceRow('Shipping', 'FREE', isHighlight: true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: HeritageTheme.goldBorderSubtle, thickness: 0.8),
        ),
        _buildPriceRow('Total', '₹ ${_formatCurrency(total)}', isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isHighlight = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 13 : 11.5,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? HeritageTheme.textLight : HeritageTheme.textMutedDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 14 : 11.5,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight
                ? HeritageTheme.green
                : (isTotal ? HeritageTheme.goldBright : HeritageTheme.textLight),
          ),
        ),
      ],
    );
  }

  /// "Pay Securely  →" Gold Gradient Button
  Widget _buildPaySecurelyButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: HeritageTheme.goldGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: HeritageTheme.goldPrimary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _isProcessingPayment ? null : _onPaySecurely,
          child: Center(
            child: _isProcessingPayment
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF1E1405)),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pay Securely',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1203),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF1A1203),
                        size: 16,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final lastThree = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }
}
