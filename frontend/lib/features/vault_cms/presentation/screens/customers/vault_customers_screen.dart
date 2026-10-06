import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_data_table.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';



class VaultCustomersScreen extends StatefulWidget {
  const VaultCustomersScreen({
    super.key,
    required this.apiService,
  });

  final VaultApiService apiService;

  @override
  State<VaultCustomersScreen> createState() => _VaultCustomersScreenState();
}

class _VaultCustomersScreenState extends State<VaultCustomersScreen> {
  List<VaultCustomer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final list = await widget.apiService.getCustomers();
    if (mounted) {
      setState(() {
        _customers = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ROYAL PATRONAGE & CLIENTELE', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
          const SizedBox(height: 4),
          Text('VIP Patron Directory', style: VaultTokens.headlineDisplay(fontSize: 28)),
          const SizedBox(height: 4),
          Text('Manage high-net-worth connoisseurs, private viewing invitations, and bespoke family heirlooms.', style: VaultTokens.bodyText(fontSize: 13)),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: VaultTokens.champagneGold)))
          else
            LuxuryDataTable(
              columns: const [
                LuxuryTableColumn(label: 'Patron', width: 220),
                LuxuryTableColumn(label: 'Tier', width: 140),
                LuxuryTableColumn(label: 'City / Region', width: 130),
                LuxuryTableColumn(label: 'Lifetime Spend', width: 140),
                LuxuryTableColumn(label: 'Contact', width: 180),
                LuxuryTableColumn(label: 'Atelier Concierge', width: 140),
              ],
              rowCount: _customers.length,
              rowBuilder: (context, index) {
                final c = _customers[index];
                return [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: VaultTokens.goldGradient,
                        ),
                        child: Center(
                          child: Text(
                            c.name.isNotEmpty ? c.name[0] : 'P',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF161108)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(c.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
                      ),
                    ],
                  ),
                  LuxuryStatusBadge(status: c.tier),
                  Text(c.city, style: GoogleFonts.inter(fontSize: 13, color: VaultTokens.warmIvory)),
                  Text('₹${(c.totalSpend / 100000).toStringAsFixed(2)} Lakhs', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
                  Text(c.phone, style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.sageLight)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Invite to Vault ↗', style: GoogleFonts.inter(fontSize: 12, color: VaultTokens.champagneGold)),
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
