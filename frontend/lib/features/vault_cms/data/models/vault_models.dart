class VaultProduct {
  final int id;
  final String name;
  final String category;
  final String collection;
  final String sku;
  final String metal;
  final String purity;
  final double weightGrams;
  final double makingChargePercent;
  final int stonePrice;
  final String gemstones;
  final String gemstoneType;
  final String gemstoneWeight;
  final String diamondCarat;
  final String certification;
  final String hallmark;
  final String craftsmanship;
  final String origin;
  final String designer;
  final String craftingTime;
  final int stockQuantity;
  final int lowStockThreshold;
  final String warehouse;
  final String status;
  final String availability;
  final String seoTitle;
  final String metaDescription;
  final String urlSlug;
  final String tags;
  final String shortDescription;
  final String description;
  final String imageUrl;
  final String lifestyleImageUrl;
  final bool isFeatured;
  final int? basePriceOverride;
  final int calculatedTotalPrice;
  final int calculatedMetalCost;
  final int calculatedMakingCharges;
  final int calculatedGst;

  const VaultProduct({
    required this.id,
    required this.name,
    required this.category,
    this.collection = '',
    this.sku = '',
    this.metal = 'Gold',
    this.purity = '22K',
    this.weightGrams = 42.5,
    this.makingChargePercent = 12.0,
    this.stonePrice = 45000,
    this.gemstones = 'Burmese Rubies, Zambian Emeralds & Basra Pearls',
    this.gemstoneType = 'Natural Unheated Gems',
    this.gemstoneWeight = '8.40 Carats',
    this.diamondCarat = '1.20 ct Polki Uncut Diamonds',
    this.certification = 'IGI Certified Heritage Grade A+',
    this.hallmark = 'BIS 916 Hallmarked Pure 22 Karat Gold',
    this.craftsmanship = 'Handcrafted Chola Nakshi & Jadau filigree',
    this.origin = 'Thanjavur, Tamil Nadu Heritage Atelier',
    this.designer = 'Master Artisan K. Ramanathan',
    this.craftingTime = '120 Hours of Master Goldsmithing',
    this.stockQuantity = 5,
    this.lowStockThreshold = 2,
    this.warehouse = 'Chennai Flagship Jewel Vault',
    this.status = 'Published',
    this.availability = 'Ready to Ship',
    this.seoTitle = '',
    this.metaDescription = '',
    this.urlSlug = '',
    this.tags = 'temple, bridal, 22k gold, necklace, royal',
    this.shortDescription = 'Intricate temple necklace sculpted with divine devotion.',
    this.description = 'Handcrafted by 4th-generation Thanjavur goldsmiths, this museum-grade jewel features temple floral motifs set with natural Burmese rubies and uncut Polki diamonds.',
    this.imageUrl = 'assets/images/athirai_pedestal_necklace.jpg',
    this.lifestyleImageUrl = 'assets/images/athirai_front_model.jpg',
    this.isFeatured = true,
    this.basePriceOverride,
    this.calculatedTotalPrice = 365000,
    this.calculatedMetalCost = 280000,
    this.calculatedMakingCharges = 33600,
    this.calculatedGst = 10758,
  });

  factory VaultProduct.fromJson(Map<String, dynamic> json) {
    final breakdown = json['price_breakdown'] as Map<String, dynamic>?;

    return VaultProduct(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category'] is Map ? json['category']['name']?.toString() ?? '' : json['category']?.toString() ?? 'Necklace',
      collection: json['collection'] is Map ? json['collection']['name']?.toString() ?? '' : json['collection']?.toString() ?? 'Chola Dynasty',
      sku: json['sku']?.toString() ?? 'ATH-NECK-001',
      metal: json['metal']?.toString() ?? 'Gold',
      purity: json['purity']?.toString() ?? '22K',
      weightGrams: (json['weight_grams'] is num) ? (json['weight_grams'] as num).toDouble() : double.tryParse(json['weight_grams']?.toString() ?? '42.5') ?? 42.5,
      makingChargePercent: (json['making_charge_percent'] is num) ? (json['making_charge_percent'] as num).toDouble() : double.tryParse(json['making_charge_percent']?.toString() ?? '12.0') ?? 12.0,
      stonePrice: json['stone_price'] is int ? json['stone_price'] : int.tryParse(json['stone_price']?.toString() ?? '45000') ?? 45000,
      gemstones: json['gemstones']?.toString() ?? 'Burmese Rubies & Zambian Emeralds',
      gemstoneType: json['gemstone_type']?.toString() ?? 'Natural Unheated Gems',
      gemstoneWeight: json['gemstone_weight']?.toString() ?? '8.40 Carats',
      diamondCarat: json['diamond_carat']?.toString() ?? '1.20 ct Polki Uncut Diamonds',
      certification: json['certification']?.toString() ?? 'IGI Certified Heritage Grade A+',
      hallmark: json['hallmark']?.toString() ?? 'BIS 916 Hallmarked Pure 22 Karat Gold',
      craftsmanship: json['craftsmanship']?.toString() ?? 'Handcrafted Nakshi & Filigree',
      origin: json['origin']?.toString() ?? 'Thanjavur, Tamil Nadu',
      designer: json['designer']?.toString() ?? 'Master Artisan K. Ramanathan',
      craftingTime: json['crafting_time']?.toString() ?? '120 Hours',
      stockQuantity: json['stock_quantity'] is int ? json['stock_quantity'] : int.tryParse(json['stock_quantity']?.toString() ?? '5') ?? 5,
      lowStockThreshold: json['low_stock_threshold'] is int ? json['low_stock_threshold'] : int.tryParse(json['low_stock_threshold']?.toString() ?? '2') ?? 2,
      warehouse: json['warehouse']?.toString() ?? 'Chennai Flagship Jewel Vault',
      status: json['status']?.toString() ?? 'Published',
      availability: json['availability']?.toString() ?? 'Ready to Ship',
      seoTitle: json['seo_title']?.toString() ?? '',
      metaDescription: json['meta_description']?.toString() ?? '',
      urlSlug: json['url_slug']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: (json['image_url'] != null && json['image_url'].toString().isNotEmpty)
          ? json['image_url'].toString()
          : 'assets/images/athirai_pedestal_necklace.jpg',
      lifestyleImageUrl: (json['lifestyle_image_url'] != null && json['lifestyle_image_url'].toString().isNotEmpty)
          ? json['lifestyle_image_url'].toString()
          : 'assets/images/athirai_front_model.jpg',
      isFeatured: json['is_featured'] == true,
      basePriceOverride: json['base_price_override'] is int ? json['base_price_override'] : int.tryParse(json['base_price_override']?.toString() ?? ''),
      calculatedTotalPrice: breakdown != null && breakdown['total_price'] != null
          ? int.tryParse(breakdown['total_price'].toString()) ?? 365000
          : int.tryParse(json['total_price']?.toString() ?? '365000') ?? 365000,
      calculatedMetalCost: breakdown != null && breakdown['metal_cost'] != null
          ? int.tryParse(breakdown['metal_cost'].toString()) ?? 280000
          : 280000,
      calculatedMakingCharges: breakdown != null && breakdown['making_charges'] != null
          ? int.tryParse(breakdown['making_charges'].toString()) ?? 33600
          : 33600,
      calculatedGst: breakdown != null && breakdown['gst_amount'] != null
          ? int.tryParse(breakdown['gst_amount'].toString()) ?? 10758
          : 10758,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'collection': collection,
      'sku': sku,
      'metal': metal,
      'purity': purity,
      'weight_grams': weightGrams,
      'making_charge_percent': makingChargePercent,
      'stone_price': stonePrice,
      'gemstones': gemstones,
      'gemstone_type': gemstoneType,
      'gemstone_weight': gemstoneWeight,
      'diamond_carat': diamondCarat,
      'certification': certification,
      'hallmark': hallmark,
      'craftsmanship': craftsmanship,
      'origin': origin,
      'designer': designer,
      'crafting_time': craftingTime,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'warehouse': warehouse,
      'status': status,
      'availability': availability,
      'seo_title': seoTitle,
      'meta_description': metaDescription,
      'url_slug': urlSlug,
      'tags': tags,
      'short_description': shortDescription,
      'description': description,
      'image_url': imageUrl,
      'lifestyle_image_url': lifestyleImageUrl,
      'is_featured': isFeatured,
      if (basePriceOverride != null) 'base_price_override': basePriceOverride,
    };
  }

  VaultProduct copyWith({
    int? id,
    String? name,
    String? category,
    String? collection,
    String? sku,
    String? metal,
    String? purity,
    double? weightGrams,
    double? makingChargePercent,
    int? stonePrice,
    String? gemstones,
    String? gemstoneType,
    String? gemstoneWeight,
    String? diamondCarat,
    String? certification,
    String? hallmark,
    String? craftsmanship,
    String? origin,
    String? designer,
    String? craftingTime,
    int? stockQuantity,
    int? lowStockThreshold,
    String? warehouse,
    String? status,
    String? availability,
    String? seoTitle,
    String? metaDescription,
    String? urlSlug,
    String? tags,
    String? shortDescription,
    String? description,
    String? imageUrl,
    String? lifestyleImageUrl,
    bool? isFeatured,
    int? basePriceOverride,
    int? calculatedTotalPrice,
    int? calculatedMetalCost,
    int? calculatedMakingCharges,
    int? calculatedGst,
  }) {
    return VaultProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      collection: collection ?? this.collection,
      sku: sku ?? this.sku,
      metal: metal ?? this.metal,
      purity: purity ?? this.purity,
      weightGrams: weightGrams ?? this.weightGrams,
      makingChargePercent: makingChargePercent ?? this.makingChargePercent,
      stonePrice: stonePrice ?? this.stonePrice,
      gemstones: gemstones ?? this.gemstones,
      gemstoneType: gemstoneType ?? this.gemstoneType,
      gemstoneWeight: gemstoneWeight ?? this.gemstoneWeight,
      diamondCarat: diamondCarat ?? this.diamondCarat,
      certification: certification ?? this.certification,
      hallmark: hallmark ?? this.hallmark,
      craftsmanship: craftsmanship ?? this.craftsmanship,
      origin: origin ?? this.origin,
      designer: designer ?? this.designer,
      craftingTime: craftingTime ?? this.craftingTime,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      warehouse: warehouse ?? this.warehouse,
      status: status ?? this.status,
      availability: availability ?? this.availability,
      seoTitle: seoTitle ?? this.seoTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      urlSlug: urlSlug ?? this.urlSlug,
      tags: tags ?? this.tags,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      lifestyleImageUrl: lifestyleImageUrl ?? this.lifestyleImageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      basePriceOverride: basePriceOverride ?? this.basePriceOverride,
      calculatedTotalPrice: calculatedTotalPrice ?? this.calculatedTotalPrice,
      calculatedMetalCost: calculatedMetalCost ?? this.calculatedMetalCost,
      calculatedMakingCharges: calculatedMakingCharges ?? this.calculatedMakingCharges,
      calculatedGst: calculatedGst ?? this.calculatedGst,
    );
  }
}

class VaultCollection {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String coverImageUrl;
  final String bannerImageUrl;
  final int productCount;
  final bool isFeatured;

  const VaultCollection({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.coverImageUrl = 'assets/images/heritage_home.png',
    this.bannerImageUrl = 'assets/images/athirai_pedestal_necklace.jpg',
    this.productCount = 12,
    this.isFeatured = true,
  });

  factory VaultCollection.fromJson(Map<String, dynamic> json) {
    return VaultCollection(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImageUrl: (json['cover_image_url'] != null && json['cover_image_url'].toString().isNotEmpty)
          ? json['cover_image_url'].toString()
          : 'assets/images/heritage_home.png',
      bannerImageUrl: (json['banner_image_url'] != null && json['banner_image_url'].toString().isNotEmpty)
          ? json['banner_image_url'].toString()
          : 'assets/images/athirai_pedestal_necklace.jpg',
      productCount: json['product_count'] is int ? json['product_count'] : 12,
      isFeatured: json['is_featured'] == true,
    );
  }
}

class VaultOrder {
  final int id;
  final String orderId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String productName;
  final int totalAmount;
  final String paymentMethod;
  final String status;
  final String createdAt;

  const VaultOrder({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.productName,
    required this.totalAmount,
    this.paymentMethod = 'Vault Gold Pay',
    this.status = 'Confirmed',
    this.createdAt = 'Today, 2:30 PM',
  });

  factory VaultOrder.fromJson(Map<String, dynamic> json) {
    return VaultOrder(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['order_id']?.toString() ?? 'ORD-2026-001',
      customerName: json['customer_name']?.toString() ?? 'Ananya Sharma',
      customerEmail: json['customer_email']?.toString() ?? 'ananya.sharma@athirai.com',
      customerPhone: json['customer_phone']?.toString() ?? '+91 98765 43210',
      productName: json['product_name']?.toString() ?? 'Temple Blossom Necklace',
      totalAmount: json['total_amount'] is int ? json['total_amount'] : int.tryParse(json['total_amount']?.toString() ?? '365000') ?? 365000,
      paymentMethod: json['payment_method']?.toString() ?? 'Vault Gold Pay',
      status: json['status']?.toString() ?? 'Confirmed',
      createdAt: json['created_at']?.toString() ?? 'Today',
    );
  }
}

class VaultCustomer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String tier;
  final int totalSpend;
  final String city;
  final String avatarUrl;

  const VaultCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.tier = 'Royal Patron',
    this.totalSpend = 1420000,
    this.city = 'Chennai',
    this.avatarUrl = 'assets/images/athirai_profile_avatar.png',
  });

  factory VaultCustomer.fromJson(Map<String, dynamic> json) {
    return VaultCustomer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'Royal Patron',
      totalSpend: json['total_spend'] is int ? json['total_spend'] : int.tryParse(json['total_spend']?.toString() ?? '0') ?? 0,
      city: json['city']?.toString() ?? 'Chennai',
      avatarUrl: (json['avatar_url'] != null && json['avatar_url'].toString().isNotEmpty)
          ? json['avatar_url'].toString()
          : 'assets/images/athirai_profile_avatar.png',
    );
  }
}

class VaultVaultItem {
  final int id;
  final String categoryType;
  final String title;
  final String imageUrl;
  final int price;
  final String metalPurity;
  final String description;

  const VaultVaultItem({
    required this.id,
    required this.categoryType,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.metalPurity = '22K Gold',
    this.description = 'Heritage temple jewel',
  });

  factory VaultVaultItem.fromJson(Map<String, dynamic> json) {
    return VaultVaultItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      categoryType: json['category_type']?.toString() ?? 'Necklace',
      title: json['title']?.toString() ?? '',
      imageUrl: (json['image_url'] != null && json['image_url'].toString().isNotEmpty)
          ? json['image_url'].toString()
          : 'assets/images/athirai_pedestal_necklace.jpg',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '365000') ?? 365000,
      metalPurity: json['metal_purity']?.toString() ?? '22K Gold',
      description: json['description']?.toString() ?? '',
    );
  }
}

class VaultMetalRates {
  final int gold24k;
  final int gold22k;
  final int gold18k;
  final double silver999;
  final String updatedAt;

  const VaultMetalRates({
    this.gold24k = 7980,
    this.gold22k = 7450,
    this.gold18k = 6100,
    this.silver999 = 98.50,
    this.updatedAt = 'Live Market',
  });

  factory VaultMetalRates.fromJson(Map<String, dynamic> json) {
    return VaultMetalRates(
      gold24k: json['gold_24k'] is int ? json['gold_24k'] : int.tryParse(json['gold_24k']?.toString() ?? '7980') ?? 7980,
      gold22k: json['gold_22k'] is int ? json['gold_22k'] : int.tryParse(json['gold_22k']?.toString() ?? '7450') ?? 7450,
      gold18k: json['gold_18k'] is int ? json['gold_18k'] : int.tryParse(json['gold_18k']?.toString() ?? '6100') ?? 6100,
      silver999: (json['silver_999'] is num) ? (json['silver_999'] as num).toDouble() : double.tryParse(json['silver_999']?.toString() ?? '98.5') ?? 98.5,
      updatedAt: json['updated_at']?.toString() ?? 'Live Market',
    );
  }
}

class VaultAnalyticsData {
  final int totalProducts;
  final int publishedProducts;
  final int draftProducts;
  final int lowStock;
  final int totalCollections;
  final int totalOrders;
  final int totalRevenue;
  final String totalRevenueFormatted;
  final int totalCustomers;
  final String conversionRate;
  final String averageOrderValue;
  final List<Map<String, String>> recentActivity;

  const VaultAnalyticsData({
    this.totalProducts = 28,
    this.publishedProducts = 22,
    this.draftProducts = 6,
    this.lowStock = 3,
    this.totalCollections = 5,
    this.totalOrders = 84,
    this.totalRevenue = 4280000,
    this.totalRevenueFormatted = '₹42.8 Lakhs',
    this.totalCustomers = 1280,
    this.conversionRate = '4.8%',
    this.averageOrderValue = '₹3,45,000',
    this.recentActivity = const [],
  });

  factory VaultAnalyticsData.fromJson(Map<String, dynamic> json) {
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};
    final activity = (json['recent_activity'] as List<dynamic>?)
            ?.map((e) => Map<String, String>.from(e as Map))
            .toList() ??
        [];

    return VaultAnalyticsData(
      totalProducts: kpis['total_products'] is int ? kpis['total_products'] : 28,
      publishedProducts: kpis['published_products'] is int ? kpis['published_products'] : 22,
      draftProducts: kpis['draft_products'] is int ? kpis['draft_products'] : 6,
      lowStock: kpis['low_stock'] is int ? kpis['low_stock'] : 3,
      totalCollections: kpis['total_collections'] is int ? kpis['total_collections'] : 5,
      totalOrders: kpis['total_orders'] is int ? kpis['total_orders'] : 84,
      totalRevenue: kpis['total_revenue'] is int ? kpis['total_revenue'] : 4280000,
      totalRevenueFormatted: kpis['total_revenue_formatted']?.toString() ?? '₹42.8 Lakhs',
      totalCustomers: kpis['total_customers'] is int ? kpis['total_customers'] : 1280,
      conversionRate: kpis['conversion_rate']?.toString() ?? '4.8%',
      averageOrderValue: kpis['average_order_value']?.toString() ?? '₹3,45,000',
      recentActivity: activity,
    );
  }
}
