class JewelleryItem {
  final String id;
  final String name;
  final String category; // Necklace, Ring, Bracelet, Bangle, Earrings, Pendant, Chain
  final String purity; // 22K, 18K, 24K
  final double weightGrams;
  final String priceFormatted;
  final String description;
  final double posX;
  final double posZ;
  final String assetPreview;

  const JewelleryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.purity,
    required this.weightGrams,
    required this.priceFormatted,
    required this.description,
    required this.posX,
    required this.posZ,
    this.assetPreview = '',
  });
}
