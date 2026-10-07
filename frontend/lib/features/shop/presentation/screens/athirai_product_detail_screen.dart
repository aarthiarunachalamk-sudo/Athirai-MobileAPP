import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_jewel_studio_screen.dart';

/// Interactive modes for the hero product showcase
enum ShowcaseMode {
  zoomLoupe,
  turntable360,
}

/// Screen 04: Product Detail ("Crafted in Every Detail")
/// Exact match for Mockup Screen 04:
/// - `< Product Detail`, Share icon, "3D" badge
/// - Hero Showcase: Temple Blossom Necklace with Zoom Loupe Lens and 360° Turntable Orbit
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
    this.onOpenWishlist,
  });

  final ShopStore store;
  final ShopProduct? product;
  final VoidCallback onBack;
  final VoidCallback onBuyNow;
  final VoidCallback onOpenBag;
  final VoidCallback? onOpenWishlist;

  @override
  State<AthiraiProductDetailScreen> createState() =>
      _AthiraiProductDetailScreenState();
}

class _AthiraiProductDetailScreenState
    extends State<AthiraiProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _activeActionIndex = 0; // 0: 360 View, 1: AR Try-on, 2: View on Avatar

  // Showcase Modes & Zoom Loupe
  ShowcaseMode _showcaseMode = ShowcaseMode.zoomLoupe;
  Offset _loupeFocalPoint = const Offset(0.50, 0.44); // Center of the necklace centerpiece
  double _zoomScale = 2.8; // 2.0x, 2.8x, 3.5x
  bool _isLoupeVisible = true;

  // 360° Turntable Mode
  double _turntableAngle = 0.0;
  bool _isAutoSpinning = false;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        if (_isAutoSpinning && mounted) {
          setState(() {
            _turntableAngle = (_spinController.value * 360.0) % 360.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _toggleAutoSpin() {
    setState(() {
      _isAutoSpinning = !_isAutoSpinning;
      if (_isAutoSpinning) {
        _spinController.repeat();
      } else {
        _spinController.stop();
      }
    });
  }

  void _updateFocalPoint(Offset localPos, double w, double h) {
    setState(() {
      _loupeFocalPoint = Offset(
        (localPos.dx / w).clamp(0.05, 0.95),
        (localPos.dy / h).clamp(0.05, 0.95),
      );
      _isLoupeVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product?.item.name.isNotEmpty == true &&
            !widget.product!.item.name.contains('Cosmic')
        ? widget.product!.item.name
        : 'Temple Blossom Necklace';
    final collection = widget.product?.collection ?? 'Heritage Collection';
    final priceText = widget.product != null ? rupees(widget.product!.price) : '₹ 3,65,000';
    final specsText = widget.product != null
        ? '${widget.product!.purity} ${widget.product!.metal} • ${widget.product!.weightGrams}g'
        : '22K Gold • Emerald • Pearls';

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

  /// Top App Bar with back, wishlist counter, cart counter, and 3D badge
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
                'Product Detail',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: HeritageTheme.textLight,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              // Wishlist shortcut icon button with badge
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
              // Cart shortcut icon button with badge
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
              // "3D" pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                margin: const EdgeInsets.only(right: 6),
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
      },
    );
  }

  /// Product image renderer with high filter quality and robust fallback
  Widget _buildProductImage({
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final img = widget.product?.image;
    if (img != null && img.isNotEmpty) {
      if (img.startsWith('http')) {
        return Image.network(
          img,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => Image.asset(
            AppAssets.pedestalNecklace,
            width: width,
            height: height,
            fit: fit,
            filterQuality: FilterQuality.high,
          ),
        );
      } else {
        return Image.asset(
          img,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => Image.asset(
            AppAssets.pedestalNecklace,
            width: width,
            height: height,
            fit: fit,
            filterQuality: FilterQuality.high,
          ),
        );
      }
    }
    return Image.asset(
      AppAssets.pedestalNecklace,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }

  /// Mode switcher pill tab (Zoom Loupe vs 360° View)
  Widget _buildModeTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x44D4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFDF7A), width: 0.8)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? const Color(0xFFFFDF7A) : HeritageTheme.textMutedDark,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFFDF7A) : HeritageTheme.textMutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fullscreen Macro Inspection Dialog with Pinch & Zoom up to 6.0x
  void _openFullscreenMacroModal(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (modalCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Interactive Pinch & Zoom Viewer
            Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 6.0,
                boundaryMargin: const EdgeInsets.all(60),
                child: _buildProductImage(fit: BoxFit.contain),
              ),
            ),

            // Top Bar with Hallmark Info & Close
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xCC061814),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: Color(0xFFFFDF7A), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '22K 916 BIS Hallmarked • Macro HD',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFDF7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(modalCtx).pop(),
                  ),
                ],
              ),
            ),

            // Bottom Zoom Instructions
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xCC061814),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x44D4AF37)),
                  ),
                  child: Text(
                    'Pinch to zoom up to 6.0x • Drag to explore craftsmanship',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFFD1DFDE),
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

  /// Hero Showcase with interactive Zoom Loupe lens and 360° velvet pedestal display
  Widget _buildHeroPedestal() {
    const double containerH = 320.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerW = constraints.maxWidth;
        const double loupeDiameter = 138.0;
        const double loupeRadius = loupeDiameter / 2.0;

        // Pixel coordinates of user focal point
        final focalX = (_loupeFocalPoint.dx * containerW).clamp(0.0, containerW);
        final focalY = (_loupeFocalPoint.dy * containerH).clamp(0.0, containerH);

        // Clamped loupe center position to keep entire magnifying lens on-screen
        final loupeCenterX = focalX.clamp(loupeRadius, containerW - loupeRadius);
        final loupeCenterY = focalY.clamp(loupeRadius, containerH - loupeRadius);

        // Offset of the magnified canvas inside the loupe
        final loupeOffsetX = loupeRadius - (focalX * _zoomScale);
        final loupeOffsetY = loupeRadius - (focalY * _zoomScale);

        return Container(
          height: containerH,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _showcaseMode == ShowcaseMode.zoomLoupe
                  ? const Color(0xFFD4AF37)
                  : HeritageTheme.goldBorderSubtle,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: HeritageTheme.emeraldGlow,
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Base Showcase View (Zoom Loupe or 360 Turntable)
                if (_showcaseMode == ShowcaseMode.zoomLoupe) ...[
                  // Base product image
                  _buildProductImage(
                    width: containerW,
                    height: containerH,
                    fit: BoxFit.cover,
                  ),

                  // Bottom subtle gradient shade
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.70, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.70),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Interactive Touch/Drag Surface for Zoom Loupe
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (d) => _updateFocalPoint(d.localPosition, containerW, containerH),
                      onPanUpdate: (d) => _updateFocalPoint(d.localPosition, containerW, containerH),
                      onTapDown: (d) => _updateFocalPoint(d.localPosition, containerW, containerH),
                      onDoubleTap: () => _openFullscreenMacroModal(context),
                    ),
                  ),

                  // The Circular Magnifying Loupe Lens (Matching Reference Image)
                  if (_isLoupeVisible)
                    Positioned(
                      left: loupeCenterX - loupeRadius,
                      top: loupeCenterY - loupeRadius,
                      width: loupeDiameter,
                      height: loupeDiameter,
                      child: IgnorePointer(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Magnified Image clipped into circle
                            ClipOval(
                              child: SizedBox(
                                width: loupeDiameter,
                                height: loupeDiameter,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: loupeOffsetX,
                                      top: loupeOffsetY,
                                      width: containerW * _zoomScale,
                                      height: containerH * _zoomScale,
                                      child: _buildProductImage(
                                        width: containerW * _zoomScale,
                                        height: containerH * _zoomScale,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Glass lens optical specular gleam
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.25),
                                              Colors.white.withOpacity(0.04),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.40, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Reticle micro-focus center target
                                    Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFFFDF7A).withOpacity(0.75),
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Metallic White/Gold Ring Frame (Matching User Reference)
                            Container(
                              width: loupeDiameter,
                              height: loupeDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.55),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.65),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),

                            // Micro Tag attached to the loupe
                            Positioned(
                              bottom: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xEE061814),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                                ),
                                child: Text(
                                  '${_zoomScale.toStringAsFixed(1)}x Macro',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFFDF7A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Bottom Drag Hint / Instruction
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xD9061814),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, color: Color(0xFFFFDF7A), size: 13),
                          const SizedBox(width: 5),
                          Text(
                            'Drag lens to zoom jewellery details',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: HeritageTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // 2. 360° Turntable Mode with Horizontal Drag
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        _isAutoSpinning = false;
                        _turntableAngle = (_turntableAngle - d.primaryDelta! * 0.85) % 360.0;
                        if (_turntableAngle < 0) _turntableAngle += 360.0;
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Pedestal 3D Matrix Perspective Transformation
                        Center(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateY(_turntableAngle * (math.pi / 180.0)),
                            alignment: Alignment.center,
                            child: _buildProductImage(
                              width: containerW,
                              height: containerH,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Moving Specular Studio Light Sheen that tracks the angle
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(math.sin(_turntableAngle * (math.pi / 180.0)), -1.0),
                                  end: Alignment(-math.sin(_turntableAngle * (math.pi / 180.0)), 1.0),
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFFFFDF7A).withOpacity(0.20),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.35, 0.50, 0.65],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom 360° Turntable Orbit Ring & Angle HUD
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xD9061814),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFD4AF37), width: 0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: HeritageTheme.goldPrimary.withOpacity(0.3),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: _toggleAutoSpin,
                                    child: Icon(
                                      _isAutoSpinning
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_fill_rounded,
                                      color: const Color(0xFFFFDF7A),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '360° Turntable • ${_turntableAngle.round()}°',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFFDF7A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(Drag to rotate)',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: HeritageTheme.textMutedDark,
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
                ],

                // Top Left: Zoom Level Selector Chips (when in Zoom Loupe mode)
                if (_showcaseMode == ShowcaseMode.zoomLoupe)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xD9061814),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [2.0, 2.8, 3.5].map((scale) {
                          final isSelected = _zoomScale == scale;
                          return InkWell(
                            onTap: () => setState(() => _zoomScale = scale),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0x55D4AF37) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: const Color(0xFFFFDF7A), width: 0.8)
                                    : null,
                              ),
                              child: Text(
                                '${scale}x',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFFFFDF7A) : HeritageTheme.textMutedDark,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                // Top Right: Mode Switcher Capsule (Zoom Loupe, 360° View, Fullscreen)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xEE061814),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom Loupe Tab
                        _buildModeTab(
                          icon: Icons.search_rounded,
                          label: 'Zoom Loupe',
                          isSelected: _showcaseMode == ShowcaseMode.zoomLoupe,
                          onTap: () {
                            setState(() {
                              _showcaseMode = ShowcaseMode.zoomLoupe;
                              _isLoupeVisible = true;
                              _isAutoSpinning = false;
                            });
                          },
                        ),
                        const SizedBox(width: 3),
                        // 360° Turntable Tab
                        _buildModeTab(
                          icon: Icons.rotate_right_rounded,
                          label: '360° Orbit',
                          isSelected: _showcaseMode == ShowcaseMode.turntable360,
                          onTap: () {
                            setState(() {
                              _showcaseMode = ShowcaseMode.turntable360;
                              _isAutoSpinning = true;
                              _spinController.repeat();
                            });
                          },
                        ),
                        const SizedBox(width: 3),
                        // Fullscreen Macro Action
                        InkWell(
                          onTap: () => _openFullscreenMacroModal(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0x33D4AF37),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Color(0xFFFFDF7A),
                              size: 16,
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
              if (index == 0) {
                setState(() {
                  _showcaseMode = ShowcaseMode.turntable360;
                  _isAutoSpinning = true;
                  _spinController.repeat();
                });
              } else if (index > 0) {
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
    final p = widget.product;
    final materials = [
      {
        'name': p != null ? p.metal : 'Gold',
        'sub': p != null ? p.purity : '22K',
        'icon': Icons.monetization_on_outlined,
      },
      {
        'name': 'Weight',
        'sub': p != null ? '${p.weightGrams}g' : '44.20g',
        'icon': Icons.scale_outlined,
      },
      {
        'name': 'Making',
        'sub': p != null ? '${p.makingChargePercent}%' : '12%',
        'icon': Icons.handyman_outlined,
      },
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

  /// Bottom Action Bar: Wishlist Toggle + "Add to Cart" + "Buy Now"
  Widget _buildBottomActionBar() {
    final productId = widget.product?.id ?? 'rg-1';
    final productName = widget.product?.name ?? 'Temple Blossom Necklace';

    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final isWishlisted = widget.store.isSaved(productId);
        final inCartQty = widget.store.quantity(productId);

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
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
              // 1. Wishlist Heart Toggle Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isWishlisted
                      ? HeritageTheme.goldPrimary.withOpacity(0.2)
                      : const Color(0xCC071B16),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isWishlisted
                        ? HeritageTheme.goldBright
                        : HeritageTheme.goldBorder,
                    width: 1.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      widget.store.toggleWishlist(productId);
                      final nowWishlisted = widget.store.isSaved(productId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nowWishlisted
                                ? 'Added "$productName" to Wishlist'
                                : 'Removed from Wishlist',
                          ),
                          duration: const Duration(seconds: 1),
                          action: nowWishlisted && widget.onOpenWishlist != null
                              ? SnackBarAction(
                                  label: 'VIEW',
                                  textColor: HeritageTheme.goldBright,
                                  onPressed: widget.onOpenWishlist!,
                                )
                              : null,
                        ),
                      );
                    },
                    child: Center(
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isWishlisted
                            ? HeritageTheme.goldBright
                            : HeritageTheme.textLight,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 2. "Add to Cart" Capsule Button
              Expanded(
                flex: 5,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: inCartQty > 0
                        ? const Color(0xE60A2B23)
                        : const Color(0xCC071B16),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: inCartQty > 0
                          ? HeritageTheme.goldBright
                          : HeritageTheme.goldBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        widget.store.addToCart(productId, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added to Cart (Qty: ${widget.store.quantity(productId)})',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            inCartQty > 0
                                ? Icons.check_circle_rounded
                                : Icons.shopping_bag_outlined,
                            color: inCartQty > 0
                                ? HeritageTheme.goldBright
                                : HeritageTheme.goldPrimary,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            inCartQty > 0
                                ? 'In Cart ($inCartQty)'
                                : 'Add to Cart',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: inCartQty > 0
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

              const SizedBox(width: 8),

              // 3. "Buy Now" Gold Gradient Button
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
                        widget.store.addToCart(productId, 1);
                        widget.onBuyNow();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.flash_on_rounded,
                            color: Color(0xFF1A1203),
                            size: 17,
                          ),
                          const SizedBox(width: 4),
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
      },
    );
  }
}
