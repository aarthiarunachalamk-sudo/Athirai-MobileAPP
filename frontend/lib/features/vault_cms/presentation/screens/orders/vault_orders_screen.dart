import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_data_table.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';



class VaultOrdersScreen extends StatefulWidget {
  const VaultOrdersScreen({
    super.key,
    required this.apiService,
  });

  final VaultApiService apiService;

  @override
  State<VaultOrdersScreen> createState() => _VaultOrdersScreenState();
}

class _VaultOrdersScreenState extends State<VaultOrdersScreen> {
  List<VaultOrder> _orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'All';
  VaultOrder? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final list = await widget.apiService.getOrders(status: _selectedStatus == 'All' ? null : _selectedStatus);
    if (mounted) {
      setState(() {
        _orders = list;
        _isLoading = false;
      });
    }
  }

  void _openOrderDetail(VaultOrder order) {
    setState(() => _selectedOrder = order);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PATRON COMMISSIONS & ACQUISITIONS', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
              const SizedBox(height: 4),
              Text('Orders & Bespoke Commissions', style: VaultTokens.headlineDisplay(fontSize: 28)),
              const SizedBox(height: 4),
              Text('Track luxury jewellery acquisitions from crafting in atelier through BIS hallmarking to white-glove delivery.', style: VaultTokens.bodyText(fontSize: 13)),
              const SizedBox(height: 24),

              // Status Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Confirmed', 'Crafting', 'Hallmarking', 'Shipped', 'Delivered'].map((status) {
                    final isSel = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status),
                        selected: isSel,
                        onSelected: (sel) {
                          setState(() => _selectedStatus = status);
                          _loadOrders();
                        },
                        selectedColor: const Color(0x66C7A45B),
                        backgroundColor: const Color(0x33061A14),
                        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w400, color: isSel ? VaultTokens.champagneGold : VaultTokens.sageLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: VaultTokens.champagneGold)))
              else
                LuxuryDataTable(
                  columns: const [
                    LuxuryTableColumn(label: 'Order ID', width: 130),
                    LuxuryTableColumn(label: 'VIP Patron', width: 180),
                    LuxuryTableColumn(label: 'Masterpiece Piece', width: 220),
                    LuxuryTableColumn(label: 'Amount (₹)', width: 120),
                    LuxuryTableColumn(label: 'Payment Method', width: 160),
                    LuxuryTableColumn(label: 'Crafting Status', width: 120),
                    LuxuryTableColumn(label: 'View', width: 70),
                  ],
                  rowCount: _orders.length,
                  rowBuilder: (context, index) {
                    final o = _orders[index];
                    return [
                      Text(o.orderId, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: VaultTokens.champagneGold)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(o.customerName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
                          Text(o.customerEmail, style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.sageMuted)),
                        ],
                      ),
                      Text(o.productName, style: GoogleFonts.inter(fontSize: 13, color: VaultTokens.warmIvory)),
                      Text('₹${(o.totalAmount / 100000).toStringAsFixed(2)} L', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
                      Text(o.paymentMethod, style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.sageLight)),
                      LuxuryStatusBadge(status: o.status),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 14, color: VaultTokens.champagneGold),
                        onPressed: () => _openOrderDetail(o),
                        splashRadius: 14,
                      ),
                    ];
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),

        // Sliding Order Detail Drawer (when selected)
        if (_selectedOrder != null)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: 440,
              decoration: BoxDecoration(
                color: const Color(0xFF061814),
                border: const Border(left: BorderSide(color: VaultTokens.borderGoldMuted, width: 1.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30, offset: const Offset(-8, 0)),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('COMMISSION DETAILS', style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.8)),
                        IconButton(
                          icon: const Icon(Icons.close, color: VaultTokens.sageLight),
                          onPressed: () => setState(() => _selectedOrder = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_selectedOrder!.orderId, style: VaultTokens.headlineDisplay(fontSize: 22)),
                    const SizedBox(height: 8),
                    LuxuryStatusBadge(status: _selectedOrder!.status),
                    const Divider(color: VaultTokens.borderGoldMuted, height: 28),

                    Text('PATRON INFORMATION', style: VaultTokens.brandLabel(fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(_selectedOrder!.customerName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: VaultTokens.warmIvory)),
                    Text(_selectedOrder!.customerEmail, style: GoogleFonts.inter(fontSize: 13, color: VaultTokens.sageLight)),
                    Text(_selectedOrder!.customerPhone, style: GoogleFonts.inter(fontSize: 13, color: VaultTokens.sageLight)),
                    const Divider(color: VaultTokens.borderGoldMuted, height: 28),

                    Text('MASTERPIECE COMMISSIONED', style: VaultTokens.brandLabel(fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(_selectedOrder!.productName, style: VaultTokens.titleSerif(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Total Valuation: ₹${_selectedOrder!.totalAmount}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: VaultTokens.champagneGold)),
                    Text('Payment: ${_selectedOrder!.paymentMethod}', style: GoogleFonts.inter(fontSize: 12.5, color: VaultTokens.sageMuted)),
                    const Divider(color: VaultTokens.borderGoldMuted, height: 28),

                    Text('ATELIER CRAFTING PROGRESSION', style: VaultTokens.brandLabel(fontSize: 10)),
                    const SizedBox(height: 12),
                    ...['Confirmed', 'Crafting', 'Hallmarking', 'Shipped', 'Delivered'].map((st) {
                      final isCurrent = _selectedOrder!.status.toLowerCase() == st.toLowerCase();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isCurrent ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted),
                            backgroundColor: isCurrent ? const Color(0x33C7A45B) : Colors.transparent,
                          ),
                          onPressed: () {
                            setState(() {
                              final idx = _orders.indexWhere((x) => x.id == _selectedOrder!.id);
                              if (idx != -1) {
                                final updated = VaultOrder(
                                  id: _selectedOrder!.id,
                                  orderId: _selectedOrder!.orderId,
                                  customerName: _selectedOrder!.customerName,
                                  customerEmail: _selectedOrder!.customerEmail,
                                  customerPhone: _selectedOrder!.customerPhone,
                                  productName: _selectedOrder!.productName,
                                  totalAmount: _selectedOrder!.totalAmount,
                                  paymentMethod: _selectedOrder!.paymentMethod,
                                  status: st,
                                );
                                _orders[idx] = updated;
                                _selectedOrder = updated;
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(st, style: GoogleFonts.inter(fontSize: 13, color: isCurrent ? VaultTokens.champagneGold : VaultTokens.sageLight)),
                              if (isCurrent) const Icon(Icons.check, size: 16, color: VaultTokens.champagneGold),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
