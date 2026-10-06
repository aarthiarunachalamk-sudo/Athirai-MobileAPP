class Showroom {
  final String id;
  final String name;
  final String previewImage;
  final String sceneId;
  final String description;
  final String subtitle;
  final String atmosphere;

  const Showroom({
    required this.id,
    required this.name,
    required this.previewImage,
    required this.sceneId,
    this.description = '',
    this.subtitle = 'Exclusive High Jewelry Salon',
    this.atmosphere = 'Cosmic Luxury',
  });
}
