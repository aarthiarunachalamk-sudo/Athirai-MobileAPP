import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_inputs.dart';


class VaultCollectionsScreen extends StatefulWidget {
  const VaultCollectionsScreen({
    super.key,
    required this.apiService,
    required this.onOpenCollection,
  });

  final VaultApiService apiService;
  final ValueChanged<String> onOpenCollection;

  @override
  State<VaultCollectionsScreen> createState() => _VaultCollectionsScreenState();
}

class _VaultCollectionsScreenState extends State<VaultCollectionsScreen> {
  List<VaultCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    final cols = await widget.apiService.getCollections();
    if (mounted) {
      setState(() {
        _collections = cols;
        _isLoading = false;
      });
    }
  }

  void _showCreateCollectionDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF09211B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VaultTokens.borderGoldMuted),
        ),
        title: Text('Curate New Royal Collection', style: VaultTokens.titleSerif(fontSize: 22)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LuxuryTextField(label: 'COLLECTION NAME', controller: nameCtrl, hintText: 'e.g. Celestial Polki Dynasties'),
              const SizedBox(height: 16),
              LuxuryTextField(label: 'HISTORICAL INSPIRATION', controller: descCtrl, maxLines: 3, hintText: 'Describe the heritage dynasty, motifs, and era...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: VaultTokens.sageMuted)),
          ),
          LuxuryGoldPillButton(
            label: 'CREATE COLLECTION',
            height: 40,
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await widget.apiService.createCollection(nameCtrl.text.trim(), descCtrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  _loadCollections();
                }

              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURATED DYNASTIES & LINEAGES', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
                  const SizedBox(height: 4),
                  Text('Heritage Jewellery Collections', style: VaultTokens.headlineDisplay(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text('Curated groupings representing distinct eras of South Indian royal architecture and goldsmithing.', style: VaultTokens.bodyText(fontSize: 13)),
                ],
              ),
              LuxuryGoldPillButton(
                label: '+ NEW COLLECTION',
                icon: Icons.add,
                onPressed: _showCreateCollectionDialog,
              ),
            ],
          ),
          const SizedBox(height: 28),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator(color: VaultTokens.champagneGold)))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cross = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _collections.length,
                  itemBuilder: (context, index) {
                    final col = _collections[index];
                    return LuxuryGlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 20,
                      enableHoverEffect: true,
                      onTap: () => widget.onOpenCollection(col.name),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.asset(
                                    col.coverImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF092620),
                                      child: const Icon(Icons.temple_hindu, color: VaultTokens.antiqueGold, size: 48),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: VaultTokens.borderGoldMuted),
                                    ),
                                    child: Text(
                                      '${col.productCount} MASTERPIECES',
                                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(col.name, style: VaultTokens.titleSerif(fontSize: 20)),
                                      const SizedBox(height: 6),
                                      Text(
                                        col.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: VaultTokens.bodyText(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Explore Pieces →', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: VaultTokens.champagneGold)),
                                      const Icon(Icons.arrow_forward_ios, size: 12, color: VaultTokens.champagneGold),
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
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
