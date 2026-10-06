import '../domain/models/jewellery_item.dart';

class JewelleryData {
  static List<JewelleryItem> getItemsForScene(String sceneId) {
    switch (sceneId) {
      case 'temple_heritage':
        return const [
          JewelleryItem(
            id: 'th-1',
            name: 'Kundan Lakshmi Antique Choker',
            category: 'Necklace',
            purity: '22K',
            weightGrams: 58.4,
            priceFormatted: '₹4,38,000',
            description: 'Intricately handcrafted 22K antique gold choker featuring Goddess Lakshmi motifs, Burmese rubies, and emerald drops.',
            posX: -3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'th-2',
            name: 'Sacred Temple Jhumkas',
            category: 'Earrings',
            purity: '22K',
            weightGrams: 24.6,
            priceFormatted: '₹1,84,500',
            description: 'Traditional temple dome jhumkas adorned with natural pearls and delicate gold cluster bells.',
            posX: 3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'th-3',
            name: 'Gajraj Heritage Kada',
            category: 'Bangle',
            purity: '22K',
            weightGrams: 42.0,
            priceFormatted: '₹3,15,000',
            description: 'Embossed elephant finials with intricate Nakshi carving and screw-lock mechanism.',
            posX: 0.0,
            posZ: -5.5,
          ),
        ];

      case 'diamond_palace':
        return const [
          JewelleryItem(
            id: 'dp-1',
            name: 'Astral Solitaire Diamond Ring',
            category: 'Ring',
            purity: '18K',
            weightGrams: 6.8,
            priceFormatted: '₹2,75,000',
            description: '2.5 carat VVS1 clarity oval brilliant diamond set in a luminous platinum-gold micro-pavé band.',
            posX: -3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'dp-2',
            name: 'L’Éclat Diamond Cascading Collier',
            category: 'Necklace',
            purity: '18K',
            weightGrams: 36.2,
            priceFormatted: '₹7,90,000',
            description: 'Cascading tiers of pear and marquise cut diamonds inspired by constellations.',
            posX: 3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'dp-3',
            name: 'Celestial Diamond Tennis Bracelet',
            category: 'Bracelet',
            purity: '18K',
            weightGrams: 18.5,
            priceFormatted: '₹3,40,000',
            description: 'Round brilliant cut diamonds seamlessly set in handcrafted 18K white gold links.',
            posX: 0.0,
            posZ: -5.5,
          ),
        ];

      case 'nature_gold':
        return const [
          JewelleryItem(
            id: 'ng-1',
            name: 'Verdant Flora Emerald Pendant',
            category: 'Pendant',
            purity: '22K',
            weightGrams: 14.2,
            priceFormatted: '₹1,62,000',
            description: 'Deep Zambian emerald centerpiece enclosed within organic 22K gold vine filigree.',
            posX: -3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'ng-2',
            name: 'Lotus Blossom Gold Bangle',
            category: 'Bangle',
            purity: '22K',
            weightGrams: 31.0,
            priceFormatted: '₹2,32,500',
            description: 'Petals of blooming lotus sculpted in matte 22K yellow gold with uncut polki accents.',
            posX: 3.5,
            posZ: -3.0,
          ),
        ];

      case 'royal_galaxy':
      default:
        return const [
          JewelleryItem(
            id: 'rg-1',
            name: 'Athirai Cosmic Temple Necklace',
            category: 'Necklace',
            purity: '22K',
            weightGrams: 48.5,
            priceFormatted: '₹3,65,000',
            description: 'Signature Athirai royal choker merging classical temple gold craftsmanship with cosmic starlight halos.',
            posX: -3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'rg-2',
            name: 'Orion Golden Orbit Ring',
            category: 'Ring',
            purity: '22K',
            weightGrams: 8.2,
            priceFormatted: '₹78,000',
            description: 'Spiraling 22K gold orbit bands holding an uncut Polki diamond center.',
            posX: 3.5,
            posZ: -3.0,
          ),
          JewelleryItem(
            id: 'rg-3',
            name: 'Imperial Dynastic Gold Chain',
            category: 'Chain',
            purity: '22K',
            weightGrams: 32.0,
            priceFormatted: '₹2,40,000',
            description: 'Double-woven royal Figaro links with satin gold finish and hand-engraved Athirai emblem.',
            posX: 0.0,
            posZ: -5.5,
          ),
        ];
    }
  }
}
