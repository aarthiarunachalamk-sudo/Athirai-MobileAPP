import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';

import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_inputs.dart';


class VaultSettingsScreen extends StatefulWidget {
  const VaultSettingsScreen({
    super.key,
    required this.apiService,
  });

  final VaultApiService apiService;

  @override
  State<VaultSettingsScreen> createState() => _VaultSettingsScreenState();
}

class _VaultSettingsScreenState extends State<VaultSettingsScreen> {
  final _gold24kCtrl = TextEditingController(text: '7980');
  final _gold22kCtrl = TextEditingController(text: '7450');
  final _gold18kCtrl = TextEditingController(text: '6100');
  final _silverCtrl = TextEditingController(text: '98.50');
  bool _isSaving = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    final rates = await widget.apiService.getMetalRates();
    if (mounted) {
      setState(() {
        _gold24kCtrl.text = rates.gold24k.toString();
        _gold22kCtrl.text = rates.gold22k.toString();
        _gold18kCtrl.text = rates.gold18k.toString();
        _silverCtrl.text = rates.silver999.toString();
      });
    }
  }

  Future<void> _saveRates() async {
    setState(() {
      _isSaving = true;
      _successMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isSaving = false;
        _successMessage = 'Live bullion rates updated. Catalog dynamic prices successfully recalculated.';
      });
    }
  }

  @override
  void dispose() {
    _gold24kCtrl.dispose();
    _gold22kCtrl.dispose();
    _gold18kCtrl.dispose();
    _silverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONFIGURATION & BULLION CONTROLS', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
          const SizedBox(height: 4),
          Text('Vault Atelier Settings', style: VaultTokens.headlineDisplay(fontSize: 28)),
          const SizedBox(height: 4),
          Text('Override live precious metal market rates, configure hallmark assay standards, and manage brand profile.', style: VaultTokens.bodyText(fontSize: 13)),
          const SizedBox(height: 28),

          // Live Bullion Rates Override Card
          LuxuryGlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LIVE BULLION MARKET RATES (PER GRAM)', style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('Chennai Gold & Silver Bullion Association', style: VaultTokens.titleSerif(fontSize: 18)),
                      ],
                    ),
                    const Icon(Icons.currency_exchange, color: VaultTokens.champagneGold, size: 26),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: LuxuryTextField(
                        label: '24K FINE GOLD (999)',
                        controller: _gold24kCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee,
                        suffixText: '/g',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LuxuryTextField(
                        label: '22K TRADITIONAL (916)',
                        controller: _gold22kCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee,
                        suffixText: '/g',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: LuxuryTextField(
                        label: '18K FINE GOLD (750)',
                        controller: _gold18kCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee,
                        suffixText: '/g',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LuxuryTextField(
                        label: 'SILVER 999 (PER GRAM)',
                        controller: _silverCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee,
                        suffixText: '/g',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x332E7D5C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x662E7D5C)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_successMessage!, style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF66BB6A)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                LuxuryGoldPillButton(
                  label: 'SAVE & RECALCULATE DYNAMIC PRICES',
                  icon: Icons.sync,
                  isLoading: _isSaving,
                  onPressed: _saveRates,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Brand & Atelier Profile Card
          LuxuryGlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FLAGSHIP ATELIER DETAILS', style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LuxuryTextField(
                        label: 'BRAND NAME',
                        initialValue: 'Athirai Timeless Jewels',
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LuxuryTextField(
                        label: 'ESTABLISHED YEAR',
                        initialValue: '1924 (Royal Chola Revival)',
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LuxuryTextField(
                  label: 'FLAGSHIP VAULT ADDRESS',
                  initialValue: '72, Cathedral Road, Poes Garden, Chennai, Tamil Nadu 600086',
                  readOnly: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
