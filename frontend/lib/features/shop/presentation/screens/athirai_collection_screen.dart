import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_recharge_screen.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_profile_dashboard_screen.dart';
import '../widgets/athirai_royal_drawer.dart';
import '../widgets/athirai_collections_megamenu_sheet.dart';

/// Screen 03: Complete Luxury Mobile Collections Explorer
/// Designed specifically for high-end jewellery mobile shopping:
/// - Sticky luxury app bar with coin balance, wishlist & cart badges, and search toggle
/// - Expandable inline search bar with real-time text query filtering
/// - Scrollable category carousel with smart singular/plural matching
/// - Secondary sort & quick filter bar (Price sort, metal filter, grid/list toggle)
/// - Context-aware hero spotlight (Temple Blossom for All/Necklaces, tailored banners for Rings, Bangles, etc.)
/// - 2-Column luxury mobile product cards with purity pills, wishlist hearts, dynamic prices, and direct actions
/// - Detailed list view mode toggle
/// - Filter bottom sheet for deep price, purity, and weight filtering
/// - Regal empty state with reset filter CTA
class AthiraiCollectionScreen extends StatefulWidget {
  const AthiraiCollectionScreen({
    super.key,
    required this.store,
    required this.onBack,
    required this.onOpenProduct,
    required this.onOpenBag,
    this.onOpenWishlist,
    this.onBuyNow,
    this.initialCategory,
    this.initialSubItem,
  });

  final ShopStore store;
  final VoidCallback onBack;
  final ValueChanged<ShopProduct> onOpenProduct;
  final VoidCallback onOpenBag;
  final VoidCallback? onOpenWishlist;
  final ValueChanged<ShopProduct>? onBuyNow;
  final String? initialCategory;
  final String? initialSubItem;

  @override
  State<AthiraiCollectionScreen> createState() =>
      _AthiraiCollectionScreenState();
}

enum _SortOption {
  curated('Curated & Featured'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  weightLowToHigh('Weight: Low to High'),
  weightHighToLow('Weight: High to Low');

  final String label;
  const _SortOption(this.label);
}

class _AthiraiCollectionScreenState extends State<AthiraiCollectionScreen> {
  late String _selectedCategory;
  String? _selectedSubItem;

  // Search & Filter State
  final _searchController = TextEditingController();
  bool _isSearchOpen = false;
  String _searchQuery = '';
  _SortOption _currentSort = _SortOption.curated;
  String _selectedMetalFilter = 'All'; // All, 22K Gold, 18K Gold, Silver
  String _selectedPriceRange = 'All'; // All, <1L, 1L-3L, 3L+
  bool _isGridView = true; // true: 2-column grid, false: detailed list

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _selectedSubItem = widget.initialSubItem;
    _searchController.addListener(() {
      final q = _searchController.text.trim();
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AthiraiCollectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory ||
        widget.initialSubItem != oldWidget.initialSubItem) {
      if (widget.initialCategory != null) {
        _selectedCategory = widget.initialCategory!;
      }
      _selectedSubItem = widget.initialSubItem;
    }
  }

  static const List<Map<String, String>> _categoryTabs = [
    {'name': 'All', 'icon': '💎'},
    {'name': 'Necklaces', 'icon': '👑'},
    {'name': 'Rings', 'icon': '💍'},
    {'name': 'Bangles', 'icon': '✨'},
    {'name': 'Earrings', 'icon': '🌸'},
    {'name': 'Chains', 'icon': '⛓️'},
    {'name': 'Coins & Bars', 'icon': '🪙'},
    {'name': 'Daily Wear', 'icon': '💛'},
    {'name': 'Wedding', 'icon': '🏛️'},
    {'name': 'Gifting', 'icon': '🎁'},
    {'name': 'Mangalsutra', 'icon': '📿'},
    {'name': 'Gold', 'icon': '🏆'},
    {'name': 'Silver', 'icon': '🌙'},
  ];

  bool _matchesCategory(ShopProduct p, String cat) {
    if (cat == 'All') return true;
    final c = cat.toLowerCase();
    final pCat = p.category.toLowerCase();
    final pName = p.name.toLowerCase();
    final pCol = p.collection.toLowerCase();
    final pMetal = p.metal.toLowerCase();

    if (c == 'necklaces' || c == 'necklace') {
      return pCat.contains('necklace') ||
          pCat.contains('temple') ||
          pName.contains('necklace') ||
          pName.contains('choker') ||
          pName.contains('collier');
    }
    if (c == 'rings' || c == 'ring') {
      return pCat.contains('ring') ||
          pName.contains('ring') ||
          pName.contains('solitaire') ||
          pName.contains('band');
    }
    if (c == 'bangles' || c == 'bangle') {
      return pCat.contains('bangle') ||
          pCat.contains('bracelet') ||
          pName.contains('bangle') ||
          pName.contains('kada') ||
          pName.contains('bracelet');
    }
    if (c == 'earrings' || c == 'earring') {
      return pCat.contains('earring') ||
          pName.contains('earring') ||
          pName.contains('jhumka') ||
          pName.contains('stud') ||
          pName.contains('ear drop');
    }
    if (c == 'chains' || c == 'chain') {
      return pCat.contains('chain') ||
          pName.contains('chain') ||
          pName.contains('figaro') ||
          pName.contains('dynastic');
    }
    if (c.contains('coin') || c.contains('bar')) {
      return pCat.contains('coin') ||
          pCat.contains('bar') ||
          pName.contains('coin') ||
          pName.contains('bar');
    }
    if (c == 'gold') {
      return pMetal == 'gold' || pName.contains('gold');
    }
    if (c == 'silver') {
      return pMetal == 'silver' || pName.contains('silver');
    }
    if (c.contains('daily')) {
      return pCol.contains('contemporary') || p.item.weightGrams <= 20.0;
    }
    if (c.contains('wedding')) {
      return pCol.contains('royal') ||
          pCol.contains('heritage') ||
          pName.contains('kundan') ||
          pName.contains('bridal');
    }
    if (c.contains('mangal')) {
      return pCat.contains('mangal') || pName.contains('mangal');
    }
    if (c.contains('gift')) {
      return p.item.weightGrams <= 25.0 ||
          pName.contains('emerald') ||
          pName.contains('ring');
    }
    return pCat == c || pCol.contains(c) || pName.contains(c);
  }

  List<ShopProduct> _getFilteredProducts(List<ShopProduct> allProducts) {
    return allProducts.where((p) {
      // 1. Sub-item / Deep collection item filter
      if (_selectedSubItem != null && _selectedSubItem!.isNotEmpty) {
        final query = _selectedSubItem!.toLowerCase();
        final matchesSub = p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.item.description.toLowerCase().contains(query) ||
            p.collection.toLowerCase().contains(query);
        if (!matchesSub) return false;
      }

      // 2. Category Filter
      if (!_matchesCategory(p, _selectedCategory)) return false;

      // 3. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesSearch = p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.collection.toLowerCase().contains(q) ||
            p.purity.toLowerCase().contains(q) ||
            p.metal.toLowerCase().contains(q) ||
            p.item.description.toLowerCase().contains(q);
        if (!matchesSearch) return false;
      }

      // 4. Metal Filter
      if (_selectedMetalFilter != 'All') {
        if (_selectedMetalFilter == '22K Gold' && p.purity != '22K') return false;
        if (_selectedMetalFilter == '18K Gold' && p.purity != '18K') return false;
        if (_selectedMetalFilter == 'Silver' && p.metal.toLowerCase() != 'silver') return false;
      }

      // 5. Price Range Filter
      if (_selectedPriceRange != 'All') {
        final price = p.price;
        if (_selectedPriceRange == '< ₹1L' && price >= 100000) return false;
        if (_selectedPriceRange == '₹1L - ₹3L' && (price < 100000 || price > 300000)) return false;
        if (_selectedPriceRange == '₹3L+' && price < 300000) return false;
      }

      return true;
    }).toList();
  }

  List<ShopProduct> _applySorting(List<ShopProduct> list) {
    final sorted = List<ShopProduct>.from(list);
    switch (_currentSort) {
      case _SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _SortOption.weightLowToHigh:
        sorted.sort((a, b) => a.weightGrams.compareTo(b.weightGrams));
        break;
      case _SortOption.weightHighToLow:
        sorted.sort((a, b) => b.weightGrams.compareTo(a.weightGrams));
        break;
      case _SortOption.curated:
        // Keep natural curated order
        break;
    }
    return sorted;
  }

  void _openDirectory([String initialTab = 'ALL JEWELLERY']) {
    AthiraiCollectionsMegamenuSheet.show(
      context,
      store: widget.store,
      initialTab: initialTab,
      onSelectItem: (collection, item) {
        setState(() {
          _selectedCategory = collection;
          _selectedSubItem = item == 'All' ? null : item;
        });
      },
    );
  }

  void _openFilterSheet(int totalMatching) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF041914),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x66C7A45B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Collections',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF7F2E8),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedMetalFilter = 'All';
                        _selectedPriceRange = 'All';
                        _currentSort = _SortOption.curated;
                      });
                      setSheetState(() {});
                    },
                    child: Text(
                      'Reset All',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Metal Purity
              Text(
                'Metal & Purity',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFA2B4AF),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', '22K Gold', '18K Gold', 'Silver'].map((metal) {
                  final isSel = _selectedMetalFilter == metal;
                  return ChoiceChip(
                    label: Text(metal),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() => _selectedMetalFilter = metal);
                      setSheetState(() {});
                    },
                    selectedColor: const Color(0x33D4AF37),
                    backgroundColor: const Color(0x22000000),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFFFFDF7A) : const Color(0xFFD1DFDE),
                    ),
                    side: BorderSide(
                      color: isSel ? const Color(0xFFD4AF37) : const Color(0x33C7A45B),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Price Range
              Text(
                'Price Range',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFA2B4AF),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', '< ₹1L', '₹1L - ₹3L', '₹3L+'].map((range) {
                  final isSel = _selectedPriceRange == range;
                  return ChoiceChip(
                    label: Text(range),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() => _selectedPriceRange = range);
                      setSheetState(() {});
                    },
                    selectedColor: const Color(0x33D4AF37),
                    backgroundColor: const Color(0x22000000),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFFFFDF7A) : const Color(0xFFD1DFDE),
                    ),
                    side: BorderSide(
                      color: isSel ? const Color(0xFFD4AF37) : const Color(0x33C7A45B),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF041814),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF041914),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Masterpieces',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF7F2E8),
              ),
            ),
            const SizedBox(height: 12),
            ..._SortOption.values.map((option) {
              final isSel = _currentSort == option;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  option.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    color: isSel ? const Color(0xFFFFDF7A) : const Color(0xFFD1DFDE),
                  ),
                ),
                trailing: isSel
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 18)
                    : null,
                onTap: () {
                  setState(() => _currentSort = option);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final rawFiltered = _getFilteredProducts(widget.store.products);
        final sortedProducts = _applySorting(rawFiltered);

        // Featured card product for 'All' or 'Necklaces'
        final isAllOrNecklace = _selectedCategory == 'All' || _selectedCategory == 'Necklaces';
        final ShopProduct? featuredProduct;
        if (isAllOrNecklace && sortedProducts.isNotEmpty) {
          featuredProduct = sortedProducts.firstWhere(
            (p) => p.name.contains('Temple Blossom'),
            orElse: () => sortedProducts.first,
          );
        } else {
          featuredProduct = null;
        }

        // Remaining products after featured
        final remainingProducts = (featuredProduct != null && isAllOrNecklace)
            ? sortedProducts.where((p) => p.id != featuredProduct!.id).toList()
            : sortedProducts;

        final hasActiveFilters = _selectedMetalFilter != 'All' ||
            _selectedPriceRange != 'All' ||
            _currentSort != _SortOption.curated;

        return Scaffold(
          backgroundColor: HeritageTheme.darkBg,
          body: Stack(
            children: [
              // Radial Luxury Emerald Vignette Backdrop
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.2, -0.3),
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
                    // 1. Mobile App Bar
                    _buildTopAppBar(context),

                    // 2. Expandable Inline Search Bar
                    if (_isSearchOpen) _buildInlineSearchBar(),

                    // 3. Category Carousel (Chips with Icons)
                    _buildFilterChips(),

                    // 4. Mobile Secondary Quick Bar (Counter + Sort + Filter + Grid Toggle)
                    _buildSecondaryControlsBar(sortedProducts.length, hasActiveFilters),

                    const SizedBox(height: 4),

                    // 5. Scrollable Masterpiece List
                    Expanded(
                      child: RefreshIndicator(
                        color: HeritageTheme.goldBright,
                        backgroundColor: const Color(0xFF04100D),
                        onRefresh: () => widget.store.loadFromBackend(),
                        child: sortedProducts.isEmpty
                            ? _buildEmptyState()
                            : SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Heritage Dial Hero Card (Rendered for 'All' or backward-compatibility)
                                    if (_selectedCategory == 'All' && _searchQuery.isEmpty) ...[
                                      _buildHeritageDialCard(),
                                      const SizedBox(height: 14),
                                    ],

                                    // Category Spotlight Banner for specific categories
                                    if (_selectedCategory != 'All' && _searchQuery.isEmpty) ...[
                                      _buildCategoryBanner(_selectedCategory, sortedProducts.length),
                                      const SizedBox(height: 14),
                                    ],

                                    // Featured Masterpiece Card (for All/Necklaces)
                                    if (featuredProduct != null) ...[
                                      _buildFeaturedProductCard(context, featuredProduct),
                                      const SizedBox(height: 14),
                                    ],

                                    // Dynamic Product Presentation: 2-Column Grid or Detailed List
                                    if (_isGridView)
                                      _buildTwoColumnGrid(context, remainingProducts)
                                    else
                                      _buildDetailedListView(context, remainingProducts),

                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    // 6. Minimalist Bottom Accent Bar with Gold Compass
                    _buildBottomCompassBar(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Top App Bar matching high-end mobile jewellery shopping apps
  Widget _buildTopAppBar(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final wishlistCount = widget.store.wishlistCount;
        final cartCount = widget.store.count;

        return Container(
          padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: HeritageTheme.textLight,
                  size: 19,
                ),
                tooltip: 'Back',
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Collections',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.textLight,
                        letterSpacing: 0.3,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      _selectedSubItem ?? (_selectedCategory == 'All' ? 'Curated for Generations' : _selectedCategory),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFDF7A),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Toggle Icon
              IconButton(
                icon: Icon(
                  _isSearchOpen ? Icons.search_off_rounded : Icons.search_rounded,
                  color: _isSearchOpen ? const Color(0xFFFFDF7A) : HeritageTheme.textLight,
                  size: 21,
                ),
                tooltip: 'Search Collections',
                onPressed: () {
                  setState(() {
                    _isSearchOpen = !_isSearchOpen;
                    if (!_isSearchOpen) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),

              // AUG Coins Wallet shortcut
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiRechargeScreen(store: widget.store),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x66D4AF37), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        widget.store.augCoins.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFDF7A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Wishlist shortcut button with live badge
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

              // Cart shortcut button with live badge
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

              // Three-line menu button (☰)
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: HeritageTheme.goldBright,
                  size: 22,
                ),
                tooltip: 'Menu',
                onPressed: () {
                  AthiraiRoyalDrawer.show(
                    context,
                    store: widget.store,
                    onSelectHome: widget.onBack,
                    onSelectProfile: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AthiraiProfileDashboardScreen(
                            store: widget.store,
                          ),
                        ),
                      );
                    },
                    onSelectOrders: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AthiraiOrderSummaryScreen(
                            store: widget.store,
                          ),
                        ),
                      );
                    },
                    onSelectWishlist: widget.onOpenWishlist,
                    onSelectCart: widget.onOpenBag,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Inline Luxury Gold Search Bar
  Widget _buildInlineSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xCC051814),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFF7F2E8)),
        decoration: InputDecoration(
          hintText: 'Search rings, necklaces, 22K gold, diamonds...',
          hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B817B)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFFDF7A), size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFFFDF7A), size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  /// Horizontal category filter carousel with icons & active gold states
  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          // Megamenu Directory Launcher Pill
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _openDirectory(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D332B), Color(0xFF08221D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 13, color: Color(0xFFFFDF7A)),
                    const SizedBox(width: 5),
                    Text(
                      'All Collections ▾',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active Sub-Item Badge
          if (_selectedSubItem != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedSubItem = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E3831),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_selectedCategory: $_selectedSubItem',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFDF7A),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.close_rounded, size: 14, color: Color(0xFFFFDF7A)),
                    ],
                  ),
                ),
              ),
            ),

          // Category Pills
          ..._categoryTabs.map((tab) {
            final cat = tab['name']!;
            final icon = tab['icon']!;
            final isSelected = cat == _selectedCategory && _selectedSubItem == null;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = cat;
                  _selectedSubItem = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFC7A45B), Color(0xFFE5C158)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0x66051814),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFDF7A)
                          : const Color(0x33C7A45B),
                      width: isSelected ? 1.4 : 0.8,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF04100D)
                              : const Color(0xFFA2B4AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Secondary Mobile Bar (Piece Counter, Sort Modal, Filter Sheet, Grid/List Switcher)
  Widget _buildSecondaryControlsBar(int totalCount, bool hasFilters) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          // Counter Chip
          Text(
            '$totalCount ${_selectedCategory == "All" ? "Pieces" : _selectedCategory}',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD1DFDE),
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),

          // Sort Button
          InkWell(
            onTap: _openSortModal,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x44051814),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33C7A45B), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, size: 14, color: Color(0xFFFFDF7A)),
                  const SizedBox(width: 4),
                  Text(
                    _currentSort == _SortOption.curated ? 'Sort' : _currentSort.label.split(':').first,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF7F2E8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Filter Button
          InkWell(
            onTap: () => _openFilterSheet(totalCount),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: hasFilters ? const Color(0x33D4AF37) : const Color(0x44051814),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasFilters ? const Color(0xFFD4AF37) : const Color(0x33C7A45B),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: hasFilters ? const Color(0xFFFFDF7A) : HeritageTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filter',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: hasFilters ? const Color(0xFFFFDF7A) : const Color(0xFFF7F2E8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Layout Switcher (Grid ⊞ vs List ☰)
          InkWell(
            onTap: () => setState(() => _isGridView = !_isGridView),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x44051814),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33C7A45B), width: 0.8),
              ),
              child: Icon(
                _isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                size: 14,
                color: const Color(0xFFFFDF7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Category Spotlight Banner for when specific categories are browsed
  Widget _buildCategoryBanner(String category, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3229), Color(0xFF061814)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x44D4AF37), width: 0.9),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x33D4AF37),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, color: Color(0xFFFFDF7A), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Royal $category Collection',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF7F2E8),
                  ),
                ),
                Text(
                  'BIS 916 Hallmarked · 100% Certified Gold & Natural Gems',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFFA2B4AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State with Clear Filters CTA
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x22D4AF37),
                border: Border.all(color: const Color(0x44D4AF37)),
              ),
              child: const Center(
                child: Icon(Icons.explore_outlined, color: Color(0xFFFFDF7A), size: 30),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Masterpieces Found',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF7F2E8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No jewellery matches your current selection or search term.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFA2B4AF),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _selectedSubItem = null;
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedMetalFilter = 'All';
                  _selectedPriceRange = 'All';
                  _currentSort = _SortOption.curated;
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF041814),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hero Card: "Heritage Dial"
  Widget _buildHeritageDialCard() {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: const Color(0xCC071B16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
      ),
      child: Row(
        children: [
          // Astrolabe Dial Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 82,
              height: 82,
              child: Image.asset(
                AppAssets.heritageDial,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF09201A),
                  child: const Icon(Icons.explore, color: HeritageTheme.goldPrimary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Timeless',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.textLight,
                      ),
                    ),
                    Text(
                      'Designs',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: HeritageTheme.goldPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Rooted in Tradition',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: HeritageTheme.textMutedDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Featured Product Card (Temple Blossom or category star)
  Widget _buildFeaturedProductCard(BuildContext context, ShopProduct product) {
    final inCart = widget.store.quantity(product.id) > 0;
    final isSaved = widget.store.isSaved(product.id);

    return GestureDetector(
      onTap: () => widget.onOpenProduct(product),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: HeritageTheme.emeraldGlow,
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Product Hero Image
              Image.asset(
                AppAssets.pedestalNecklace,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF071C17),
                  child: const Center(
                    child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary, size: 48),
                  ),
                ),
              ),

              // Gradient vignette
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // "Featured" Pill Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xD9061814),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
                  ),
                  child: Text(
                    'Featured',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.goldBright,
                    ),
                  ),
                ),
              ),

              // Wishlist Heart Icon
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    widget.store.toggleWishlist(product.id);
                    final nowSaved = widget.store.isSaved(product.id);
                    AthiraiSnackBar.show(
                      context,
                      message: nowSaved
                          ? 'Added "${product.name}" to Wishlist'
                          : 'Removed from Wishlist',
                      icon: nowSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xCC051814),
                      border: Border.all(
                        color: isSaved ? HeritageTheme.goldBright : HeritageTheme.goldBorderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isSaved ? HeritageTheme.goldBright : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Details & Actions
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name.contains('Temple Blossom')
                            ? 'Temple Blossom'
                            : (product.name.contains(' ')
                                ? product.name.substring(0, product.name.lastIndexOf(' '))
                                : product.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.textLight,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        product.name.contains('Temple Blossom')
                            ? 'Necklace'
                            : (product.name.contains(' ')
                                ? product.name.substring(product.name.lastIndexOf(' ') + 1)
                                : product.category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: HeritageTheme.goldPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${product.purity} ${product.metal} • ${product.weightGrams}g',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: const Color(0xFFA2B4AF),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            rupees(product.price),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: HeritageTheme.goldBright,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Add to Cart
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: inCart
                                    ? HeritageTheme.goldPrimary.withOpacity(0.2)
                                    : const Color(0xCC071B16),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: inCart ? HeritageTheme.goldBright : HeritageTheme.goldBorder,
                                  width: 0.9,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  widget.store.addToCart(product.id, 1);
                                  AthiraiSnackBar.show(
                                    context,
                                    message: 'Added "${product.name}" to Cart',
                                    icon: Icons.shopping_bag_outlined,
                                    actionLabel: 'VIEW CART',
                                    onAction: widget.onOpenBag,
                                  );
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        inCart ? Icons.check_circle_rounded : Icons.shopping_bag_outlined,
                                        color: HeritageTheme.goldPrimary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        inCart ? 'In Cart (${widget.store.quantity(product.id)})' : 'Add to Cart',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
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
                          const SizedBox(width: 8),
                          // Buy Now
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: HeritageTheme.goldGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: HeritageTheme.goldPrimary.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  widget.store.addToCart(product.id, 1);
                                  if (widget.onBuyNow != null) {
                                    widget.onBuyNow!(product);
                                  } else {
                                    widget.onOpenBag();
                                  }
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.flash_on_rounded, color: Color(0xFF1A1203), size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Buy Now',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1A1203),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2-Column Luxury Mobile Product Grid
  Widget _buildTwoColumnGrid(BuildContext context, List<ShopProduct> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.51,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = products[index];
        final inCart = widget.store.quantity(item.id) > 0;
        final isSaved = widget.store.isSaved(item.id);

        return GestureDetector(
          onTap: () => widget.onOpenProduct(item),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xCC071B16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with Floating Badges
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: const Color(0x66040F0D),
                          child: item.image.startsWith('http')
                              ? Image.network(
                                  item.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary),
                                  ),
                                )
                              : Image.asset(
                                  item.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(Icons.diamond_outlined, color: HeritageTheme.goldPrimary),
                                  ),
                                ),
                        ),

                        // Purity Pill Badge (Top Left)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xE6051814),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x88D4AF37), width: 0.7),
                            ),
                            child: Text(
                              '${item.purity} Gold',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFDF7A),
                              ),
                            ),
                          ),
                        ),

                        // Wishlist Heart Button (Top Right)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              widget.store.toggleWishlist(item.id);
                              final nowSaved = widget.store.isSaved(item.id);
                              AthiraiSnackBar.show(
                                context,
                                message: nowSaved
                                    ? 'Added "${item.name}" to Wishlist'
                                    : 'Removed from Wishlist',
                                icon: nowSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xCC04100D),
                                border: Border.all(
                                  color: isSaved ? HeritageTheme.goldBright : const Color(0x44D4AF37),
                                  width: 0.8,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isSaved ? HeritageTheme.goldBright : Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Collection Tag
                        Text(
                          item.collection.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFA2B4AF),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Title
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: HeritageTheme.textLight,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Weight & Hallmark
                        Text(
                          '${item.weightGrams}g • BIS Hallmark',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            color: const Color(0xFF6B817B),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Price
                        Text(
                          rupees(item.price),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: HeritageTheme.goldBright,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Quick Mobile Thumb Actions
                        Row(
                          children: [
                            // "Add to Cart" Capsule
                            Expanded(
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: inCart
                                      ? HeritageTheme.goldPrimary.withOpacity(0.2)
                                      : const Color(0xCC051814),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: inCart ? HeritageTheme.goldBright : HeritageTheme.goldBorderSubtle,
                                    width: 0.8,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    widget.store.addToCart(item.id, 1);
                                    AthiraiSnackBar.show(
                                      context,
                                      message: 'Added "${item.name}" to Cart',
                                      icon: Icons.shopping_bag_outlined,
                                      actionLabel: 'VIEW CART',
                                      onAction: widget.onOpenBag,
                                    );
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          inCart ? Icons.check_circle_rounded : Icons.shopping_bag_outlined,
                                          color: HeritageTheme.goldPrimary,
                                          size: 11,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          inCart ? 'In Cart' : 'Cart',
                                          style: GoogleFonts.inter(
                                            fontSize: 9.5,
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
                            const SizedBox(width: 4),

                            // "Buy Now" Mini Pill
                            Expanded(
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: HeritageTheme.goldGradient,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    widget.store.addToCart(item.id, 1);
                                    if (widget.onBuyNow != null) {
                                      widget.onBuyNow!(item);
                                    } else {
                                      widget.onOpenBag();
                                    }
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.flash_on_rounded, color: Color(0xFF1A1203), size: 11),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Buy',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1A1203),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Full-width Detailed List View Mode (for detailed appraisal browsing)
  Widget _buildDetailedListView(BuildContext context, List<ShopProduct> products) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = products[index];
        final inCart = widget.store.quantity(item.id) > 0;
        final isSaved = widget.store.isSaved(item.id);

        return GestureDetector(
          onTap: () => widget.onOpenProduct(item),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xCC071B16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: item.image.startsWith('http')
                        ? Image.network(item.image, fit: BoxFit.cover)
                        : Image.asset(item.image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),

                // Specs & Prices
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.purity} ${item.metal} • ${item.weightGrams}g',
                            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFA2B4AF)),
                          ),
                          GestureDetector(
                            onTap: () => widget.store.toggleWishlist(item.id),
                            child: Icon(
                              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isSaved ? HeritageTheme.goldBright : Colors.white60,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rupees(item.price),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: HeritageTheme.goldBright,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.store.addToCart(item.id, 1);
                              AthiraiSnackBar.show(
                                context,
                                message: 'Added "${item.name}" to Cart',
                                icon: Icons.shopping_bag_outlined,
                                actionLabel: 'VIEW CART',
                                onAction: widget.onOpenBag,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: inCart ? const Color(0x33D4AF37) : const Color(0xFFD4AF37),
                              foregroundColor: inCart ? const Color(0xFFFFDF7A) : const Color(0xFF04100D),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              inCart ? 'In Cart' : 'Add to Cart',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
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
        );
      },
    );
  }

  /// Minimalist bottom accent bar with gold compass emblem
  Widget _buildBottomCompassBar() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
          ),
          child: const Center(
            child: Icon(
              Icons.explore_outlined,
              color: HeritageTheme.goldPrimary,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
