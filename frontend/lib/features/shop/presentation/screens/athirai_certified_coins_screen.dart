import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../widgets/athirai_purchase_sheet.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_product_detail_screen.dart';

/// Screen-accurate Certified Coin Collection Screen
/// Faithfully implementing the logic and design shown in the reference video:
/// - Header with Today's Gold Rate & Live AUG Coin Balance
/// - "CERTIFIED COIN COLLECTION" title with design count
/// - "Live backend rate" card (e.g. Rs. 275 Silver 999 per gram / Rs. 14,250 Gold 22K)
/// - Metal filter tabs: All Coins, Silver Coins, Gold Coins
/// - Horizontal "EXPLORE BY WEIGHT" carousel (Gold Coins, 250mg, 500mg, 1g, 2g, 5g, 10g, View All)
/// - "Refine Collection" filters (Metal & Purity, Weight, Price Range, Clear All Filters)
/// - 2-Column Product Grid with Purity badges, GST tags, price per gram, and Buy with AUG Coins
class AthiraiCertifiedCoinsScreen extends StatefulWidget {
  const AthiraiCertifiedCoinsScreen({
    super.key,
    required this.store,
    this.initialTab = 'Silver Coins',
    this.onBack,
    this.onOpenProduct,
    this.onOpenBag,
    this.onOpenWishlist,
    this.onOpenRecharge,
  });

  final ShopStore store;
  final String initialTab;
  final VoidCallback? onBack;
  final ValueChanged<ShopProduct>? onOpenProduct;
  final VoidCallback? onOpenBag;
  final VoidCallback? onOpenWishlist;
  final VoidCallback? onOpenRecharge;

  @override
  State<AthiraiCertifiedCoinsScreen> createState() =>
      _AthiraiCertifiedCoinsScreenState();
}

class _AthiraiCertifiedCoinsScreenState
    extends State<AthiraiCertifiedCoinsScreen> {
  late String _selectedTab;
  String? _selectedWeightFilter;
  String? _selectedPriceRange;
  String? _selectedPurityFilter;

  final List<String> _metalTabs = ['All Coins', 'Silver Coins', 'Gold Coins'];

  final List<Map<String, String>> _weightPills = [
    {'label': 'All Weights', 'weight': ''},
    {'label': '250 mg', 'weight': '0.25'},
    {'label': '500 mg', 'weight': '0.5'},
    {'label': '1 g', 'weight': '1.0'},
    {'label': '2 g', 'weight': '2.0'},
    {'label': '5 g', 'weight': '5.0'},
    {'label': '10 g', 'weight': '10.0'},
    {'label': '50 g', 'weight': '50.0'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  String _formatNumber(num n) {
    return n.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  List<ShopProduct> get _filteredCoins {
    return widget.store.products.where((p) {
      final nameLower = p.name.toLowerCase();
      final catLower = p.category.toLowerCase();
      final metalLower = p.metal.toLowerCase();

      // Must be a coin/bullion product
      final isCoin = catLower.contains('coin') ||
          nameLower.contains('coin') ||
          nameLower.contains('bar') ||
          p.collection.toLowerCase().contains('coin');

      if (!isCoin) return false;

      // Filter by Metal Tab
      if (_selectedTab == 'Silver Coins') {
        if (!metalLower.contains('silver') && !nameLower.contains('silver')) {
          return false;
        }
      } else if (_selectedTab == 'Gold Coins') {
        if (!metalLower.contains('gold') && !nameLower.contains('gold')) {
          return false;
        }
      }

      // Filter by Purity
      if (_selectedPurityFilter != null && _selectedPurityFilter!.isNotEmpty) {
        if (!p.item.purity.contains(_selectedPurityFilter!)) return false;
      }

      // Filter by Weight
      if (_selectedWeightFilter != null && _selectedWeightFilter!.isNotEmpty) {
        final targetW = double.tryParse(_selectedWeightFilter!) ?? -1;
        if (targetW > 0) {
          final diff = (p.item.weightGrams - targetW).abs();
          if (diff > 0.05 && (p.item.weightGrams * 1000 - targetW * 1000).abs() > 50) {
            return false;
          }
        }
      }

      // Filter by Price Range
      if (_selectedPriceRange != null && _selectedPriceRange!.isNotEmpty) {
        final price = p.price;
        switch (_selectedPriceRange) {
          case '0 - 1,000':
            if (price > 1000) return false;
            break;
          case '1,000 - 5,000':
            if (price < 1000 || price > 5000) return false;
            break;
          case '5,000 - 10,000':
            if (price < 5000 || price > 10000) return false;
            break;
          case '10,000 - 25,000':
            if (price < 10000 || price > 25000) return false;
            break;
          case '25,000 Above':
            if (price < 25000) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedWeightFilter = null;
      _selectedPriceRange = null;
      _selectedPurityFilter = null;
    });
  }

  void _openFilterDrawer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF061B18),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Refine Collection',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF7F2E8),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                      setSheetState(() {});
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'CLEAR ALL FILTERS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC7A45B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metal & Purity
              Text(
                'METAL & PURITY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: const Color(0xFF8E9E94),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All Coins', 'Silver Coins', 'Gold Coins'].map((metal) {
                  final isSel = _selectedTab == metal;
                  return ChoiceChip(
                    label: Text(metal),
                    selected: isSel,
                    selectedColor: const Color(0xFFC7A45B),
                    backgroundColor: const Color(0x33020907),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFF041A13) : const Color(0xFFD1DFDE),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setSheetState(() => _selectedTab = metal);
                        setState(() => _selectedTab = metal);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Price Range
              Text(
                'PRICE RANGE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: const Color(0xFF8E9E94),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '0 - 1,000',
                  '1,000 - 5,000',
                  '5,000 - 10,000',
                  '10,000 - 25,000',
                  '25,000 Above',
                ].map((range) {
                  final isSel = _selectedPriceRange == range;
                  return ChoiceChip(
                    label: Text('₹$range'),
                    selected: isSel,
                    selectedColor: const Color(0xFFC7A45B),
                    backgroundColor: const Color(0x33020907),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFF041A13) : const Color(0xFFD1DFDE),
                    ),
                    onSelected: (val) {
                      setSheetState(() => _selectedPriceRange = val ? range : null);
                      setState(() => _selectedPriceRange = val ? range : null);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7A45B),
                    foregroundColor: const Color(0xFF041A13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final coins = _filteredCoins;
        final liveSilverRate = widget.store.rates.silver999;
        final liveGoldRate = widget.store.rates.gold22k;

        return Scaffold(
          backgroundColor: HeritageTheme.darkBg,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top Header with Rates & Vault AUG Coins
                _buildTopHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Collection Header & Live Backend Rate Card
                        _buildCollectionHeaderAndRateCard(liveSilverRate, liveGoldRate, coins.length),
                        const SizedBox(height: 16),

                        // 3. Category Filter Tabs (All Coins, Silver Coins, Gold Coins)
                        _buildFilterTabs(),
                        const SizedBox(height: 16),

                        // 4. Explore by Weight Horizontal Slider
                        _buildExploreByWeight(),
                        const SizedBox(height: 16),

                        // 5. Active Filters & Refine Collection Button
                        _buildFilterBar(coins.length),
                        const SizedBox(height: 14),

                        // 6. Product Cards Grid (Matching 50gm Silver Bar, 2gm Silver Coin, etc.)
                        _buildCoinGrid(coins),
                        const SizedBox(height: 40),
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

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xCC061B18),
        border: Border(bottom: BorderSide(color: Color(0x22C7A45B), width: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFC7A45B),
              size: 18,
            ),
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),

          // Live Gold Rate Ticker in Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x26C7A45B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x4DC7A45B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded, size: 13, color: Color(0xFFFFDF7A)),
                const SizedBox(width: 5),
                Text(
                  "Today's Gold Rate 22K: Rs. ${_formatNumber(widget.store.rates.gold22k)}/-",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFDF7A),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // AUG Coin Pill
          InkWell(
            onTap: widget.onOpenRecharge,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2E28),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 0.9),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDF7A),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF041A13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AUG ${_formatNumber(widget.store.augCoins)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFDF7A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Cart Icon
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Color(0xFFC7A45B), size: 21),
                if (widget.store.count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFC92035),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.store.count}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: widget.onOpenBag,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionHeaderAndRateCard(double silverRate, int goldRate, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CERTIFIED COIN COLLECTION',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: const Color(0xFFC7A45B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedTab,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF7F2E8),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count coin designs available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFA2B4AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Live Backend Rate Card matching reference video
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B2E28),
                Color(0xFF071F1B),
                Color(0xFF041512),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x66D4AF37), width: 1.1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live backend rate',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFF8E9E94),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x3316A34A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'LIVE SYNCED',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _selectedTab == 'Gold Coins'
                        ? 'Rs. $goldRate'
                        : 'Rs. ${silverRate.toInt()}',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFDF7A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedTab == 'Gold Coins'
                        ? 'Gold 22K per gram'
                        : 'Silver 999 per gram',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD1DFDE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Coin prices use saved product prices or live-rate calculation when weight is available.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF8E9E94),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: _metalTabs.map((tab) {
        final isSelected = _selectedTab == tab;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedTab = tab),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0E3831) : const Color(0x33020907),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0x33C7A45B),
                  width: isSelected ? 1.4 : 0.8,
                ),
              ),
              child: Text(
                tab,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFFFFDF7A) : const Color(0xFFA2B4AF),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExploreByWeight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXPLORE BY WEIGHT',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: const Color(0xFFC7A45B),
              ),
            ),
            if (_selectedWeightFilter != null)
              GestureDetector(
                onTap: () => setState(() => _selectedWeightFilter = null),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFDF7A),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _weightPills.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (ctx, idx) {
              final item = _weightPills[idx];
              final isSelected = _selectedWeightFilter == item['weight'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedWeightFilter =
                        isSelected ? null : item['weight'];
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 72,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0B2E28)
                        : const Color(0x33061B18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : const Color(0x33C7A45B),
                      width: isSelected ? 1.4 : 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x33D4AF37),
                          border: Border.all(color: const Color(0x66D4AF37)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle_outlined,
                            size: 18,
                            color: isSelected
                                ? const Color(0xFFFFDF7A)
                                : const Color(0xFFC7A45B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFDF7A)
                              : const Color(0xFFD1DFDE),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Shop By: ',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF8E9E94),
              ),
            ),
            Text(
              '$count curated coins',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF7F2E8),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: _openFilterDrawer,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x22C7A45B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x44C7A45B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 14, color: Color(0xFFC7A45B)),
                const SizedBox(width: 4),
                Text(
                  'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF7F2E8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinGrid(List<ShopProduct> coins) {
    if (coins.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.stars_outlined, size: 48, color: Color(0xFFC7A45B)),
            const SizedBox(height: 12),
            Text(
              'No coins found matching filters',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF7F2E8),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Reset All Filters', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: coins.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (ctx, idx) {
        final coin = coins[idx];
        return _buildCoinCard(coin);
      },
    );
  }

  Widget _buildCoinCard(ShopProduct coin) {
    final isWishlisted = widget.store.isSaved(coin.id);
    final weight = coin.item.weightGrams;
    final ratePerGm = (coin.price / (weight > 0 ? weight : 1.0)).round();

    return InkWell(
      onTap: () {
        if (widget.onOpenProduct != null) {
          widget.onOpenProduct!(coin);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AthiraiProductDetailScreen(
                store: widget.store,
                product: coin,
                onBack: () => Navigator.of(context).pop(),
                onOpenBag: widget.onOpenBag ?? () {},
                onBuyNow: () {
                  AthiraiPurchaseSheet.show(
                    context,
                    product: coin,
                    store: widget.store,
                    onOrderCompleted: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AthiraiOrderSummaryScreen(
                            store: widget.store,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF061B18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33C7A45B), width: 0.9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badges & Wishlist Heart
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x33D4AF37),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x66D4AF37), width: 0.6),
                    ),
                    child: Text(
                      '${coin.metal} ${coin.item.purity}',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.store.toggleWishlist(coin.id),
                    child: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: isWishlisted ? const Color(0xFFC92035) : const Color(0xFF8E9E94),
                    ),
                  ),
                ],
              ),
            ),

            // Coin Artwork Image with Subtle Glow Pedestal
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.18),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        coin.item.assetPreview,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.asset(
                          coin.metal.toLowerCase().contains('silver')
                              ? AppAssets.shopSilverCoins
                              : AppAssets.shopGoldCoins,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Weight & GST Tag
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${weight.toStringAsFixed(weight == weight.roundToDouble() ? 1 : 4)} g  INCL. 3% GST',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8E9E94),
                ),
              ),
            ),

            // Product Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                coin.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7F2E8),
                ),
              ),
            ),

            // Price & Per-gram Rate
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. ${coin.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFDF7A),
                    ),
                  ),
                  Text(
                    'Rs. $ratePerGm / gm',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: const Color(0xFF8E9E94),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Quick Buy with AUG Coins Button
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    AthiraiPurchaseSheet.show(
                      context,
                      product: coin,
                      store: widget.store,
                      onOrderCompleted: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AthiraiOrderSummaryScreen(
                              store: widget.store,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7A45B),
                    foregroundColor: const Color(0xFF041A13),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Buy with Coins',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
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
}
