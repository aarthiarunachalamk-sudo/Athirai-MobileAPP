import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_data_table.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';


class VaultInventoryScreen extends StatefulWidget {
  const VaultInventoryScreen({
    super.key,
    required this.apiService,
  });

  final VaultApiService apiService;

  @override
  State<VaultInventoryScreen> createState() => _VaultInventoryScreenState();
}

class _VaultInventoryScreenState extends State<VaultInventoryScreen> {
  List<VaultProduct> _products = [];
  bool _isLoading = true;
  String _selectedWarehouse = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await widget.apiService.getProducts();
    if (mounted) {
      setState(() {
        _products = list;
        _isLoading = false;
      });
    }
  }

  void _adjustStock(VaultProduct p, int delta) async {
    final newStock = (p.stockQuantity + delta).clamp(0, 9999);
    final updated = p.copyWith(stockQuantity: newStock);
    await widget.apiService.updateProduct(updated);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) {
      if (_selectedWarehouse != 'All' && !p.warehouse.toLowerCase().contains(_selectedWarehouse.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    final totalPieces = _products.fold<int>(0, (sum, p) => sum + p.stockQuantity);
    final lowStockPieces = _products.where((p) => p.stockQuantity <= p.lowStockThreshold).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VAULT STOCK & ATELIER LOGISTICS', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
          const SizedBox(height: 4),
          Text('Inventory Management', style: VaultTokens.headlineDisplay(fontSize: 28)),
          const SizedBox(height: 4),
          Text('Monitor physical pieces in flagship vaults, safety thresholds, and warehouse dispatches.', style: VaultTokens.bodyText(fontSize: 13)),
          const SizedBox(height: 24),

          // Overview KPI Cards
          Row(
            children: [
              Expanded(
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL PHYSICAL UNITS', style: VaultTokens.brandLabel(fontSize: 9.5)),
                      const SizedBox(height: 4),
                      Text('$totalPieces Pieces', style: VaultTokens.headlineDisplay(fontSize: 22, fontWeight: FontWeight.w700)),
                      Text('Across all 4 vaults', style: VaultTokens.bodyText(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOW STOCK WARNINGS', style: VaultTokens.brandLabel(fontSize: 9.5)),
                      const SizedBox(height: 4),
                      Text('$lowStockPieces Masterpieces', style: VaultTokens.headlineDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFFFFB74D))),
                      Text('Replenish crafting orders', style: VaultTokens.bodyText(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESTIMATED VAULT VALUE', style: VaultTokens.brandLabel(fontSize: 9.5)),
                      const SizedBox(height: 4),
                      Text('₹1.24 Crores', style: VaultTokens.headlineDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
                      Text('Synchronized with live bullion', style: VaultTokens.bodyText(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Warehouse Filter Chips
          Row(
            children: [
              Text('WAREHOUSE: ', style: VaultTokens.brandLabel(fontSize: 10)),
              const SizedBox(width: 8),
              ...['All', 'Chennai', 'Bangalore', 'Hyderabad'].map((w) {
                final isSel = _selectedWarehouse == w;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(w),
                    selected: isSel,
                    onSelected: (sel) => setState(() => _selectedWarehouse = w),
                    selectedColor: const Color(0x66C7A45B),
                    backgroundColor: const Color(0x33061A14),
                    labelStyle: GoogleFonts.inter(fontSize: 12, color: isSel ? VaultTokens.champagneGold : VaultTokens.sageLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted)),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Inventory Table
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: VaultTokens.champagneGold)))
          else
            LuxuryDataTable(
              columns: const [
                LuxuryTableColumn(label: 'Piece', width: 220),
                LuxuryTableColumn(label: 'SKU', width: 110),
                LuxuryTableColumn(label: 'Warehouse', width: 180),
                LuxuryTableColumn(label: 'Stock Units', width: 110),
                LuxuryTableColumn(label: 'Min Threshold', width: 100),
                LuxuryTableColumn(label: 'Status', width: 120),
                LuxuryTableColumn(label: 'Quick Restock', width: 110),
              ],
              rowCount: filtered.length,
              rowBuilder: (context, index) {
                final p = filtered[index];
                final isLow = p.stockQuantity <= p.lowStockThreshold;

                return [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          p.imageUrl,
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(width: 34, height: 34, color: const Color(0xFF061A14)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
                      ),
                    ],
                  ),
                  Text(p.sku, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: VaultTokens.champagneGold)),
                  Text(p.warehouse, style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.sageLight)),
                  Text('${p.stockQuantity} Units', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isLow ? const Color(0xFFFFB74D) : VaultTokens.warmIvory)),
                  Text('${p.lowStockThreshold} Units', style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.sageMuted)),
                  LuxuryStatusBadge(status: isLow ? 'Low Stock' : 'In Stock'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 18, color: VaultTokens.sageMuted),
                        onPressed: p.stockQuantity > 0 ? () => _adjustStock(p, -1) : null,
                        splashRadius: 14,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 18, color: VaultTokens.champagneGold),
                        onPressed: () => _adjustStock(p, 1),
                        splashRadius: 14,
                      ),
                    ],
                  ),
                ];
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
