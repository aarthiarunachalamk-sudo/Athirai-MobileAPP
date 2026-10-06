import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';


class JewelVaultConstellationScreen extends StatefulWidget {
  const JewelVaultConstellationScreen({
    super.key,
    required this.apiService,
    required this.onSelectProduct,
  });

  final VaultApiService apiService;
  final ValueChanged<VaultProduct> onSelectProduct;

  @override
  State<JewelVaultConstellationScreen> createState() => _JewelVaultConstellationScreenState();
}

class _JewelVaultConstellationScreenState extends State<JewelVaultConstellationScreen> {
  List<VaultVaultItem> _vaultItems = [];
  bool _isLoading = true;
  int _activeNodeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVault();
  }

  Future<void> _loadVault() async {
    setState(() => _isLoading = true);
    final items = await widget.apiService.getVaultItems();
    if (mounted) {
      setState(() {
        _vaultItems = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: VaultTokens.champagneGold));
    }

    final activeItem = _vaultItems.isNotEmpty ? _vaultItems[_activeNodeIndex % _vaultItems.length] : null;

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
                  Text('COSMIC ORBITAL CURATION', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
                  const SizedBox(height: 4),
                  Text('Your Constellation Jewel Vault', style: VaultTokens.headlineDisplay(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text('Harmonious pairing of bridal & heritage suites organized in celestial symmetry.', style: VaultTokens.bodyText(fontSize: 13)),
                ],
              ),
              LuxuryGoldPillButton(
                label: 'BOOK ATELIER STYLIST',
                icon: Icons.calendar_today_outlined,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Constellation Arena
          Container(
            height: 520,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 0.95,
                colors: [
                  Color(0xFF0B2E26),
                  Color(0xFF04120E),
                  Color(0xFF020705),
                ],
              ),
              border: Border.all(color: VaultTokens.borderGoldMuted, width: 1.2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric Gold Orbital Rings Custom Painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConstellationOrbitalPainter(
                      activeAngle: (_activeNodeIndex * (2 * math.pi / math.max(1, _vaultItems.length))),
                    ),
                  ),
                ),

                // Central Avatar / Mannequin
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: VaultTokens.champagneGold.withOpacity(0.35),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                    border: Border.all(color: VaultTokens.borderGoldBright, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/athirai_vault_mannequin.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/athirai_front_model.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF08261F),
                          child: const Icon(Icons.person, color: VaultTokens.antiqueGold, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),

                // Orbital Node Buttons
                ...List.generate(_vaultItems.length, (idx) {
                  final total = _vaultItems.length;
                  final angle = (idx * 2 * math.pi / total) - (math.pi / 2);
                  const radius = 180.0;
                  final dx = radius * math.cos(angle);
                  final dy = radius * math.sin(angle);
                  final isSel = idx == _activeNodeIndex;
                  final item = _vaultItems[idx];

                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeNodeIndex = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSel ? 68 : 52,
                        height: isSel ? 68 : 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF04120E),
                          border: Border.all(
                            color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted,
                            width: isSel ? 2.2 : 1.0,
                          ),
                          boxShadow: [
                            if (isSel)
                              BoxShadow(
                                color: VaultTokens.champagneGold.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.diamond,
                              color: VaultTokens.champagneGold,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Active Node Floating Glass Information Panel
                if (activeItem != null)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: LuxuryGlassCard(
                        padding: const EdgeInsets.all(18),
                        borderRadius: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  activeItem.categoryType.toUpperCase(),
                                  style: VaultTokens.brandLabel(fontSize: 9.5),
                                ),
                                Text(
                                  activeItem.metalPurity,
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeItem.title,
                              style: VaultTokens.titleSerif(fontSize: 17),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeItem.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: VaultTokens.bodyText(fontSize: 11.5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${(activeItem.price / 100000).toStringAsFixed(2)} Lakhs',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: VaultTokens.champagneGold),
                                ),
                                LuxuryGoldPillButton(
                                  label: 'VIEW',
                                  height: 32,
                                  fontSize: 11,
                                  onPressed: () {
                                    widget.onSelectProduct(VaultProduct(
                                      id: activeItem.id,
                                      name: activeItem.title,
                                      category: activeItem.categoryType,
                                      imageUrl: activeItem.imageUrl,
                                      calculatedTotalPrice: activeItem.price,
                                    ));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _ConstellationOrbitalPainter extends CustomPainter {
  final double activeAngle;

  _ConstellationOrbitalPainter({required this.activeAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final orbitPaint = Paint()
      ..color = VaultTokens.antiqueGold.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric rings
    canvas.drawCircle(center, 120, orbitPaint);
    canvas.drawCircle(center, 180, orbitPaint);
    canvas.drawCircle(center, 230, orbitPaint);

    // Glowing connection line to active node
    const radius = 180.0;
    final nodeX = center.dx + radius * math.cos(activeAngle - math.pi / 2);
    final nodeY = center.dy + radius * math.sin(activeAngle - math.pi / 2);

    final beamPaint = Paint()
      ..color = VaultTokens.champagneGold.withOpacity(0.4)
      ..strokeWidth = 1.6;

    canvas.drawLine(center, Offset(nodeX, nodeY), beamPaint);
  }

  @override
  bool shouldRepaint(covariant _ConstellationOrbitalPainter oldDelegate) =>
      oldDelegate.activeAngle != activeAngle;
}
