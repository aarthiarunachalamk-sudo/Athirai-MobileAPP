import 'package:flutter/material.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../widgets/athirai_add_jewel_sheet.dart';

/// Screen displaying the 100% Dynamic Jewellery Price List & Metal Rates Calculator.
class AthiraiPriceListScreen extends StatefulWidget {
  const AthiraiPriceListScreen({
    super.key,
    required this.store,
    required this.onBack,
    required this.onOpenProduct,
    required this.onOpenBag,
    this.onOpenStudio,
  });

  final ShopStore store;
  final VoidCallback onBack;
  final ValueChanged<ShopProduct> onOpenProduct;
  final VoidCallback onOpenBag;
  final ValueChanged<ShopProduct>? onOpenStudio;

  @override
  State<AthiraiPriceListScreen> createState() => _AthiraiPriceListScreenState();
}

class _AthiraiPriceListScreenState extends State<AthiraiPriceListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRateEditorDialog() {
    final gold22kCtrl = TextEditingController(text: widget.store.rates.gold22k.toString());
    final gold24kCtrl = TextEditingController(text: widget.store.rates.gold24k.toString());
    final gold18kCtrl = TextEditingController(text: widget.store.rates.gold18k.toString());
    final silverCtrl = TextEditingController(text: widget.store.rates.silver999.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: HeritageTheme.creamBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF073B3F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFFFD978), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Daily Metal Rates',
                          style: HeritageTheme.serif(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'All product prices will recalculate dynamically',
                          style: TextStyle(color: HeritageTheme.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRateInputField('22K Gold (₹/g)', gold22kCtrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRateInputField('24K Gold (₹/g)', gold24kCtrl),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRateInputField('18K Gold (₹/g)', gold18kCtrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRateInputField('999 Silver (₹/g)', silverCtrl),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageTheme.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final g22 = int.tryParse(gold22kCtrl.text);
                    final g24 = int.tryParse(gold24kCtrl.text);
                    final g18 = int.tryParse(gold18kCtrl.text);
                    final sil = double.tryParse(silverCtrl.text);

                    widget.store.updateMetalRates(
                      gold22k: g22,
                      gold24k: g24,
                      gold18k: g18,
                      silver999: sil,
                    );

                    Navigator.pop(ctx);
                    setState(() {});

                    AthiraiSnackBar.show(
                      context,
                      message: 'Updated live metal rates! 22K is now ₹${widget.store.rates.gold22k}/g',
                      icon: Icons.currency_rupee_rounded,
                    );
                  },
                  child: const Text('Save Rates & Recalculate All Prices', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF5A483C))),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DCCB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DCCB))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final rates = widget.store.rates;
        final products = widget.store.products;

        final filtered = products.where((p) {
          final matchesCat = _selectedCategory == 'All' ||
              p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
          final matchesSearch = _searchQuery.isEmpty || p.matchesSearch(_searchQuery);
          return matchesCat && matchesSearch;
        }).toList();

        final totalWeight = filtered.fold<double>(0, (sum, p) => sum + p.weightGrams);
        final totalValuation = filtered.fold<int>(0, (sum, p) => sum + p.price);

        return Scaffold(
          backgroundColor: HeritageTheme.creamBg,
          appBar: AppBar(
            backgroundColor: HeritageTheme.creamBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: HeritageTheme.ebony),
              onPressed: widget.onBack,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dynamic Price List',
                  style: HeritageTheme.serif(fontSize: 19, fontWeight: FontWeight.bold, color: HeritageTheme.ebony),
                ),
                Text(
                  'Live Bullion & Making Charges Breakdown',
                  style: HeritageTheme.sans(fontSize: 10.5, color: HeritageTheme.muted),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Add New Jewel',
                icon: const Icon(Icons.add_circle_outline_rounded, color: HeritageTheme.maroon, size: 22),
                onPressed: () => AthiraiAddJewelSheet.show(context, store: widget.store),
              ),
              IconButton(
                tooltip: 'Shopping Bag',
                icon: Badge(
                  isLabelVisible: widget.store.count > 0,
                  backgroundColor: HeritageTheme.maroon,
                  label: Text('${widget.store.count}'),
                  child: const Icon(Icons.shopping_bag_outlined, color: HeritageTheme.ebony, size: 22),
                ),
                onPressed: widget.onOpenBag,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: HeritageTheme.maroon,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_circle_rounded, color: Color(0xFFFFD978)),
            label: const Text('Add Jewel / Category', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => AthiraiAddJewelSheet.show(context, store: widget.store),
          ),
          body: Column(
            children: [
              // 1. Live Metal Rates Header & Rate Editor Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF073B3F), Color(0xFF0F565C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF073B3F).withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('LIVE RATES', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Daily Gold & Silver Feed',
                              style: TextStyle(color: Color(0xFFCCA881), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _showRateEditorDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCCA881), width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_rounded, color: Color(0xFFFFD978), size: 12),
                                SizedBox(width: 4),
                                Text('Edit Rates', style: TextStyle(color: Color(0xFFFFD978), fontSize: 10.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRatePill('22K Gold', '₹${rates.gold22k}/g'),
                        _buildRatePill('24K Gold', '₹${rates.gold24k}/g'),
                        _buildRatePill('18K Gold', '₹${rates.gold18k}/g'),
                        _buildRatePill('999 Silver', '₹${rates.silver999.toStringAsFixed(1)}/g'),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Search & Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8DCCB)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search jewel, purity, weight...',
                            hintStyle: const TextStyle(color: Color(0xFFA09282), fontSize: 12.5),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: HeritageTheme.ebony),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
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
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Category Filter Chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFilterChip('All', filteredCount: products.length),
                    for (final cat in widget.store.categories)
                      _buildFilterChip(cat.name),
                  ],
                ),
              ),

              // 4. Summary Strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Jewels • ${totalWeight.toStringAsFixed(1)}g Total Weight',
                      style: const TextStyle(color: Color(0xFF6B5848), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Total: ${rupees(totalValuation)}',
                      style: const TextStyle(color: HeritageTheme.maroon, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 5. Dynamic Itemized Price List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diamond_outlined, size: 48, color: HeritageTheme.gold),
                            const SizedBox(height: 12),
                            Text(
                              'No jewels found in "$_selectedCategory"',
                              style: HeritageTheme.serif(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: HeritageTheme.maroon),
                              onPressed: () => AthiraiAddJewelSheet.show(context, store: widget.store),
                              child: const Text('+ Add a Jewel Now', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 84),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          final breakdown = product.getBreakdown(rates);
                          return _buildPriceListCard(product, breakdown);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatePill(String title, String rate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFDCD2C6), fontSize: 9.5)),
        Text(rate, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilterChip(String label, {int? filteredCount}) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = label),
        selectedColor: HeritageTheme.maroon,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : HeritageTheme.ebony,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? HeritageTheme.maroon : const Color(0xFFE8DCCB),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceListCard(ShopProduct product, JewelPriceBreakdown b) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DCCB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Summary Row
          InkWell(
            onTap: () => widget.onOpenProduct(product),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8DCCB)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.diamond_outlined, color: HeritageTheme.gold),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title, Category & Weight
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF073B3F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${b.purity} • ${b.metal}',
                                style: const TextStyle(color: Color(0xFFCCA881), fontSize: 8.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${b.weightGrams}g Net',
                              style: const TextStyle(color: Color(0xFF7A6E63), fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HeritageTheme.serif(fontSize: 14, fontWeight: FontWeight.bold, color: HeritageTheme.ebony),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              rupees(b.finalPrice),
                              style: HeritageTheme.sans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: HeritageTheme.maroon,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(@ ₹${b.metalRatePerGram.toInt()}/g)',
                              style: const TextStyle(color: HeritageTheme.muted, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Add to Bag Quick Button
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart_rounded, color: HeritageTheme.maroon, size: 20),
                    onPressed: () {
                      widget.store.addToCart(product.id);
                      AthiraiSnackBar.show(
                        context,
                        message: 'Added "${product.name}" to Bag!',
                        icon: Icons.shopping_bag_outlined,
                        actionLabel: 'VIEW BAG',
                        onAction: widget.onOpenBag,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0E6D8)),

          // Itemized Calculation Table
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF7F2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Column(
              children: [
                _buildBreakdownLine('Metal Component (${b.weightGrams}g × ₹${b.metalRatePerGram.toInt()}):', rupees(b.goldComponent)),
                _buildBreakdownLine('Making Charges / VA (${b.makingChargePercent}%):', rupees(b.makingCharges)),
                if (b.stonePrice > 0)
                  _buildBreakdownLine('Stone / Diamond Value:', rupees(b.stonePrice)),
                _buildBreakdownLine('GST (3% Bullion Tax):', rupees(b.gst)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Dynamic Price:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: HeritageTheme.ebony)),
                    Text(rupees(b.finalPrice), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: HeritageTheme.maroon)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownLine(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B5848))),
          Text(val, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: HeritageTheme.ebony)),
        ],
      ),
    );
  }
}
