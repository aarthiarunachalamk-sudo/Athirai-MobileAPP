import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_data_table.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_inputs.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';


class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({
    super.key,
    required this.apiService,
    required this.onCreateNew,
    required this.onSelectProduct,
    required this.onEditProduct,
  });

  final VaultApiService apiService;
  final VoidCallback onCreateNew;
  final ValueChanged<VaultProduct> onSelectProduct;
  final ValueChanged<VaultProduct> onEditProduct;

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<VaultProduct> _allProducts = [];
  List<VaultProduct> _filteredProducts = [];
  bool _isLoading = true;
  bool _isGridView = true;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedCollection = 'All';
  String _selectedStatus = 'All';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Necklace',
    'Rings',
    'Bangles',
    'Earrings',
    'Bridal Sets',
  ];

  final List<String> _collections = [
    'All',
    'Chola Dynasty',
    'Temple Blossoms',
    'Navratna Heritage',
    'Bridal Elegance',
    'Celestial Polki',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final list = await widget.apiService.getProducts();
    if (mounted) {
      setState(() {
        _allProducts = list;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((p) {
      if (_selectedCategory != 'All' && p.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      if (_selectedCollection != 'All' && p.collection.toLowerCase() != _selectedCollection.toLowerCase()) {
        return false;
      }
      if (_selectedStatus != 'All') {
        if (_selectedStatus == 'Low Stock') {
          if (p.stockQuantity > p.lowStockThreshold) return false;
        } else if (p.status.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.gemstones.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  void _deleteProduct(VaultProduct product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF09211B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultTokens.borderGoldMuted),
        ),
        title: Text(
          'Archive Masterpiece?',
          style: VaultTokens.titleSerif(fontSize: 20),
        ),
        content: Text(
          'Are you sure you want to archive "${product.name}"? It will be removed from the active vault catalog.',
          style: VaultTokens.bodyText(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: VaultTokens.sageMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VaultTokens.statusDanger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive Piece'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.apiService.deleteProduct(product.id);
      _loadProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Catalog Header & Actions ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED FOR GENERATIONS',
                    style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masterpiece Collection Explorer',
                    style: VaultTokens.headlineDisplay(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore, filter, and manage handcrafted temple & polki heirloom jewellery.',
                    style: VaultTokens.bodyText(fontSize: 13),
                  ),
                ],
              ),
              LuxuryGoldPillButton(
                label: '+ DESIGN NEW PIECE',
                icon: Icons.add,
                onPressed: widget.onCreateNew,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Search & Filter Controls Bar ───────────────────────────────────
          LuxuryGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            borderRadius: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: LuxurySearchInput(
                        controller: _searchController,
                        hintText: 'Search by jewel name, SKU code, or gemstone...',
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Collection Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x55071F19),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCollection,
                            dropdownColor: const Color(0xFF09211B),
                            icon: const Icon(Icons.arrow_drop_down, color: VaultTokens.champagneGold),
                            isExpanded: true,
                            items: _collections.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c == 'All' ? 'All Collections' : c,
                                  style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.warmIvory),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCollection = val;
                                  _applyFilters();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Status Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x55071F19),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            dropdownColor: const Color(0xFF09211B),
                            icon: const Icon(Icons.arrow_drop_down, color: VaultTokens.champagneGold),
                            isExpanded: true,
                            items: ['All', 'Published', 'Draft', 'Low Stock'].map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s == 'All' ? 'All Statuses' : s,
                                  style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.warmIvory),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedStatus = val;
                                  _applyFilters();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Grid vs Table Toggle

                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0x55071F19),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.grid_view,
                              size: 18,
                              color: _isGridView ? VaultTokens.champagneGold : VaultTokens.sageMuted,
                            ),
                            onPressed: () => setState(() => _isGridView = true),
                            splashRadius: 18,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.table_rows_outlined,
                              size: 18,
                              color: !_isGridView ? VaultTokens.champagneGold : VaultTokens.sageMuted,
                            ),
                            onPressed: () => setState(() => _isGridView = false),
                            splashRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Category Chips Row
                Row(
                  children: [
                    Text(
                      'CATEGORY: ',
                      style: VaultTokens.brandLabel(fontSize: 10, letterSpacing: 1.2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(cat),
                                selected: isSel,
                                onSelected: (sel) {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _applyFilters();
                                  });
                                },
                                selectedColor: const Color(0x66C7A45B),
                                backgroundColor: const Color(0x33061A14),
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                                  color: isSel ? VaultTokens.champagneGold : VaultTokens.sageLight,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted,
                                    width: 1,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Catalog Content View ───────────────────────────────────────────
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(color: VaultTokens.champagneGold),
              ),
            )
          else if (_filteredProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: VaultTokens.mutedGold),
                    const SizedBox(height: 12),
                    Text(
                      'No masterpieces found matching criteria',
                      style: VaultTokens.titleSerif(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try resetting filters or searching with a different term.',
                      style: VaultTokens.bodyText(),
                    ),
                  ],
                ),
              ),
            )
          else if (_isGridView)
            _buildProductsGrid()
          else
            _buildProductsTable(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1200
            ? 3
            : (constraints.maxWidth > 750 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.72,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final p = _filteredProducts[index];
            return LuxuryGlassCard(
              padding: const EdgeInsets.all(0),
              borderRadius: 20,
              enableHoverEffect: true,
              onTap: () => widget.onSelectProduct(p),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with Pedestal Glow & Status Pill
                  Expanded(
                    flex: 11,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.asset(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF071F19),
                              child: const Icon(Icons.diamond, color: VaultTokens.antiqueGold, size: 48),
                            ),
                          ),
                        ),
                        // Inner Dark Vignette
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Top Badges
                        Positioned(
                          top: 12,
                          left: 12,
                          child: LuxuryStatusBadge(status: p.status),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: VaultTokens.borderGoldMuted, width: 0.8),
                            ),
                            child: Text(
                              '${p.metal} ${p.purity}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: VaultTokens.champagneGold,
                              ),
                            ),
                          ),
                        ),
                        // Stock Indicator Tag at Bottom of Image
                        Positioned(
                          bottom: 10,
                          left: 12,
                          child: Text(
                            p.collection.toUpperCase(),
                            style: VaultTokens.brandLabel(fontSize: 9.5, letterSpacing: 1.5, color: VaultTokens.champagneGold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product Details Card Bottom Section
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.sku,
                                style: GoogleFonts.inter(fontSize: 10.5, color: VaultTokens.sageMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: VaultTokens.titleSerif(fontSize: 19),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p.weightGrams}g Gold • ${p.gemstones}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: VaultTokens.bodyText(fontSize: 11.5),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Divider(color: VaultTokens.borderGoldMuted, height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ESTIMATED VALUE',
                                        style: VaultTokens.brandLabel(fontSize: 9, letterSpacing: 1.0),
                                      ),
                                      Text(
                                        '₹${(p.calculatedTotalPrice / 100000).toStringAsFixed(2)} Lakhs',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: VaultTokens.champagneGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: VaultTokens.champagneGold),
                                        onPressed: () => widget.onEditProduct(p),
                                        tooltip: 'Edit Specifications',
                                        splashRadius: 18,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE57373)),
                                        onPressed: () => _deleteProduct(p),
                                        tooltip: 'Archive',
                                        splashRadius: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildProductsTable() {
    final columns = [
      const LuxuryTableColumn(label: 'Piece', width: 220),
      const LuxuryTableColumn(label: 'SKU', width: 110),
      const LuxuryTableColumn(label: 'Category', width: 100),
      const LuxuryTableColumn(label: 'Collection', width: 130),
      const LuxuryTableColumn(label: 'Purity/Weight', width: 110),
      const LuxuryTableColumn(label: 'Dynamic Price', width: 120),
      const LuxuryTableColumn(label: 'Stock', width: 70),
      const LuxuryTableColumn(label: 'Status', width: 100),
      const LuxuryTableColumn(label: 'Actions', width: 90),
    ];

    return LuxuryDataTable(
      columns: columns,
      rowCount: _filteredProducts.length,
      rowBuilder: (context, index) {
        final p = _filteredProducts[index];
        return [
          // Piece & Thumbnail
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  p.imageUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 36,
                    height: 36,
                    color: const Color(0xFF092620),
                    child: const Icon(Icons.diamond, size: 18, color: VaultTokens.antiqueGold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory),
                ),
              ),
            ],
          ),
          // SKU
          Text(p.sku, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: VaultTokens.champagneGold)),
          // Category
          Text(p.category, style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.sageLight)),
          // Collection
          Text(p.collection, style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.warmIvory)),
          // Purity/Weight
          Text('${p.purity} • ${p.weightGrams}g', style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.sageMuted)),
          // Dynamic Price
          Text(
            '₹${(p.calculatedTotalPrice / 100000).toStringAsFixed(2)} L',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold),
          ),
          // Stock
          Text('${p.stockQuantity}', style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.warmIvory)),
          // Status
          LuxuryStatusBadge(status: p.status),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 16, color: VaultTokens.champagneGold),
                onPressed: () => widget.onSelectProduct(p),
                splashRadius: 14,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: VaultTokens.sageLight),
                onPressed: () => widget.onEditProduct(p),
                splashRadius: 14,
              ),
            ],
          ),
        ];
      },
    );
  }
}
