import 'package:flutter/material.dart';

class AthiraiCollectionColumn {
  final String id;
  final String badgeLetter;
  final String title;
  final Color badgeColor;
  final String viewAllLabel;
  final List<String> items;

  const AthiraiCollectionColumn({
    required this.id,
    required this.badgeLetter,
    required this.title,
    required this.badgeColor,
    required this.viewAllLabel,
    required this.items,
  });
}

class AthiraiCollectionsCatalog {
  AthiraiCollectionsCatalog._();

  static const List<String> categoryTabs = [
    'ALL JEWELLERY',
    'GOLD',
    'SILVER',
    'COINS',
    'OFFERS',
    'TEAM369-LIVE',
    'WEDDING',
    'GIFTING',
    'NEARBY SHOP',
  ];

  static const List<AthiraiCollectionColumn> columns = [
    // 1. Gold Jewellery
    AthiraiCollectionColumn(
      id: 'gold',
      badgeLetter: 'G',
      title: 'Gold Jewellery',
      badgeColor: Color(0xFFD4AF37),
      viewAllLabel: 'View All Gold →',
      items: [
        'Gold Rings',
        'Gold Bangles',
        'Gold Bracelets',
        'Gold Earrings',
        'Gold Pendants',
        'Gold Chains',
        'Gold Necklaces',
        'Gold Mangalsutra',
        'Gold Anklets',
        'Gold Maang Tikka',
        'Gold Kada',
        'Gold Nose Pins',
        'Gold Tie Pins',
        'Gold Ear Chains',
        'Gold Toe Rings',
        'Gold Armlets',
      ],
    ),

    // 2. Silver Jewellery
    AthiraiCollectionColumn(
      id: 'silver',
      badgeLetter: 'S',
      title: 'Silver Jewellery',
      badgeColor: Color(0xFFC7D3D0),
      viewAllLabel: 'View All Silver →',
      items: [
        'Silver Anklets',
        'Silver Rings',
        'Silver Earrings',
        'Silver Bracelets',
        'Silver Bangles',
        'Silver Pendants',
        'Silver Chains',
        'Silver Necklaces',
        'Silver Toe Rings',
        'Silver Nose Pins',
        'Silver Articles',
        'Silver Coins & Items',
      ],
    ),

    // 3. Coins & Bars
    AthiraiCollectionColumn(
      id: 'coins',
      badgeLetter: 'C',
      title: 'Coins & Bars',
      badgeColor: Color(0xFFFFDF7A),
      viewAllLabel: 'View All Coins →',
      items: [
        'Gold Coins',
        'Silver Coins',
        'Gold Bars',
        'Silver Bars',
        'Collectible Coins',
        'Gift Coins',
        'Temple Coins',
      ],
    ),

    // 4. Daily Wear
    AthiraiCollectionColumn(
      id: 'daily_wear',
      badgeLetter: 'D',
      title: 'Daily Wear',
      badgeColor: Color(0xFF81C784),
      viewAllLabel: 'View All Daily Wear →',
      items: [
        'Daily Wear Rings',
        'Daily Wear Earrings',
        'Daily Wear Pendants',
        'Daily Wear Chains',
        'Light Weight Jewellery',
        'Minimal Collection',
      ],
    ),

    // 5. Wedding Jewellery
    AthiraiCollectionColumn(
      id: 'wedding',
      badgeLetter: 'W',
      title: 'Wedding Jewellery',
      badgeColor: Color(0xFFFFB74D),
      viewAllLabel: 'View All Wedding →',
      items: [
        'Bridal Sets',
        'Temple Jewellery',
        'Kundan Jewellery',
        'Polki Jewellery',
        'Antique Jewellery',
        'Wedding Bangles',
      ],
    ),

    // 6. Gifting Collection
    AthiraiCollectionColumn(
      id: 'gifting',
      badgeLetter: 'G',
      title: 'Gifting Collection',
      badgeColor: Color(0xFFBA68C8),
      viewAllLabel: 'View All Gifting →',
      items: [
        'Gift For Her',
        'Gift For Him',
        'Kids Jewellery',
        'Corporate Gifts',
        'Anniversary Gifts',
        'Birthday Gifts',
      ],
    ),

    // 7. Mangalsutra
    AthiraiCollectionColumn(
      id: 'mangalsutra',
      badgeLetter: 'M',
      title: 'Mangalsutra',
      badgeColor: Color(0xFFFF8A65),
      viewAllLabel: 'View All Mangalsutra →',
      items: [
        'Traditional Mangalsutra',
        'Beaded Mangalsutra',
        'Short Mangalsutra',
        'Gold Mangalsutra',
        'Black Bead Mangalsutra',
      ],
    ),

    // 8. Other Jewellery
    AthiraiCollectionColumn(
      id: 'other',
      badgeLetter: 'O',
      title: 'Other Jewellery',
      badgeColor: Color(0xFF4DD0E1),
      viewAllLabel: 'View All Other →',
      items: [
        'Nose Pins',
        'Anklets',
        'Toe Rings',
        'Cufflinks',
        'Brooches',
        'Tie Pins',
      ],
    ),
  ];
}
