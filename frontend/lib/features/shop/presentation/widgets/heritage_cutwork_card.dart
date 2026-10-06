import 'package:flutter/material.dart';
import '../theme/heritage_theme.dart';

/// Luxury Jewellery Product Card featuring:
/// - Ornate Indian Jali (Lattice / Cut-work) filigree border
/// - Micro-animations on card touch: spring scale compression + gold shimmer sweep
/// - Enhanced badges: 22K BIS 916 Hallmark, Live Net Weight, Making charge indicator
/// - Animated Wishlist heart burst
class HeritageCutworkCard extends StatefulWidget {
  const HeritageCutworkCard({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    this.tag = '22K • Signature',
    this.netWeight = '42.50 gm',
    this.liveRate = '₹7,450 / g',
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistTap,
    this.onAddTap,
    this.cardWidth = 168,
  });

  final String name;
  final String price;
  final String image;
  final String tag;
  final String netWeight;
  final String liveRate;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddTap;
  final double cardWidth;

  @override
  State<HeritageCutworkCard> createState() => _HeritageCutworkCardState();
}

class _HeritageCutworkCardState extends State<HeritageCutworkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shimmerAnimation;
  bool _isPressed = false;
  late bool _wishlisted;

  @override
  void initState() {
    super.initState();
    _wishlisted = widget.isWishlisted;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.2, end: 1.5).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutQuad,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HeritageCutworkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWishlisted != widget.isWishlisted) {
      setState(() => _wishlisted = widget.isWishlisted);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _animController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _animController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: widget.cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isPressed
                  ? HeritageTheme.gold.withValues(alpha: 0.8)
                  : const Color(0xFFEADBCE),
              width: _isPressed ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? HeritageTheme.maroon.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.07),
                blurRadius: _isPressed ? 18 : 10,
                offset: Offset(0, _isPressed ? 8 : 4),
              ),
              if (!_isPressed)
                BoxShadow(
                  color: HeritageTheme.gold.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Cut-work Header & Showcase Image
                    _buildImageSection(),

                    // Product Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag & Hallmark
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF4EB),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE8D7C4), width: 0.8),
                                  ),
                                  child: Text(
                                    widget.tag,
                                    style: HeritageTheme.sans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: HeritageTheme.maroon,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.netWeight,
                                  style: HeritageTheme.sans(
                                    fontSize: 9.5,
                                    color: const Color(0xFF7A6E63),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Product Name
                          Text(
                            widget.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HeritageTheme.serif(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: HeritageTheme.ebony,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Price & Add Button Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.price,
                                        style: HeritageTheme.sans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: HeritageTheme.maroon,
                                        ),
                                      ),
                                      Text(
                                        widget.liveRate,
                                        style: HeritageTheme.sans(
                                          fontSize: 8.5,
                                          color: HeritageTheme.muted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),

                              // Quick Add Circular Button
                              InkWell(
                                onTap: widget.onAddTap ?? widget.onTap,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFAF6F0),
                                    border: Border.all(
                                      color: HeritageTheme.gold.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    size: 15,
                                    color: HeritageTheme.maroon,
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

                // Touch Shimmer Light Sweep Effect
                if (_animController.isAnimating || _isPressed)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _CardShimmerSweepPainter(_shimmerAnimation.value),
                          );
                        },
                      ),
                    ),
                  ),

                // Top Cut-work Filigree Overlay (Indian Palace Jali pattern)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 18,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: JaliCutworkBorderPainter(
                        color: HeritageTheme.goldAntique.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      // Keep a consistent, near-square product stage in the two-column grid.
      height: 168,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDFC),
        border: Border(bottom: BorderSide(color: Color(0xFFEFE6D9), width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Auto-crop: fills entire tile regardless of source image dimensions.
          // ClipRRect ensures rounded corners are respected on the fill.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: _isPressed
                  ? _buildImage(BoxFit.cover)
                  : _buildImage(BoxFit.cover),
            ),
          ),

          // Frosted-glass gradient vignette at bottom for text separation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 52,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFFFFFDFC).withValues(alpha: 0.92),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Wishlist Floating Button with Micro-Animation
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() => _wishlisted = !_wishlisted);
                widget.onWishlistTap?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  _wishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 15,
                  color: _wishlisted ? HeritageTheme.maroon : const Color(0xFF7A6E63),
                ),
              ),
            ),
          ),

          // 3D/Interactive View Cue
          Positioned(
            bottom: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xD9073B3F), // Infisq Emerald Teal
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_in_ar_rounded, size: 10, color: Color(0xFFCCA881)),
                  SizedBox(width: 3),
                  Text(
                    '3D View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BoxFit fit) {
    return Image.asset(
      widget.image,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.diamond_outlined,
              size: 44,
              color: HeritageTheme.gold.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 6),
            Text(
              'Image Preview',
              style: HeritageTheme.sans(
                fontSize: 9,
                color: HeritageTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ornate Indian Jali (Lattice) Cut-work Border Painter
class JaliCutworkBorderPainter extends CustomPainter {
  JaliCutworkBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    const scallopWidth = 14.0;
    final count = (w / scallopWidth).floor();
    final step = w / count;

    final path = Path();
    path.moveTo(0, 0);

    for (int i = 0; i < count; i++) {
      final xStart = i * step;
      final xMid = xStart + step / 2;
      final xEnd = xStart + step;

      // Scalloped cutwork arch
      path.quadraticBezierTo(xMid, 7, xEnd, 0);

      // Delicate gold foil perforation dot
      canvas.drawCircle(Offset(xMid, 4), 1.0, dotPaint);
    }

    canvas.drawPath(path, paint);

    // Subtle baseline
    canvas.drawLine(
      const Offset(0, 0.5),
      Offset(w, 0.5),
      paint..strokeWidth = 0.6,
    );
  }

  @override
  bool shouldRepaint(covariant JaliCutworkBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Dynamic gold light reflection sweep painter
class _CardShimmerSweepPainter extends CustomPainter {
  _CardShimmerSweepPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweepWidth = size.width * 0.6;
    final startX = (size.width + sweepWidth) * progress;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        HeritageTheme.goldLight.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.28),
        HeritageTheme.goldLight.withValues(alpha: 0.18),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(startX - sweepWidth, 0, sweepWidth, size.height),
      );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _CardShimmerSweepPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
