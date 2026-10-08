import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/models/athirai_collections_catalog.dart';
import '../../domain/shop_store.dart';

/// Interactive Luxury Collections Mega-Menu / Directory Sheet
/// Exact match for Athirai Website Collections Explorer Screenshot:
/// - Brand logo with Tamil "ஆதிரை" crest
/// - Search bar ("Search gold & silver jewellery...")
/// - Live Rates Pill ("Today's Gold Rate 22K - Rs. 14,250/-")
/// - Category Tabs Bar (ALL JEWELLERY, GOLD, SILVER, COINS, OFFERS, TEAM369-LIVE, WEDDING, GIFTING, NEARBY SHOP)
/// - 8 Columns of Collections:
///   1. G Gold Jewellery (16 items)
///   2. S Silver Jewellery (12 items)
///   3. C Coins & Bars (7 items)
///   4. D Daily Wear (6 items)
///   5. W Wedding Jewellery (6 items)
///   6. G Gifting Collection (6 items)
///   7. M Mangalsutra (5 items)
///   8. O Other Jewellery (6 items)
class AthiraiCollectionsMegamenuSheet extends StatefulWidget {
  const AthiraiCollectionsMegamenuSheet({
    super.key,
    required this.store,
    required this.onSelectItem,
    this.initialTab = 'ALL JEWELLERY',
  });

  final ShopStore store;
  final void Function(String collection, String item) onSelectItem;
  final String initialTab;

  /// Convenience launcher
  static void show(
    BuildContext context, {
    required ShopStore store,
    required void Function(String collection, String item) onSelectItem,
    String initialTab = 'ALL JEWELLERY',
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AthiraiCollectionsMegamenuSheet(
        store: store,
        onSelectItem: onSelectItem,
        initialTab: initialTab,
      ),
    );
  }

  @override
  State<AthiraiCollectionsMegamenuSheet> createState() =>
      _AthiraiCollectionsMegamenuSheetState();
}

class _AthiraiCollectionsMegamenuSheetState
    extends State<AthiraiCollectionsMegamenuSheet> {
  late String _activeTab;
  String _searchFilter = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AthiraiCollectionColumn> get _filteredColumns {
    var cols = AthiraiCollectionsCatalog.columns;

    // Filter by category tab if not ALL JEWELLERY
    if (_activeTab == 'GOLD') {
      cols = cols.where((c) => c.id == 'gold').toList();
    } else if (_activeTab == 'SILVER') {
      cols = cols.where((c) => c.id == 'silver').toList();
    } else if (_activeTab == 'COINS') {
      cols = cols.where((c) => c.id == 'coins').toList();
    } else if (_activeTab == 'WEDDING') {
      cols = cols.where((c) => c.id == 'wedding').toList();
    } else if (_activeTab == 'GIFTING') {
      cols = cols.where((c) => c.id == 'gifting').toList();
    } else if (_activeTab == 'OFFERS') {
      // In offers, show gold, coins, and wedding
      cols = cols.where((c) => c.id == 'gold' || c.id == 'coins' || c.id == 'wedding').toList();
    }

    if (_searchFilter.trim().isEmpty) return cols;

    final q = _searchFilter.toLowerCase().trim();
    return cols
        .map((col) {
          final matchingItems =
              col.items.where((it) => it.toLowerCase().contains(q)).toList();
          if (col.title.toLowerCase().contains(q) || matchingItems.isNotEmpty) {
            return AthiraiCollectionColumn(
              id: col.id,
              badgeLetter: col.badgeLetter,
              title: col.title,
              badgeColor: col.badgeColor,
              viewAllLabel: col.viewAllLabel,
              items: matchingItems.isNotEmpty ? matchingItems : col.items,
            );
          }
          return null;
        })
        .whereType<AthiraiCollectionColumn>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      decoration: BoxDecoration(
        color: const Color(0xFF041410),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            spreadRadius: 10,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Sheet Drag Handle & Close Row ──────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x55D4AF37),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header: Tamil Logo, Rates Ticker, Close Button ─────────────────
          _buildHeader(),

          // ── Search Bar ("Search gold & silver jewellery...") ───────────────
          _buildSearchBar(),

          // ── Category Tabs Bar ──────────────────────────────────────────────
          _buildCategoryTabs(),

          const Divider(color: Color(0x26C7A45B), height: 1),

          // ── 8 Collections Columns Catalog ──────────────────────────────────
          Expanded(
            child: _buildColumnsDirectory(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // Brand Emblem + Tamil "ஆதிரை" Text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.emeraldCrest,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.diamond_outlined,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ஆதிரை',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFDF7A),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'ATHIRAI JEWELS',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC7A45B),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Live Today's Gold Rate Pill
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF092923),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 0.9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFFFFDF7A)),
                    const SizedBox(width: 6),
                    Text(
                      "Today's Gold Rate 22K - Rs. ${_formatNumber(widget.store.rates.gold22k)}/-",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close_rounded, color: Color(0xFFC7A45B), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0x55020907),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x44C7A45B)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded, size: 18, color: Color(0xFFC7A45B)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchFilter = val),
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFF7F2E8)),
                decoration: InputDecoration(
                  hintText: 'Search gold & silver jewellery...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7E928D)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchFilter.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 16, color: Color(0xFFC7A45B)),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _searchFilter = '');
                },
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.mic_none_rounded, size: 18, color: Color(0xFFC7A45B)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: AthiraiCollectionsCatalog.categoryTabs.map((tab) {
          final isSelected = _activeTab == tab;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _activeTab = tab),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0E3831) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFD4AF37) : const Color(0x26C7A45B),
                    width: isSelected ? 1.2 : 0.7,
                  ),
                ),
                child: Text(
                  tab,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.8,
                    color: isSelected ? const Color(0xFFFFDF7A) : const Color(0xFFA2B4AF),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnsDirectory() {
    final cols = _filteredColumns;

    if (cols.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFC7A45B)),
            const SizedBox(height: 10),
            Text(
              'No collections matching "$_searchFilter"',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFA2B4AF)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: cols.length,
      itemBuilder: (ctx, idx) {
        final col = cols[idx];
        return _buildColumnCard(col);
      },
    );
  }

  Widget _buildColumnCard(AthiraiCollectionColumn col) {
    return Container(
      width: 215,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0x80030E0C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33C7A45B), width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Column Header: Badge Letter + Title ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xCC092620),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                // Capital Initial Letter Badge
                Text(
                  col.badgeLetter,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: col.badgeColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    col.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF7F2E8),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Subcategory Items List ──────────────────────────────
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: col.items.length,
              separatorBuilder: (_, _) => const Divider(
                color: Color(0x12C7A45B),
                height: 1,
              ),
              itemBuilder: (ctx, itemIdx) {
                final item = col.items[itemIdx];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelectItem(col.title, item);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD6E3DF),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: Color(0x55C7A45B),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Column Footer: "View All [Category] →" ─────────────────────────
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              widget.onSelectItem(col.title, 'All');
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0x330E3831),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      col.viewAllLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: Color(0xFFFFDF7A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int val) {
    final str = val.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }
}
