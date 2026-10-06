import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_jewel_studio_screen.dart';

/// Screen 04: Product Detail ("Crafted in Every Detail")
/// Exact match for Mockup Screen 04:
/// - `< Product Detail`, Share icon, "3D" badge
/// - Hero Showcase: Temple Blossom Necklace on dark emerald velvet bust with "360°" glowing ring
/// - Title: "Temple Blossom Necklace", "Heritage Collection"
/// - "₹ 3,65,000 | 22K Gold • Emerald • Pearls"
/// - 3 Action Pills: 360° View, AR Try-on, View on Avatar
/// - "Craftsmanship Journey" 4-step timeline: Design Concept, Hand Crafting, Stone Setting, Final Polish
/// - "Material Details" 3 cards: Gold 22K, Emerald 4.32 ct, Pearl Natural
/// - Bottom bar: "Add to Vault" + "Buy Now" gold gradient button
class AthiraiProductDetailScreen extends StatefulWidget {
  const AthiraiProductDetailScreen({
    super.key,
    required this.store,
    this.product,
    required this.onBack,
    required this.onBuyNow,
    required this.onOpenBag,
  });

  final ShopStore store;
  final ShopProduct? product;
  final VoidCallback onBack;
  final VoidCallback onBuyNow;
  final VoidCallback onOpenBag;

  @override
  State<AthiraiProductDetailScreen> createState() =>
      _AthiraiProductDetailScreenState();
}

class _AthiraiProductDetailScreenState
    extends State<AthiraiProductDetailScreen> {
  int _activeActionIndex = 0; // 0: 360 View, 1: AR Try-on, 2: View on Avatar

  @override
  Widget build(BuildContext context) {
    final title = widget.product?.item.name.isNotEmpty == true &&
            !widget.product!.item.name.contains('Cosmic')
        ? widget.product!.item.name
        : 'Temple Blossom Necklace';
    const collection = 'Heritage Collection';
    const priceText = '₹ 3,65,000';
    const specsText = '22K Gold • Emerald • Pearls';

    return Scaffold(
      backgroundColor: HeritageTheme.darkBg,
      body: Stack(
        children: [
          // Background dark emerald ambient gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.1,
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
                // Top App Bar: < Product Detail, Share, 3D
                _buildTopAppBar(context),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero 360° Velvet Pedestal Display
                        _buildHeroPedestal(),

                        const SizedBox(height: 14),

                        // Title, Collection, Price & Specs
                        _buildProductHeader(title, collection, priceText, specsText),

                        const SizedBox(height: 18),

                        // 3 Action Pills: 360° View, AR Try-on, View on Avatar
                        _buildActionPills(),

                        const SizedBox(height: 22),

                        // "Craftsmanship Journey" Timeline
                        _buildCraftsmanshipJourney(),

                        const SizedBox(height: 22),

                        // "Material Details" 3 Cards
                        _buildMaterialDetails(),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar: "Add to Vault" + "Buy Now"
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
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
            'Product Detail',
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
              Icons.ios_share_rounded,
              color: HeritageTheme.textLight,
              size: 20,
            ),
            onPressed: () {},
          ),
          // "3D" pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0x33D4AF37),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
            ),
            child: Text(
              '3D',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HeritageTheme.goldBright,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Showcase with 360° velvet pedestal display
  Widget _buildHeroPedestal() {
    return Container(
      height: 290,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: HeritageTheme.emeraldGlow,
            blurRadius: 26,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Pedestal image
            Image.asset(
              AppAssets.pedestalNecklace,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF071C17),
                child: const Center(
                  child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary, size: 54),
                ),
              ),
            ),

            // Gradient at bottom of image
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.65, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // "360°" halo badge at bottom center
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xD9061814),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: HeritageTheme.goldPrimary.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.rotate_right_rounded,
                        color: HeritageTheme.goldBright,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '360°',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.goldBright,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Product Header
  Widget _buildProductHeader(
      String title, String collection, String price, String specs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: HeritageTheme.textLight,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          collection,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: HeritageTheme.textMutedDark,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HeritageTheme.goldBright,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '|',
                style: TextStyle(color: HeritageTheme.textMutedDark.withOpacity(0.6)),
              ),
            ),
            Expanded(
              child: Text(
                specs,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: HeritageTheme.textMutedDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3 Action Pill Buttons: 360° View, AR Try-on, View on Avatar
  Widget _buildActionPills() {
    final actions = [
      {'label': '360° View', 'icon': Icons.view_in_ar_rounded},
      {'label': 'AR Try-on', 'icon': Icons.camera_alt_outlined},
      {'label': 'View on Avatar', 'icon': Icons.face_retouching_natural_rounded},
    ];

    return Row(
      children: List.generate(actions.length, (index) {
        final item = actions[index];
        final isSelected = _activeActionIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _activeActionIndex = index);
              if (index > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AthiraiJewelStudioScreen(
                      store: widget.store,
                      initialProduct: widget.product,
                      initialMode: index == 1 ? 0 : 1,
                      onBack: () => Navigator.pop(context),
                      onAddToBag: () {
                        Navigator.pop(context);
                        widget.onBuyNow();
                      },
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                right: index < 2 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x33D4AF37) : const Color(0xCC071B16),
                borderRadius: BorderRadius.circular(20),
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
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected
                        ? HeritageTheme.goldBright
                        : HeritageTheme.goldPrimary,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? HeritageTheme.textLight
                          : HeritageTheme.textMutedDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Craftsmanship Journey section with 4 circular nodes
  Widget _buildCraftsmanshipJourney() {
    final steps = [
      {'title': 'Design Concept', 'icon': Icons.draw_outlined},
      {'title': 'Hand Crafting', 'icon': Icons.pan_tool_outlined},
      {'title': 'Stone Setting', 'icon': Icons.diamond_outlined},
      {'title': 'Final Polish', 'icon': Icons.auto_awesome_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Craftsmanship Journey',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: HeritageTheme.textLight,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            return Expanded(
              child: Column(
                children: [
                  // Circular Node
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xCC071B16),
                      border: Border.all(color: HeritageTheme.goldBorder, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: HeritageTheme.goldPrimary.withOpacity(0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        step['icon'] as IconData,
                        color: HeritageTheme.goldPrimary,
                        size: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step['title'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: HeritageTheme.textMutedDark,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Material Details: 3 cards (Gold 22K, Emerald 4.32 ct, Pearl Natural)
  Widget _buildMaterialDetails() {
    final materials = [
      {'name': 'Gold', 'sub': '22K', 'icon': Icons.monetization_on_outlined},
      {'name': 'Emerald', 'sub': '4.32 ct', 'icon': Icons.hexagon_outlined},
      {'name': 'Pearl', 'sub': 'Natural', 'icon': Icons.circle_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material Details',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: HeritageTheme.textLight,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: materials.map((mat) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: mat == materials.last ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xCC071B16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(
                      mat['icon'] as IconData,
                      color: HeritageTheme.goldPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mat['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: HeritageTheme.textLight,
                            ),
                          ),
                          Text(
                            mat['sub'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: HeritageTheme.textMutedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Bottom Action Bar: "Add to Vault" + "Buy Now"
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xF2040D0B),
        border: const Border(
          top: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // "Add to Vault" Button
          Expanded(
            flex: 4,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xCC071B16),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: HeritageTheme.goldBorder, width: 0.9),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    widget.store.setQuantity(widget.product?.id ?? 'rg-1', 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to your Jewel Vault'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_outline_rounded,
                        color: HeritageTheme.goldPrimary,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add to Vault',
                        style: GoogleFonts.inter(
                          fontSize: 12,
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

          const SizedBox(width: 10),

          // "Buy Now" Gold Gradient Button
          Expanded(
            flex: 5,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: HeritageTheme.goldGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: HeritageTheme.goldPrimary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    widget.store.setQuantity(widget.product?.id ?? 'rg-1', 1);
                    widget.onBuyNow();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF1A1203),
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Buy Now',
                        style: GoogleFonts.inter(
                          fontSize: 13,
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
        ],
      ),
    );
  }
}
