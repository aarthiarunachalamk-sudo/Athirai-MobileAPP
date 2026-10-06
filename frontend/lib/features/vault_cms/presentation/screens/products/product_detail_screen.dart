import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';


class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onBack,
    required this.onEdit,
    required this.onAcquireOrder,
  });

  final VaultProduct product;
  final VoidCallback onBack;
  final ValueChanged<VaultProduct> onEdit;
  final ValueChanged<VaultProduct> onAcquireOrder;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Specifications, 2: Price Breakdown, 3: Craftsmanship Journey
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = [p.imageUrl, p.lifestyleImageUrl, 'assets/images/athirai_hero_sphere_necklace.jpg'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Navigation Bar ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: VaultTokens.champagneGold, size: 18),
                label: Text(
                  'Back to Collection Explorer',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.champagneGold),
                ),
              ),
              Row(
                children: [
                  LuxuryCapsuleButton(
                    label: 'Edit Specifications',
                    icon: Icons.edit_outlined,
                    onPressed: () => widget.onEdit(p),
                  ),
                  const SizedBox(width: 14),
                  LuxuryGoldPillButton(
                    label: 'COMMISSION PIECE',
                    icon: Icons.check_circle_outline,
                    onPressed: () => widget.onAcquireOrder(p),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Masterpiece Showcase Layout ────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 950;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Pedestal Gallery
                    Expanded(flex: 5, child: _buildPedestalGallery(images)),
                    const SizedBox(width: 32),
                    // Right Column: Details & Tabbed Specs
                    Expanded(flex: 6, child: _buildDetailsColumn(p)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildPedestalGallery(images),
                  const SizedBox(height: 28),
                  _buildDetailsColumn(p),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPedestalGallery(List<String> images) {
    return Column(
      children: [
        // Main Pedestal Card
        LuxuryGlassCard(
          padding: const EdgeInsets.all(0),
          borderRadius: 24,
          borderColor: VaultTokens.borderGoldBright.withOpacity(0.5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 420,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const RadialGradient(
                    center: Alignment(0, 0.2),
                    radius: 0.85,
                    colors: [
                      Color(0x660B2925),
                      Color(0xFF04100D),
                    ],
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      images[_selectedImageIndex],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.diamond,
                        size: 90,
                        color: VaultTokens.antiqueGold,
                      ),
                    ),
                  ),
                ),
              ),

              // Badges Overlay
              Positioned(
                top: 16,
                left: 16,
                child: LuxuryStatusBadge(status: widget.product.status),
              ),
              Positioned(
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VaultTokens.borderGoldMuted),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, size: 14, color: VaultTokens.champagneGold),
                      const SizedBox(width: 6),
                      Text(
                        '100% BIS 916 & IGI CERTIFIED',
                        style: VaultTokens.brandLabel(fontSize: 10, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Thumbnails Strip
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (idx) {
            final isSel = idx == _selectedImageIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedImageIndex = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted,
                    width: isSel ? 1.6 : 1,
                  ),
                  color: const Color(0xFF061A14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    images[idx],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.diamond, size: 24, color: VaultTokens.mutedGold),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailsColumn(VaultProduct p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${p.collection.toUpperCase()} COLLECTION',
              style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 2.2),
            ),
            Text(
              'SKU: ${p.sku}',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: VaultTokens.sageLight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          p.name,
          style: VaultTokens.headlineDisplay(fontSize: 32),
        ),
        const SizedBox(height: 10),
        Text(
          p.shortDescription,
          style: VaultTokens.bodyText(fontSize: 14),
        ),
        const SizedBox(height: 18),

        // Price & Stock Tag Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0x400A2520),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VaultTokens.borderGoldMuted),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DYNAMIC ESTIMATED PRICE', style: VaultTokens.brandLabel(fontSize: 9.5)),
                  const SizedBox(height: 2),
                  Text(
                    '₹${(p.calculatedTotalPrice / 100000).toStringAsFixed(2)} Lakhs',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: VaultTokens.champagneGold,
                    ),
                  ),
                  Text(
                    'Dynamic live bullion price (₹${p.calculatedTotalPrice})',
                    style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.sageMuted),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x332E7D5C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x662E7D5C)),
                    ),
                    child: Text(
                      '${p.stockQuantity} in Vault',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF66BB6A)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.warehouse,
                    style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.sageLight),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tab Selector Row
        Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0x40061A14),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: VaultTokens.borderGoldMuted),
          ),
          child: Row(
            children: [
              _buildTabButton(0, 'Overview'),
              _buildTabButton(1, 'Specifications'),
              _buildTabButton(2, 'Price Engine'),
              _buildTabButton(3, 'Craftsmanship'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tab Content
        _buildActiveTabContent(p),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSel = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            gradient: isSel ? VaultTokens.goldGradient : null,
            borderRadius: BorderRadius.circular(17),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              color: isSel ? const Color(0xFF161108) : VaultTokens.sageLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(VaultProduct p) {
    switch (_selectedTab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historical & Architectural Inspiration:', style: VaultTokens.brandLabel(fontSize: 10.5)),
            const SizedBox(height: 8),
            Text(p.description, style: VaultTokens.bodyText(fontSize: 13.5)),
            const SizedBox(height: 18),
            Text('Gemstone Curation:', style: VaultTokens.brandLabel(fontSize: 10.5)),
            const SizedBox(height: 8),
            Text('${p.gemstones} (${p.gemstoneWeight}) set with ${p.diamondCarat}. Hand-selected for exceptional clarity and royal symmetry.', style: VaultTokens.bodyText(fontSize: 13)),
          ],
        );
      case 1:
        return Column(
          children: [
            _buildSpecRow('Metal Type & Purity', '${p.metal} ${p.purity} Gold'),
            _buildSpecRow('Gross Gold Weight', '${p.weightGrams} Grams'),
            _buildSpecRow('Gemstone Selection', p.gemstones),
            _buildSpecRow('Gemstone Carat Weight', p.gemstoneWeight),
            _buildSpecRow('Diamonds / Polki', p.diamondCarat),
            _buildSpecRow('Hallmark Standard', p.hallmark),
            _buildSpecRow('Gemological Certification', p.certification),
            _buildSpecRow('Atelier Provenance', p.origin),
            _buildSpecRow('Master Artisan', p.designer),
            _buildSpecRow('Crafting Time', p.craftingTime),
          ],
        );
      case 2:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x33061A14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VaultTokens.borderGoldMuted),
          ),
          child: Column(
            children: [
              _buildSpecRow('Precious Metal Base Cost', '₹${p.calculatedMetalCost}'),
              _buildSpecRow('Master Goldsmith Making Charges (${p.makingChargePercent}%)', '₹${p.calculatedMakingCharges}'),
              _buildSpecRow('Certified Natural Gemstones Value', '₹${p.stonePrice}'),
              _buildSpecRow('Goods & Services Tax (GST 3%)', '₹${p.calculatedGst}'),
              const Divider(color: VaultTokens.borderGoldMuted, height: 18),
              _buildSpecRow('Total Transparent Value', '₹${p.calculatedTotalPrice}', isBold: true),
            ],
          ),
        );
      case 3:
        return Column(
          children: [
            _buildTimelineNode('01. Sacred Design Sketch', 'Formulated following ancient Thanjavur temple iconography and silpa sastra proportions.', true),
            _buildTimelineNode('02. Hand-Carved Wax & Nakshi Relievo', 'Master goldsmith chisels deity motifs and openable lotus mechanics in 22K gold.', true),
            _buildTimelineNode('03. Jadau Gemstone Setting', 'Burmese rubies and uncut Polki diamonds set in pure 24K gold foil bezels.', true),
            _buildTimelineNode('04. BIS 916 & IGI Laser Hallmarking', 'Tested by national assay labs for purity and diamond grade authenticity.', true),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSpecRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.sageMuted)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? VaultTokens.champagneGold : VaultTokens.warmIvory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String title, String desc, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: VaultTokens.goldGradient,
            ),
            child: const Icon(Icons.check, size: 12, color: Color(0xFF161108)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
                const SizedBox(height: 2),
                Text(desc, style: VaultTokens.bodyText(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
