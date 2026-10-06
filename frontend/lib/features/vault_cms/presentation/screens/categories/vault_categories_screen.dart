import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';


class VaultCategoriesScreen extends StatelessWidget {
  const VaultCategoriesScreen({
    super.key,
    required this.onSelectCategory,
  });

  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Necklaces', 'count': '14 Masterpieces', 'img': 'assets/images/athirai_pedestal_necklace.jpg', 'desc': 'Temple nakshi, choker collars, and imperial haars.'},
      {'name': 'Rings', 'count': '8 Masterpieces', 'img': 'assets/images/shop_ring.png', 'desc': 'Kinetic blooming lotus rings & navratna cocktail bands.'},
      {'name': 'Bangles', 'count': '9 Masterpieces', 'img': 'assets/images/shop_bangle.png', 'desc': 'Peacock finial screw kadas and carved temple valayals.'},
      {'name': 'Earrings', 'count': '11 Masterpieces', 'img': 'assets/images/shop_earrings.png', 'desc': 'Cascading polki chandbalis and jhumkas with pearl drops.'},
      {'name': 'Bridal Sets', 'count': '6 Full Suites', 'img': 'assets/images/heritage_necklace.png', 'desc': '108 Lakshmi coin kasu malas and royal bridal trousseaus.'},
      {'name': 'Gold Coins', 'count': '4 Denominations', 'img': 'assets/images/shop_gold_coins.png', 'desc': '24K 999 investment bullion minted with divine Lakshmi seal.'},
      {'name': 'Silver Coins', 'count': '3 Denominations', 'img': 'assets/images/shop_silver_coins.png', 'desc': '999 fine silver coins for auspicious rituals and blessings.'},
      {'name': 'Chokers', 'count': '5 Masterpieces', 'img': 'assets/images/athirai_hero_sphere_necklace.jpg', 'desc': 'Imperial royal chokers with Polki diamonds and ruby pendants.'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPLORE BY ORNAMENT TYPE', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2)),
          const SizedBox(height: 4),
          Text('Jewellery Categories', style: VaultTokens.headlineDisplay(fontSize: 28)),
          const SizedBox(height: 4),
          Text('Browse through traditional categories crafted with timeless devotion.', style: VaultTokens.bodyText(fontSize: 13)),
          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.82,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return LuxuryGlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 20,
                    enableHoverEffect: true,
                    onTap: () => onSelectCategory(cat['name']!),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.asset(
                                  cat['img']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF092620),
                                    child: const Icon(Icons.diamond, color: VaultTokens.antiqueGold, size: 40),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cat['name']!, style: VaultTokens.titleSerif(fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(cat['count']!, style: GoogleFonts.inter(fontSize: 11, color: VaultTokens.champagneGold, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat['desc']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: VaultTokens.bodyText(fontSize: 11),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('View Ornaments →', style: GoogleFonts.inter(fontSize: 11.5, color: VaultTokens.champagneGold, fontWeight: FontWeight.w600)),
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
