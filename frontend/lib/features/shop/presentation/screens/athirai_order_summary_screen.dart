import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../widgets/athirai_receipt_helper.dart';

/// Screen-accurate luxury Order Summary screen (Steps 10 & 11)
/// - Top-right corner ☰ menu access
/// - Real-time list of purchased jewellery with AUG Coins breakdown
/// - Bottom-right corner "Download Receipt" button on each order card
/// - Triggers official Tax Invoice & BIS Authenticity Certificate PDF
class AthiraiOrderSummaryScreen extends StatefulWidget {
  const AthiraiOrderSummaryScreen({
    super.key,
    required this.store,
    this.onBack,
    this.onOpenMenu,
    this.onExploreJewels,
  });

  final ShopStore store;
  final VoidCallback? onBack;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onExploreJewels;

  @override
  State<AthiraiOrderSummaryScreen> createState() => _AthiraiOrderSummaryScreenState();
}

class _AthiraiOrderSummaryScreenState extends State<AthiraiOrderSummaryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() => _isLoading = true);
    await widget.store.loadOrders();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.store,
                builder: (context, _) {
                  final orders = widget.store.myOrders;
                  if (_isLoading && orders.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: HeritageTheme.goldPrimary),
                    );
                  }

                  if (orders.isEmpty) {
                    return _buildEmptyOrdersState();
                  }

                  return RefreshIndicator(
                    color: HeritageTheme.goldPrimary,
                    backgroundColor: const Color(0xFF07211B),
                    onRefresh: _refreshOrders,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      children: [
                        _buildSummaryMetrics(orders),
                        const SizedBox(height: 16),
                        for (final order in orders) ...[
                          _buildOrderCard(order),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF04120E),
        border: Border(
          bottom: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: HeritageTheme.goldBright, size: 20),
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: HeritageTheme.textLight,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Your Purchased Heirlooms & Tax Receipts',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: HeritageTheme.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh Orders',
            icon: const Icon(Icons.refresh_rounded, color: HeritageTheme.goldPrimary, size: 22),
            onPressed: _refreshOrders,
          ),
          IconButton(
            tooltip: 'Main Menu (☰)',
            icon: const Icon(Icons.menu_rounded, color: HeritageTheme.goldBright, size: 24),
            onPressed: widget.onOpenMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics(List<Map<String, dynamic>> orders) {
    int totalCoins = 0;
    int totalInr = 0;
    for (final o in orders) {
      final coins = (o['coins_used'] as num?)?.toInt() ?? 0;
      final inr = (o['total_amount'] as num?)?.toInt() ?? 0;
      totalCoins += coins;
      totalInr += inr;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF061B16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _metricColumn(
              'Total Heirlooms',
              '${orders.length} Jewels',
              Icons.diamond_outlined,
            ),
          ),
          Container(height: 36, width: 1, color: HeritageTheme.goldBorderSubtle),
          Expanded(
            child: _metricColumn(
              'AUG Coins Spent',
              '🪙 ${totalCoins > 1000 ? '${(totalCoins / 1000).toStringAsFixed(1)}k' : totalCoins}',
              Icons.stars_rounded,
            ),
          ),
          Container(height: 36, width: 1, color: HeritageTheme.goldBorderSubtle),
          Expanded(
            child: _metricColumn(
              'Valuation',
              rupees(totalInr),
              Icons.currency_rupee_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: HeritageTheme.goldBright, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: HeritageTheme.textLight,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: HeritageTheme.textMutedDark,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x33D4AF37),
                border: Border.all(color: HeritageTheme.goldBorder, width: 1.2),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: HeritageTheme.goldBright,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Orders Yet',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: HeritageTheme.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have not placed any jewellery orders yet. Choose your favourite gold jewellery and purchase seamlessly using your AUG Coins.',
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: HeritageTheme.textMutedDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onExploreJewels,
              style: ElevatedButton.styleFrom(
                backgroundColor: HeritageTheme.goldPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: Text(
                'Explore Jewellery Collections',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final invoiceNumber = order['invoice_number']?.toString() ?? 'INV-ATH-${order['order_id']}';
    final productName = order['product_name']?.toString() ?? 'Handcrafted Temple Jewellery';
    final totalAmount = (order['total_amount'] as num?)?.toInt() ?? 0;
    final coinsUsed = (order['coins_used'] as num?)?.toInt() ?? (totalAmount * 100);
    final status = order['status']?.toString() ?? 'Confirmed';
    final purity = order['metal_purity']?.toString() ?? '22K Gold';
    final weight = (order['weight_grams'] as num?)?.toDouble() ?? 10.0;
    final deliveryName = order['delivery_name']?.toString() ?? 'Royal Patron';
    final deliveryAddress = order['delivery_address']?.toString() ?? 'Delivery Address Confirmed';
    final createdAt = order['created_at']?.toString() ?? DateTime.now().toIso8601String();
    final productImage = order['product_image']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF061814),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header with Invoice & Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF030D0A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceNumber,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.goldBright,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Placed: ${createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: HeritageTheme.textMutedDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x3310B981),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF030D0A),
                    child: _buildProductThumbnail(productImage, productName),
                  ),
                ),
                const SizedBox(width: 14),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.textLight,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$purity • ${weight.toStringAsFixed(2)} g • BIS Hallmark',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: HeritageTheme.textMutedDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price & Coins Breakdown
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x33D4AF37),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: HeritageTheme.goldBorder, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🪙 ', style: TextStyle(fontSize: 11)),
                                Text(
                                  '${_formatNumber(coinsUsed)} Coins',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: HeritageTheme.goldBright,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rupees(totalAmount),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: HeritageTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Delivery Snippet
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x66030D0A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x22D4AF37), width: 0.6),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: HeritageTheme.goldPrimary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliver to: $deliveryName ($deliveryAddress)',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: HeritageTheme.textMutedDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Bar: BIS Verification on Left & DOWNLOAD RECEIPT on Bottom-Right (Step 11)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF04120E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(
                top: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '100% BIS Hallmarked',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),

                // Prominent Bottom-Right "Download Receipt" Button (Step 11)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => AthiraiReceiptHelper.downloadAndPrintReceipt(context, order),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFDF7A),
                            Color(0xFFC7A45B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF030D0A), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Download Receipt',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF030D0A),
                              letterSpacing: 0.3,
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
      ),
    );
  }

  Widget _buildProductThumbnail(String imageUrl, String productName) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(productName),
      );
    } else if (imageUrl.isNotEmpty && imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(productName),
      );
    }
    return _fallbackImage(productName);
  }

  Widget _fallbackImage(String productName) {
    return Container(
      color: const Color(0xFF051D18),
      child: const Center(
        child: Icon(Icons.diamond_rounded, color: HeritageTheme.goldPrimary, size: 28),
      ),
    );
  }

  String _formatNumber(num number) {
    final str = number.toString();
    if (str.length <= 3) return str;
    return str.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
