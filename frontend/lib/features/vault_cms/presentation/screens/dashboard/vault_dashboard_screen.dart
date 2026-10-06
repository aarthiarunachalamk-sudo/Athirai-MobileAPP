import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';


class VaultDashboardScreen extends StatefulWidget {
  const VaultDashboardScreen({
    super.key,
    required this.apiService,
    required this.onNavigateTo,
  });

  final VaultApiService apiService;
  final ValueChanged<int> onNavigateTo;

  @override
  State<VaultDashboardScreen> createState() => _VaultDashboardScreenState();
}

class _VaultDashboardScreenState extends State<VaultDashboardScreen> {
  VaultAnalyticsData _analytics = const VaultAnalyticsData();
  VaultMetalRates _rates = const VaultMetalRates();
  List<VaultOrder> _recentOrders = [];
  List<VaultProduct> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final a = await widget.apiService.getAnalytics();
    final r = await widget.apiService.getMetalRates();
    final o = await widget.apiService.getOrders();
    final p = await widget.apiService.getProducts();

    if (mounted) {
      setState(() {
        _analytics = a;
        _rates = r;
        _recentOrders = o.take(4).toList();
        _featuredProducts = p.take(3).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: VaultTokens.champagneGold),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Greeting Banner ───────────────────────────────────────────
          _buildHeroBanner(),
          const SizedBox(height: 24),

          // ── Live Metal Rates Bar ───────────────────────────────────────────
          _buildMetalRatesBar(),
          const SizedBox(height: 24),

          // ── KPI Metric Cards ───────────────────────────────────────────────
          _buildKpiCardsGrid(),
          const SizedBox(height: 28),

          // ── Chart & Quick Actions Row ──────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildRevenuePerformanceChart()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildQuickActionShortcuts()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildRevenuePerformanceChart(),
                  const SizedBox(height: 24),
                  _buildQuickActionShortcuts(),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Bottom Split: Recent Orders & Featured Masterpieces ────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentOrdersCard()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildTopMasterpiecesCard()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildRecentOrdersCard(),
                  const SizedBox(height: 24),
                  _buildTopMasterpiecesCard(),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      borderRadius: 20,
      gradient: const LinearGradient(
        colors: [Color(0x660B2925), Color(0x33061A14)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: VaultTokens.champagneGold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'ESTABLISHED 1924  •  ROYAL HERITAGE ATELIER',
                      style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.4),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome Back, Master Goldsmith Ananya',
                  style: VaultTokens.headlineDisplay(fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your jewellery atelier is active across 5 royal collections. All 28 pieces are synchronized with live Chennai Bullion metal rates.',
                  style: VaultTokens.bodyText(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          LuxuryGoldPillButton(
            label: '+ CREATE JEWEL',
            icon: Icons.add,
            height: 44,
            onPressed: () => widget.onNavigateTo(2), // Jump to Create Workflow
          ),
        ],
      ),
    );
  }

  Widget _buildMetalRatesBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x55061A14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.show_chart, color: VaultTokens.champagneGold, size: 18),
          const SizedBox(width: 10),
          Text(
            'LIVE BULLION RATES:',
            style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRateBadge('24K Gold (999)', '₹${_rates.gold24k}/g', const Color(0xFF66BB6A)),
                  _buildRateBadge('22K Gold (916)', '₹${_rates.gold22k}/g', VaultTokens.champagneGold),
                  _buildRateBadge('18K Gold (750)', '₹${_rates.gold18k}/g', const Color(0xFFFFB74D)),
                  _buildRateBadge('Silver (999)', '₹${_rates.silver999}/g', const Color(0xFF80DEEA)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => widget.onNavigateTo(10), // Jump to settings
            child: Text(
              'Override Rates ↗',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: VaultTokens.champagneGold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateBadge(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.sageMuted)),
          Text(value, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildKpiCardsGrid() {
    final kpis = [
      {
        'title': 'TOTAL VAULT REVENUE',
        'value': _analytics.totalRevenueFormatted,
        'subtitle': '+18.4% vs last lunar cycle',
        'icon': Icons.account_balance_outlined,
        'badgeColor': const Color(0xFF66BB6A),
      },
      {
        'title': 'CATALOG MASTERPIECES',
        'value': '${_analytics.totalProducts} Pieces',
        'subtitle': '${_analytics.publishedProducts} Live • ${_analytics.draftProducts} In Atelier',
        'icon': Icons.diamond_outlined,
        'badgeColor': VaultTokens.champagneGold,
      },
      {
        'title': 'BESPOKE COMMISSIONS',
        'value': '${_analytics.totalOrders} Orders',
        'subtitle': 'Avg Value ${_analytics.averageOrderValue}',
        'icon': Icons.shopping_bag_outlined,
        'badgeColor': const Color(0xFF80DEEA),
      },
      {
        'title': 'VIP ROYAL PATRONS',
        'value': '${_analytics.totalCustomers}',
        'subtitle': '4.8% Bespoke conversion',
        'icon': Icons.military_tech_outlined,
        'badgeColor': const Color(0xFFFFB74D),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 650 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.85,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) {
            final item = kpis[index];
            return LuxuryGlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 16,
              enableHoverEffect: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'] as String,
                        style: VaultTokens.brandLabel(fontSize: 10, letterSpacing: 1.2),
                      ),
                      Icon(item['icon'] as IconData, size: 20, color: item['badgeColor'] as Color),
                    ],
                  ),
                  Text(
                    item['value'] as String,
                    style: VaultTokens.headlineDisplay(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    item['subtitle'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: VaultTokens.sageMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRevenuePerformanceChart() {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REVENUE & COMMISSIONS TREND',
                    style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lunar Cycles 2026',
                    style: VaultTokens.titleSerif(fontSize: 18),
                  ),
                ],
              ),
              LuxuryStatusBadge(status: 'Bullion Dynamic'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _LuxuryChartPainter(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'].map((m) {
              return Text(
                m,
                style: GoogleFonts.inter(fontSize: 11.5, color: VaultTokens.sageMuted),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionShortcuts() {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK VAULT ACTIONS',
            style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          _buildActionRow(
            icon: Icons.add_circle_outline,
            title: 'Design New Jewel Piece',
            subtitle: 'Start 9-step craftsmanship workflow',
            onTap: () => widget.onNavigateTo(2),
          ),
          const Divider(color: VaultTokens.borderGoldMuted, height: 20),
          _buildActionRow(
            icon: Icons.all_inclusive,
            title: 'Orbital Jewel Vault',
            subtitle: 'Open 3D constellation experience',
            onTap: () => widget.onNavigateTo(8),
          ),
          const Divider(color: VaultTokens.borderGoldMuted, height: 20),
          _buildActionRow(
            icon: Icons.tune,
            title: 'Recalculate Gold Rates',
            subtitle: 'Update per-gram prices across catalog',
            onTap: () => widget.onNavigateTo(10),
          ),
          const Divider(color: VaultTokens.borderGoldMuted, height: 20),
          _buildActionRow(
            icon: Icons.view_comfy_alt_outlined,
            title: 'Browse All Masterpieces',
            subtitle: 'Grid & Table catalog management',
            onTap: () => widget.onNavigateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x400C2C24),
                shape: BoxShape.circle,
                border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
              ),
              child: Icon(icon, size: 18, color: VaultTokens.champagneGold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: VaultTokens.warmIvory,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: VaultTokens.sageMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: VaultTokens.mutedGold),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT BESPOKE COMMISSIONS',
                style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5),
              ),
              InkWell(
                onTap: () => widget.onNavigateTo(6), // Orders screen
                child: Text(
                  'View All ↗',
                  style: GoogleFonts.inter(fontSize: 11.5, color: VaultTokens.champagneGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentOrders.map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x33061A14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VaultTokens.borderGoldMuted, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: VaultTokens.goldGradient,
                    ),
                    child: Center(
                      child: Text(
                        order.customerName.isNotEmpty ? order.customerName[0] : 'P',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF161108)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory),
                        ),
                        Text(
                          '${order.orderId} • ${order.productName}',
                          style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.sageMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.totalAmount ~/ 1000}k',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold),
                      ),
                      const SizedBox(height: 3),
                      LuxuryStatusBadge(status: order.status),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopMasterpiecesCard() {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FEATURED MASTERPIECES',
                style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5),
              ),
              InkWell(
                onTap: () => widget.onNavigateTo(1), // Catalog
                child: Text(
                  'Explore All ↗',
                  style: GoogleFonts.inter(fontSize: 11.5, color: VaultTokens.champagneGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._featuredProducts.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x33061A14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VaultTokens.borderGoldMuted, width: 0.8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      p.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFF0C2B23),
                        child: const Icon(Icons.diamond, color: VaultTokens.antiqueGold, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory),
                        ),
                        Text(
                          '${p.metal} ${p.purity} • ${p.weightGrams}g',
                          style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.sageMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(p.calculatedTotalPrice / 100000).toStringAsFixed(2)} L',
                        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${p.stockQuantity} in Vault',
                        style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.sageLight),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LuxuryChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [28.0, 32.5, 30.0, 37.0, 39.5, 42.8];
    const minVal = 25.0;
    const maxVal = 45.0;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final norm = (values[i] - minVal) / (maxVal - minVal);
      final y = size.height - (norm * (size.height - 30)) - 10;
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          VaultTokens.champagneGold.withOpacity(0.25),
          VaultTokens.antiqueGold.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Glowing line
    final linePaint = Paint()
      ..color = VaultTokens.champagneGold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Points
    for (final pt in points) {
      final dotPaint = Paint()..color = VaultTokens.champagneGold;
      canvas.drawCircle(pt, 4.0, dotPaint);

      final outerPaint = Paint()
        ..color = VaultTokens.antiqueGold.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(pt, 7.0, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
