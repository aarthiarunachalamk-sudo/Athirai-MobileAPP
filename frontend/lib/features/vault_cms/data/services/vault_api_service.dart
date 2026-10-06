import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/vault_models.dart';

class VaultApiService {
  VaultApiService({String? baseUrl})
      : baseUrl = baseUrl ?? (kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api');

  final String baseUrl;

  // In-memory cache & fallback dataset
  final List<VaultProduct> _localProducts = [
    const VaultProduct(
      id: 1,
      name: 'Temple Blossom Necklace',
      category: 'Necklace',
      collection: 'Chola Dynasty',
      sku: 'ATH-NECK-001',
      metal: 'Gold',
      purity: '22K',
      weightGrams: 42.5,
      makingChargePercent: 12.0,
      stonePrice: 48000,
      gemstones: 'Burmese Rubies, Zambian Emeralds & Basra Pearls',
      gemstoneType: 'Natural Unheated Gems',
      gemstoneWeight: '8.40 Carats',
      diamondCarat: '1.20 ct Polki Uncut Diamonds',
      certification: 'IGI Certified Heritage Grade A+',
      hallmark: 'BIS 916 Hallmarked Pure 22 Karat Gold',
      craftsmanship: 'Handcrafted Chola Nakshi & Jadau filigree',
      origin: 'Thanjavur, Tamil Nadu Heritage Atelier',
      designer: 'Master Artisan K. Ramanathan',
      craftingTime: '120 Hours of Master Goldsmithing',
      stockQuantity: 5,
      lowStockThreshold: 2,
      warehouse: 'Chennai Flagship Jewel Vault',
      status: 'Published',
      availability: 'Ready to Ship',
      shortDescription: 'Intricate temple necklace sculpted with divine floral motifs.',
      description: 'Handcrafted by 4th-generation Thanjavur goldsmiths, this museum-grade jewel features temple floral motifs set with natural Burmese rubies and uncut Polki diamonds.',
      imageUrl: 'assets/images/athirai_pedestal_necklace.jpg',
      lifestyleImageUrl: 'assets/images/athirai_front_model.jpg',
      isFeatured: true,
      calculatedTotalPrice: 365000,
      calculatedMetalCost: 316625,
      calculatedMakingCharges: 37995,
      calculatedGst: 10638,
    ),
    const VaultProduct(
      id: 2,
      name: 'Chola Dynasty Choker',
      category: 'Necklace',
      collection: 'Chola Dynasty',
      sku: 'ATH-CHOK-002',
      metal: 'Gold',
      purity: '22K',
      weightGrams: 58.0,
      makingChargePercent: 14.0,
      stonePrice: 62000,
      gemstones: 'Cabochon Rubies & Uncut Polki Diamonds',
      gemstoneType: 'Royal Heritage Polki',
      gemstoneWeight: '12.5 Carats',
      diamondCarat: '2.50 ct Polki Diamonds',
      certification: 'GIA & IGI Verified',
      hallmark: 'BIS 916 Hallmarked Pure 22 Karat Gold',
      craftsmanship: 'Ancient Repoussé & Champlevé Enamel',
      origin: 'Kumbakonam, Tamil Nadu',
      designer: 'S. Mahadevan Master Goldsmith',
      craftingTime: '160 Hours of Master Craftsmanship',
      stockQuantity: 2,
      lowStockThreshold: 3,
      warehouse: 'Chennai Flagship Jewel Vault',
      status: 'Published',
      availability: 'Low Stock Alert',
      shortDescription: 'Imperial choker worn by ancient South Indian royal dynasties.',
      description: 'An imperial masterpiece featuring heavy repoussé gold relief work with temple deities and cabochon emeralds.',
      imageUrl: 'assets/images/athirai_hero_sphere_necklace.jpg',
      lifestyleImageUrl: 'assets/images/athirai_front_model.jpg',
      isFeatured: true,
      calculatedTotalPrice: 495000,
      calculatedMetalCost: 432100,
      calculatedMakingCharges: 60494,
      calculatedGst: 14777,
    ),
    const VaultProduct(
      id: 3,
      name: 'Lotus Grace Ring',
      category: 'Rings',
      collection: 'Temple Blossoms',
      sku: 'ATH-RING-003',
      metal: 'Gold',
      purity: '22K',
      weightGrams: 14.2,
      makingChargePercent: 10.0,
      stonePrice: 22000,
      gemstones: 'Pigeon Blood Ruby Centerpiece',
      gemstoneType: 'Burmese Ruby',
      gemstoneWeight: '2.10 Carats',
      diamondCarat: '0.45 ct Brilliant Diamonds',
      certification: 'SGL Certified',
      hallmark: 'BIS 916 Hallmarked',
      craftsmanship: 'Bloom Openable Petals Mechanism',
      origin: 'Madurai, Tamil Nadu',
      designer: 'Aruna Sundaram',
      craftingTime: '45 Hours',
      stockQuantity: 12,
      lowStockThreshold: 4,
      warehouse: 'Bangalore Luxury Vault',
      status: 'Published',
      availability: 'Ready to Ship',
      shortDescription: 'Sacred blooming lotus cocktail ring with movable petals.',
      description: 'Sculpted with kinetic micro-mechanics allowing the golden lotus petals to open gently around a glowing Burmese ruby.',
      imageUrl: 'assets/images/shop_ring.png',
      lifestyleImageUrl: 'assets/images/athirai_royal_model_girl.png',
      isFeatured: true,
      calculatedTotalPrice: 138000,
      calculatedMetalCost: 105790,
      calculatedMakingCharges: 10579,
      calculatedGst: 4140,
    ),
    const VaultProduct(
      id: 4,
      name: 'Royal Mayura Bangles',
      category: 'Bangles',
      collection: 'Navratna Heritage',
      sku: 'ATH-BANG-004',
      metal: 'Gold',
      purity: '22K',
      weightGrams: 64.0,
      makingChargePercent: 11.5,
      stonePrice: 38000,
      gemstones: 'Navratna Nine Sacred Gemstones',
      gemstoneType: 'Navratna Astrology Gems',
      gemstoneWeight: '6.80 Carats',
      diamondCarat: '0.90 ct Diamonds',
      certification: 'BIS 916 & Gemological Institute',
      hallmark: 'BIS 916 Hallmarked',
      craftsmanship: 'Peacock Finial Filigree Kada',
      origin: 'Coimbatore, Tamil Nadu',
      designer: 'K. Rajavelu',
      craftingTime: '90 Hours',
      stockQuantity: 4,
      lowStockThreshold: 2,
      warehouse: 'Chennai Flagship Jewel Vault',
      status: 'Published',
      availability: 'Ready to Ship',
      shortDescription: 'Pair of royal peacock head screw kadas with Navratna gems.',
      description: 'Twin royal peacock heads meet in sculpted gold splendor, adorned with cosmic planetary gems for prosperity and protection.',
      imageUrl: 'assets/images/shop_bangle.png',
      lifestyleImageUrl: 'assets/images/athirai_front_model.jpg',
      isFeatured: false,
      calculatedTotalPrice: 520000,
      calculatedMetalCost: 476800,
      calculatedMakingCharges: 54832,
      calculatedGst: 15948,
    ),
    const VaultProduct(
      id: 5,
      name: 'Celestial Chandbali Earrings',
      category: 'Earrings',
      collection: 'Celestial Polki',
      sku: 'ATH-EAR-005',
      metal: 'Gold',
      purity: '22K',
      weightGrams: 28.5,
      makingChargePercent: 13.0,
      stonePrice: 34000,
      gemstones: 'South Sea Pearls & Polki Diamonds',
      gemstoneType: 'Natural Basra Pearl Drop',
      gemstoneWeight: '4.20 Carats',
      diamondCarat: '1.40 ct Polki',
      certification: 'IGI Heritage Certified',
      hallmark: 'BIS 916 Hallmarked',
      craftsmanship: 'Crescent Moon Filigree with Pearl Drops',
      origin: 'Hyderabad Atelier',
      designer: 'V. Sundaresan',
      craftingTime: '65 Hours',
      stockQuantity: 7,
      lowStockThreshold: 3,
      warehouse: 'Hyderabad Heritage Vault',
      status: 'Published',
      availability: 'Ready to Ship',
      shortDescription: 'Crescent moon chandelier earrings dancing with seed pearls.',
      description: 'Cascading crescent tiers crowned by glowing Polki diamonds and suspended seed pearls that sway with royal poise.',
      imageUrl: 'assets/images/shop_earrings.png',
      lifestyleImageUrl: 'assets/images/athirai_royal_model_girl.png',
      isFeatured: true,
      calculatedTotalPrice: 258000,
      calculatedMetalCost: 212325,
      calculatedMakingCharges: 27602,
      calculatedGst: 7740,
    ),
    const VaultProduct(
      id: 6,
      name: 'Bridal Kasu Mala Imperial',
      category: 'Bridal Sets',
      collection: 'Bridal Elegance',
      sku: 'ATH-BRID-006',
      metal: 'Gold',
      purity: '22K',
      weightGrams: 85.0,
      makingChargePercent: 12.0,
      stonePrice: 42000,
      gemstones: 'Goddess Lakshmi Coins with Emerald Accents',
      gemstoneType: 'Sacred Deity Coins',
      gemstoneWeight: '5.50 Carats',
      diamondCarat: '0.80 ct Accents',
      certification: 'BIS 916 Hallmarked Pure 22K',
      hallmark: 'BIS 916 Hallmarked',
      craftsmanship: 'Traditional 108 Sacred Kasu Assembly',
      origin: 'Tirunelveli Heritage Workshop',
      designer: 'R. Chelladurai',
      craftingTime: '180 Hours',
      stockQuantity: 1,
      lowStockThreshold: 2,
      warehouse: 'Chennai Flagship Jewel Vault',
      status: 'Draft',
      availability: 'Crafting in Atelier',
      shortDescription: '108 Lakshmi coin bridal necklace invoking endless prosperity.',
      description: 'The crowning jewel of the South Indian royal wedding trousseau, meticulously hand-threaded with 108 embossed gold coins.',
      imageUrl: 'assets/images/heritage_necklace.png',
      lifestyleImageUrl: 'assets/images/athirai_front_model.jpg',
      isFeatured: false,
      calculatedTotalPrice: 710000,
      calculatedMetalCost: 633250,
      calculatedMakingCharges: 75990,
      calculatedGst: 21300,
    ),
  ];

  final List<VaultCollection> _localCollections = [
    const VaultCollection(
      id: 1,
      name: 'Chola Dynasty',
      slug: 'chola-dynasty',
      description: 'Imperial grandeur inspired by the temple architecture and royal courts of Thanjavur.',
      coverImageUrl: 'assets/images/heritage_home.png',
      productCount: 14,
    ),
    const VaultCollection(
      id: 2,
      name: 'Temple Blossoms',
      slug: 'temple-blossoms',
      description: 'Sacred floral and kinetic motifs capturing sacred lotus blossoms and jasmine garlands.',
      coverImageUrl: 'assets/images/athirai_pedestal_necklace.jpg',
      productCount: 9,
    ),
    const VaultCollection(
      id: 3,
      name: 'Navratna Heritage',
      slug: 'navratna-heritage',
      description: 'Harmonious cosmic protection through the nine royal celestial planetary gemstones.',
      coverImageUrl: 'assets/images/shop_bangle.png',
      productCount: 8,
    ),
    const VaultCollection(
      id: 4,
      name: 'Bridal Elegance',
      slug: 'bridal-elegance',
      description: 'Museum-quality royal wedding jewels passed through sacred South Indian generations.',
      coverImageUrl: 'assets/images/athirai_front_model.jpg',
      productCount: 16,
    ),
    const VaultCollection(
      id: 5,
      name: 'Celestial Polki',
      slug: 'celestial-polki',
      description: 'Uncut diamond polki constellations reflecting starlight against pure 22K gold.',
      coverImageUrl: 'assets/images/athirai_hero_sphere_necklace.jpg',
      productCount: 11,
    ),
  ];

  final List<VaultOrder> _localOrders = [
    const VaultOrder(
      id: 1,
      orderId: 'ORD-2026-8841',
      customerName: 'Princess Gayatri Devi',
      customerEmail: 'gayatri.devi@royalpalace.in',
      customerPhone: '+91 98401 22890',
      productName: 'Temple Blossom Necklace',
      totalAmount: 365000,
      paymentMethod: 'Vault Gold Pay / Wire',
      status: 'Confirmed',
      createdAt: 'Today, 11:20 AM',
    ),
    const VaultOrder(
      id: 2,
      orderId: 'ORD-2026-8840',
      customerName: 'Ananya Sharma',
      customerEmail: 'ananya.sharma@athirai.com',
      customerPhone: '+91 98765 43210',
      productName: 'Chola Dynasty Choker',
      totalAmount: 495000,
      paymentMethod: 'UPI Luxury Secure',
      status: 'Crafting',
      createdAt: 'Yesterday, 4:45 PM',
    ),
    const VaultOrder(
      id: 3,
      orderId: 'ORD-2026-8839',
      customerName: 'Vikramaditya Rao',
      customerEmail: 'v.rao@heritageholdings.com',
      customerPhone: '+91 99882 11003',
      productName: 'Royal Mayura Bangles',
      totalAmount: 520000,
      paymentMethod: 'Corporate Escrow',
      status: 'Hallmarking',
      createdAt: '04 Oct 2026',
    ),
    const VaultOrder(
      id: 4,
      orderId: 'ORD-2026-8838',
      customerName: 'Dr. Meenakshi Sundaram',
      customerEmail: 'meenakshi@apollojewel.org',
      customerPhone: '+91 97100 44552',
      productName: 'Lotus Grace Ring',
      totalAmount: 138000,
      paymentMethod: 'Amex Centurion',
      status: 'Delivered',
      createdAt: '02 Oct 2026',
    ),
  ];

  final List<VaultCustomer> _localCustomers = [
    const VaultCustomer(
      id: 1,
      name: 'Princess Gayatri Devi',
      email: 'gayatri.devi@royalpalace.in',
      phone: '+91 98401 22890',
      tier: 'Royal Patron',
      totalSpend: 3850000,
      city: 'Mysuru',
      avatarUrl: 'assets/images/athirai_profile_avatar.png',
    ),
    const VaultCustomer(
      id: 2,
      name: 'Ananya Sharma',
      email: 'ananya.sharma@athirai.com',
      phone: '+91 98765 43210',
      tier: 'Diamond Patron',
      totalSpend: 1420000,
      city: 'Chennai',
      avatarUrl: 'assets/images/athirai_user_avatar.jpg',
    ),
    const VaultCustomer(
      id: 3,
      name: 'Vikramaditya Rao',
      email: 'v.rao@heritageholdings.com',
      phone: '+91 99882 11003',
      tier: 'Royal Patron',
      totalSpend: 2950000,
      city: 'Hyderabad',
      avatarUrl: 'assets/images/athirai_profile_avatar.png',
    ),
    const VaultCustomer(
      id: 4,
      name: 'Dr. Meenakshi Sundaram',
      email: 'meenakshi@apollojewel.org',
      phone: '+91 97100 44552',
      tier: 'Gold Patron',
      totalSpend: 860000,
      city: 'Bengaluru',
      avatarUrl: 'assets/images/athirai_cinematic_avatar.png',
    ),
  ];

  final List<VaultVaultItem> _localVaultItems = [
    const VaultVaultItem(
      id: 1,
      categoryType: 'Necklace',
      title: 'Temple Blossom Necklace',
      imageUrl: 'assets/images/athirai_pedestal_necklace.jpg',
      price: 365000,
      metalPurity: '22K Gold',
      description: 'Chola Dynasty temple centerpiece sculpted with rubies.',
    ),
    const VaultVaultItem(
      id: 2,
      categoryType: 'Necklace',
      title: 'Chola Dynasty Choker',
      imageUrl: 'assets/images/athirai_hero_sphere_necklace.jpg',
      price: 495000,
      metalPurity: '22K Gold',
      description: 'Imperial royal choker with Polki uncut diamonds.',
    ),
    const VaultVaultItem(
      id: 3,
      categoryType: 'Rings',
      title: 'Lotus Grace Ring',
      imageUrl: 'assets/images/shop_ring.png',
      price: 138000,
      metalPurity: '22K Gold',
      description: 'Openable lotus petals with Burmese ruby center.',
    ),
    const VaultVaultItem(
      id: 4,
      categoryType: 'Bangles',
      title: 'Royal Mayura Bangles',
      imageUrl: 'assets/images/shop_bangle.png',
      price: 520000,
      metalPurity: '22K Gold',
      description: 'Pair of peacock finial screw kadas with Navratna stones.',
    ),
    const VaultVaultItem(
      id: 5,
      categoryType: 'Earrings',
      title: 'Celestial Chandbali',
      imageUrl: 'assets/images/shop_earrings.png',
      price: 258000,
      metalPurity: '22K Gold',
      description: 'Crescent moon chandeliers with cascading pearl drops.',
    ),
  ];

  // ── Public API Methods with Django HTTP + Local Resilience ────────────────

  Future<List<VaultProduct>> getProducts({String? category, String? collection, String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/jewels/').replace(queryParameters: {
        if (category != null && category.isNotEmpty && category != 'All') 'category': category,
        if (collection != null && collection.isNotEmpty && collection != 'All') 'collection': collection,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['jewels'] as List<dynamic>?) ?? [];
        if (list.isNotEmpty) {
          return list.map((j) => VaultProduct.fromJson(j as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Fallback seamlessly to seed items
    }

    // Local filter fallback
    return _localProducts.where((p) {
      if (category != null && category.isNotEmpty && category != 'All' && p.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (collection != null && collection.isNotEmpty && collection != 'All' && p.collection.toLowerCase() != collection.toLowerCase()) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        final match = p.name.toLowerCase().contains(query) ||
            p.sku.toLowerCase().contains(query) ||
            p.gemstones.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  Future<VaultProduct?> getProduct(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/jewels/$id/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VaultProduct.fromJson(data['jewel']);
      }
    } catch (_) {}

    return _localProducts.firstWhere((p) => p.id == id, orElse: () => _localProducts.first);
  }

  Future<VaultProduct> createProduct(VaultProduct product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jewels/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final created = VaultProduct.fromJson(data['jewel']);
        _localProducts.insert(0, created);
        return created;
      }
    } catch (_) {}

    final newProduct = product.copyWith(id: _localProducts.length + 1);
    _localProducts.insert(0, newProduct);
    return newProduct;
  }

  Future<VaultProduct> updateProduct(VaultProduct product) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/jewels/${product.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updated = VaultProduct.fromJson(data['jewel']);
        final index = _localProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) _localProducts[index] = updated;
        return updated;
      }
    } catch (_) {}

    final index = _localProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) _localProducts[index] = product;
    return product;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/jewels/$id/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        _localProducts.removeWhere((p) => p.id == id);
        return true;
      }
    } catch (_) {}

    _localProducts.removeWhere((p) => p.id == id);
    return true;
  }

  Future<List<VaultCollection>> getCollections() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/collections/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['collections'] as List<dynamic>?) ?? [];
        if (list.isNotEmpty) {
          return list.map((c) => VaultCollection.fromJson(c as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    return _localCollections;
  }

  Future<VaultCollection> createCollection(String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/collections/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': description}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final col = VaultCollection.fromJson(data['collection']);
        _localCollections.add(col);
        return col;
      }
    } catch (_) {}

    final newCol = VaultCollection(
      id: _localCollections.length + 1,
      name: name,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      description: description,
    );
    _localCollections.add(newCol);
    return newCol;
  }

  Future<List<VaultOrder>> getOrders({String? status}) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/').replace(queryParameters: {
        if (status != null && status != 'All') 'status': status,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['orders'] as List<dynamic>?) ?? [];
        if (list.isNotEmpty) {
          return list.map((o) => VaultOrder.fromJson(o as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    if (status != null && status != 'All') {
      return _localOrders.where((o) => o.status.toLowerCase() == status.toLowerCase()).toList();
    }
    return _localOrders;
  }

  Future<VaultOrder> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        final res = jsonDecode(response.body);
        final order = VaultOrder.fromJson(res['order']);
        _localOrders.insert(0, order);
        return order;
      }
    } catch (_) {}

    final order = VaultOrder(
      id: _localOrders.length + 1,
      orderId: 'ORD-2026-${8842 + _localOrders.length}',
      customerName: data['customer_name']?.toString() ?? 'Ananya Sharma',
      customerEmail: data['customer_email']?.toString() ?? 'ananya.sharma@athirai.com',
      customerPhone: data['customer_phone']?.toString() ?? '+91 98765 43210',
      productName: data['product_name']?.toString() ?? 'Temple Blossom Necklace',
      totalAmount: int.tryParse(data['total_amount']?.toString() ?? '365000') ?? 365000,
    );
    _localOrders.insert(0, order);
    return order;
  }

  Future<List<VaultCustomer>> getCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['customers'] as List<dynamic>?) ?? [];
        if (list.isNotEmpty) {
          return list.map((c) => VaultCustomer.fromJson(c as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    return _localCustomers;
  }

  Future<List<VaultVaultItem>> getVaultItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vault/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['vault_items'] as List<dynamic>?) ?? [];
        if (list.isNotEmpty) {
          return list.map((v) => VaultVaultItem.fromJson(v as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    return _localVaultItems;
  }

  Future<VaultMetalRates> getMetalRates() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rates/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VaultMetalRates.fromJson(data['rates'] ?? data);
      }
    } catch (_) {}

    return const VaultMetalRates();
  }

  Future<VaultAnalyticsData> getAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/summary/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VaultAnalyticsData.fromJson(data);
      }
    } catch (_) {}

    return const VaultAnalyticsData();
  }
}
