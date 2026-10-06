import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';


class VaultAnalyticsScreen extends StatefulWidget {
  const VaultAnalyticsScreen({
    super.key,
    required this.apiService,
  });

  final VaultApiService apiService;

  @override
  State<VaultAnalyticsScreen> createState() => _VaultAnalyticsScreenState();
}

class _VaultAnalyticsScreenState extends State<VaultAnalyticsScreen> {
  VaultAnalyticsData _analytics = const VaultAnalyticsData();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final a = await widget.apiService.getAnalytics();
    if (mounted) {
      setState(() {
        _analytics = a;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: VaultTokens.champagneGold));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMMISSIONS & BULLION INTELLIGENCE', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
          const SizedBox(height: 4),
          Text('Heritage Analytics & Sales', style: VaultTokens.headlineDisplay(fontSize: 28)),
          const SizedBox(height: 4),
          Text('Detailed performance analysis across collections, precious metals, and VIP patron cohorts.', style: VaultTokens.bodyText(fontSize: 13)),
          const SizedBox(height: 28),

          // High level summary cards
          Row(
            children: [
              Expanded(
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL REVENUE (FY 2026)', style: VaultTokens.brandLabel(fontSize: 9.5)),
                      const SizedBox(height: 4),
                      Text(_analytics.totalRevenueFormatted, style: VaultTokens.headlineDisplay(fontSize: 24, color: VaultTokens.champagneGold)),
                      Text('Average Order: ${_analytics.averageOrderValue}', style: VaultTokens.bodyText(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BESPOKE CONVERSION RATE', style: VaultTokens.brandLabel(fontSize: 9.5)),
                      const SizedBox(height: 4),
                      Text(_analytics.conversionRate, style: VaultTokens.headlineDisplay(fontSize: 24, color: const Color(0xFF66BB6A))),
                      Text('From private salon viewings', style: VaultTokens.bodyText(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTIVE COMMISSIONS', style: VaultTokens.brandLabel(fontSize: 9.5)),
                      const SizedBox(height: 4),
                      Text('${_analytics.totalOrders} Orders', style: VaultTokens.headlineDisplay(fontSize: 24, color: const Color(0xFF80DEEA))),
                      Text('100% on schedule in atelier', style: VaultTokens.bodyText(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Category Revenue Split Breakdown
          LuxuryGlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CATEGORY REVENUE DISTRIBUTION', style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5)),
                const SizedBox(height: 18),
                _buildDistributionBar('Temple Necklaces & Chokers', 0.48, '₹20.5 Lakhs (48%)'),
                _buildDistributionBar('Royal Bangles & Kadas', 0.22, '₹9.4 Lakhs (22%)'),
                _buildDistributionBar('Polki Chandbalis & Earrings', 0.16, '₹6.8 Lakhs (16%)'),
                _buildDistributionBar('Blooming Lotus Cocktail Rings', 0.10, '₹4.3 Lakhs (10%)'),
                _buildDistributionBar('Bullion Gold & Silver Coins', 0.04, '₹1.8 Lakhs (4%)'),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String label, double pct, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
              Text(value, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFF071F19),
              valueColor: const AlwaysStoppedAnimation(VaultTokens.champagneGold),
            ),
          ),
        ],
      ),
    );
  }
}
