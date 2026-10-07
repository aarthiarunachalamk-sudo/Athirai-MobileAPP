import 'package:flutter/foundation.dart';

import '../../showroom/data/jewellery_data.dart';
import '../../showroom/domain/models/jewellery_item.dart';
import '../data/shop_api_service.dart';

String rupees(int amount) {
  final digits = amount.toString();
  if (digits.length <= 3) return '₹$digits';
  final tail = digits.substring(digits.length - 3);
  final head = digits
      .substring(0, digits.length - 3)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
        (match) => '${match[1]},',
      );
  return '₹$head,$tail';
}

/// Live Daily Metal Rates (per gram in INR)
class MetalRates {
  final int gold22k; // e.g. 7450
  final int gold24k; // e.g. 7980
  final int gold18k; // e.g. 6100
  final double silver999; // e.g. 98.50
  final DateTime lastUpdated;

  const MetalRates({
    this.gold22k = 7450,
    this.gold24k = 7980,
    this.gold18k = 6100,
    this.silver999 = 98.50,
    required this.lastUpdated,
  });

  MetalRates copyWith({
    int? gold22k,
    int? gold24k,
    int? gold18k,
    double? silver999,
    DateTime? lastUpdated,
  }) {
    return MetalRates(
      gold22k: gold22k ?? this.gold22k,
      gold24k: gold24k ?? this.gold24k,
      gold18k: gold18k ?? this.gold18k,
      silver999: silver999 ?? this.silver999,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

/// Dynamic Jewellery Category (e.g. Necklaces, Rings, Bangles, Temple, Custom)
class JewelCategory {
  final String id;
  final String name;
  final String image;
  final bool isCustom;

  const JewelCategory({
    required this.id,
    required this.name,
    required this.image,
    this.isCustom = false,
  });
}

/// Complete Dynamic Itemized Price Breakdown for any jewellery piece
class JewelPriceBreakdown {
  final String jewelId;
  final String name;
  final String category;
  final String metal;
  final String purity;
  final double weightGrams;
  final double metalRatePerGram;
  final int goldComponent;
  final double makingChargePercent;
  final int makingCharges;
  final int stonePrice;
  final int taxableAmount;
  final int gst;
  final int finalPrice;

  const JewelPriceBreakdown({
    required this.jewelId,
    required this.name,
    required this.category,
    required this.metal,
    required this.purity,
    required this.weightGrams,
    required this.metalRatePerGram,
    required this.goldComponent,
    required this.makingChargePercent,
    required this.makingCharges,
    required this.stonePrice,
    required this.taxableAmount,
    required this.gst,
    required this.finalPrice,
  });
}

class ShopProduct {
  ShopProduct(
    this.item,
    this.collection, {
    this.metal = 'Gold',
    this.makingChargePercent = 12.0,
    this.stonePrice = 0,
    this.isCustom = false,
    this.customPriceOverride,
  });

  final JewelleryItem item;
  final String collection;
  final String metal;
  final double makingChargePercent;
  final int stonePrice;
  final bool isCustom;
  final int? customPriceOverride;

  String get materialLabel => '${item.purity} ${metal.toLowerCase()}';
  String get id => item.id;
  String get name => item.name;
  String get category => item.category;
  String get purity => item.purity;
  double get weightGrams => item.weightGrams;

  /// Dynamic Price calculated in real-time using live metal rates, weight, making charges & 3% GST
  int get price {
    if (customPriceOverride != null) return customPriceOverride!;
    return calculatePrice(ShopStore.session.rates);
  }

  int calculatePrice(MetalRates rates) {
    return getBreakdown(rates).finalPrice;
  }

  JewelPriceBreakdown getBreakdown([MetalRates? customRates]) {
    final rates = customRates ?? ShopStore.session.rates;
    double ratePerGram;
    if (metal.toLowerCase() == 'silver') {
      ratePerGram = rates.silver999;
    } else {
      switch (item.purity) {
        case '24K':
          ratePerGram = rates.gold24k.toDouble();
          break;
        case '18K':
          ratePerGram = rates.gold18k.toDouble();
          break;
        case '22K':
        default:
          ratePerGram = rates.gold22k.toDouble();
          break;
      }
    }

    final goldVal = (item.weightGrams * ratePerGram).round();
    final making = (goldVal * (makingChargePercent / 100.0)).round();
    final taxable = goldVal + making + stonePrice;
    final gstVal = (taxable * 0.03).round();
    final total = taxable + gstVal;

    return JewelPriceBreakdown(
      jewelId: id,
      name: item.name,
      category: item.category,
      metal: metal,
      purity: item.purity,
      weightGrams: item.weightGrams,
      metalRatePerGram: ratePerGram,
      goldComponent: goldVal,
      makingChargePercent: makingChargePercent,
      makingCharges: making,
      stonePrice: stonePrice,
      taxableAmount: taxable,
      gst: gstVal,
      finalPrice: total > 0 ? total : 1000,
    );
  }

  String get image {
    if (item.assetPreview.isNotEmpty) return item.assetPreview;
    if (item.category.toLowerCase().contains('necklace') || item.category == 'Temple') {
      return 'assets/images/heritage_necklace.png';
    }
    if (item.category.toLowerCase().contains('coin')) {
      return metal.toLowerCase() == 'silver'
          ? 'assets/images/shop_silver_coins.png'
          : 'assets/images/shop_gold_coins.png';
    }
    final cat = switch (item.category) {
      'Pendant' => 'necklace',
      'Bracelet' => 'bangle',
      _ => item.category.toLowerCase(),
    };
    return 'assets/images/shop_$cat.png';
  }

  bool matchesSearch(String query) {
    String normalize(String text) => text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9.\s]'), ' ')
        .replaceAllMapped(RegExp(r'(\d)\s+(mg|g|k)\b'), (m) => '${m[1]}${m[2]}')
        .replaceAll(RegExp(r'\bcoins\b'), 'coin')
        .replaceAll(RegExp(r'\brings\b'), 'ring')
        .replaceAll(RegExp(r'\bnecklaces\b'), 'necklace')
        .replaceAll(RegExp(r'\bbangles\b'), 'bangle')
        .replaceAll(RegExp(r'\bchains\b'), 'chain');
    final searchable = normalize(
      '${item.name} ${item.category} $collection $metal '
      '${item.purity} ${item.description} ${item.weightGrams}g '
      '${item.weightGrams.toStringAsFixed(item.weightGrams == item.weightGrams.roundToDouble() ? 0 : 3)}g '
      '${(item.weightGrams * 1000).round()}mg',
    );
    return normalize(query)
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .every(
          (token) => RegExp(r'^\d').hasMatch(token)
              ? searchable.split(RegExp(r'\s+')).contains(token)
              : searchable.contains(token),
        );
  }
}

/// Fully Dynamic Shopping Store with Live Metal Rates, Backend Connection & Dynamic Products
class ShopStore extends ChangeNotifier {
  static final session = ShopStore();

  final ShopApiService _api = ShopApiService();
  bool isLoadingBackend = false;
  bool isLiveBackend = false;
  String? backendError;

  MetalRates _rates = MetalRates(
    gold22k: 7450,
    gold24k: 7980,
    gold18k: 6100,
    silver999: 98.50,
    lastUpdated: DateTime.now(),
  );

  final List<JewelCategory> _categories = [
    const JewelCategory(id: 'cat-necklaces', name: 'Necklaces', image: 'assets/images/heritage_necklace.png'),
    const JewelCategory(id: 'cat-rings', name: 'Rings', image: 'assets/images/shop_ring.png'),
    const JewelCategory(id: 'cat-bangles', name: 'Bangles', image: 'assets/images/shop_bangle.png'),
    const JewelCategory(id: 'cat-chains', name: 'Chains', image: 'assets/images/shop_chain.png'),
    const JewelCategory(id: 'cat-earrings', name: 'Earrings', image: 'assets/images/shop_earrings.png'),
    const JewelCategory(id: 'cat-pendants', name: 'Pendants', image: 'assets/images/heritage_necklace.png'),
    const JewelCategory(id: 'cat-mangalsutra', name: 'Mangalsutra', image: 'assets/images/heritage_necklace.png'),
    const JewelCategory(id: 'cat-temple', name: 'Temple', image: 'assets/images/heritage_home.png'),
    const JewelCategory(id: 'cat-coins', name: 'Coins', image: 'assets/images/shop_gold_coins.png'),
  ];

  late final List<ShopProduct> _products;

  final Set<String> _saved = {};
  final Map<String, int> _quantities = {};

  ShopStore({bool autoLoadBackend = true}) {
    _products = [
      // 1. Signature Temple & Heritage Masterpieces
      ShopProduct(
        const JewelleryItem(
          id: 'temple-blossom-1',
          name: 'Temple Blossom Necklace',
          category: 'Necklaces',
          purity: '22K',
          weightGrams: 44.00,
          priceFormatted: '₹3,77,619',
          description: 'Intricately handcrafted 22K yellow gold temple blossom necklace with delicate floral motifs and certified hallmarking.',
          posX: 0.0,
          posZ: -3.0,
          assetPreview: 'assets/images/pedestal_necklace.png',
        ),
        'Heritage Collection',
        makingChargePercent: 12.0,
      ),
      ShopProduct(
        const JewelleryItem(
          id: 'chola-dynasty-1',
          name: 'Chola Dynasty Necklace',
          category: 'Necklaces',
          purity: '22K',
          weightGrams: 33.20,
          priceFormatted: '₹2,85,331',
          description: 'Regal Chola dynasty heirloom necklace handcrafted in 22K yellow gold.',
          posX: 0.0,
          posZ: -3.0,
          assetPreview: 'assets/images/shop_necklace.png',
        ),
        'Heritage Collection',
        makingChargePercent: 12.0,
      ),
      ShopProduct(
        const JewelleryItem(
          id: 'lotus-grace-1',
          name: 'Lotus Grace Necklace',
          category: 'Necklaces',
          purity: '22K',
          weightGrams: 49.60,
          priceFormatted: '₹4,26,384',
          description: 'Exquisite 22K gold necklace sculpted with blooming lotus petals and divine grace.',
          posX: 0.0,
          posZ: -3.0,
          assetPreview: 'assets/images/heritage_necklace.png',
        ),
        'Heritage Collection',
        makingChargePercent: 12.0,
      ),
      ShopProduct(
        const JewelleryItem(
          id: 'rg-1',
          name: 'Athirai Cosmic Temple Necklace',
          category: 'Necklaces',
          purity: '22K',
          weightGrams: 44.20,
          priceFormatted: '₹3,79,869',
          description: 'A majestic temple-inspired necklace with intricate Lakshmi and cosmic motifs, crafted in 22K hallmarked gold with fine filigree.',
          posX: -3.5,
          posZ: -3.0,
          assetPreview: 'assets/images/heritage_necklace.png',
        ),
        'Signature',
        makingChargePercent: 12.0,
      ),
      ShopProduct(
        const JewelleryItem(
          id: 'th-lakshmi-1',
          name: 'Lakshmi Temple Necklace',
          category: 'Temple',
          purity: '22K',
          weightGrams: 58.40,
          priceFormatted: '₹5,26,321',
          description: 'Intricately handcrafted 22K antique gold choker featuring Goddess Lakshmi motifs and Burmese ruby accents.',
          posX: -3.5,
          posZ: -3.0,
          assetPreview: 'assets/images/heritage_necklace.png',
        ),
        'Heritage',
        makingChargePercent: 14.0,
        stonePrice: 15000,
      ),
      ShopProduct(
        const JewelleryItem(
          id: 'royal-heritage-1',
          name: 'Royal Heritage Necklace',
          category: 'Necklaces',
          purity: '22K',
          weightGrams: 48.00,
          priceFormatted: '₹4,12,500',
          description: 'Handcrafted royal heritage bridal necklace in 22K yellow gold with antique jali filigree.',
          posX: 0.0,
          posZ: -3.0,
          assetPreview: 'assets/images/heritage_necklace.png',
        ),
        'Signature',
        makingChargePercent: 12.0,
      ),

      // 2. Curated collections from JewelleryData (skip any ID collisions)
      for (final collection in const {
        'royal_galaxy': 'Signature',
        'temple_heritage': 'Heritage',
        'diamond_palace': 'Diamond',
        'nature_gold': 'Nature',
      }.entries)
        for (final item in JewelleryData.getItemsForScene(collection.key))
          if (item.id != 'rg-1' && item.id != 'th-1')
            ShopProduct(item, collection.value),

      // 3. 24K and 999 Coin Vault Products
      ..._coinProducts(),
    ];

    if (autoLoadBackend) {
      loadFromBackend(notify: false);
    }
  }

  // --- Dynamic Getters ---
  List<ShopProduct> get products => List.unmodifiable(_products);
  List<JewelCategory> get categories => List.unmodifiable(_categories);
  MetalRates get rates => _rates;

  /// Dynamic Price List of all jewellery calculated using current live rates
  List<JewelPriceBreakdown> get priceList =>
      _products.map((p) => p.getBreakdown(_rates)).toList();

  JewelPriceBreakdown getBreakdown(ShopProduct product) =>
      product.getBreakdown(_rates);

  /// Dynamically loads live metal rates, categories, and products from backend REST API
  Future<void> loadFromBackend({bool notify = true}) async {
    try {
      isLoadingBackend = true;
      if (notify) notifyListeners();

      // 1. Fetch live metal rates
      final liveRates = await _api.fetchLiveRates();
      if (liveRates != null) {
        _rates = liveRates;
        isLiveBackend = true;
      }

      // 2. Fetch categories
      final backendCategories = await _api.fetchCategories();
      if (backendCategories.isNotEmpty) {
        for (final cat in backendCategories) {
          if (!_categories.any((c) => c.name.toLowerCase() == cat.name.toLowerCase())) {
            _categories.add(cat);
          }
        }
      }

      // 3. Fetch dynamic products
      final backendJewels = await _api.fetchJewels();
      if (backendJewels.isNotEmpty) {
        for (final bj in backendJewels.reversed) {
          _products.removeWhere(
            (p) => p.id == bj.id || p.name.toLowerCase() == bj.name.toLowerCase(),
          );
          _products.insert(0, bj);
        }
        isLiveBackend = true;
      }

      // Fetch wallet & rewards data
      final walletData = await _api.fetchWallet();
      if (walletData != null) {
        if (walletData['balance_coins'] != null) {
          _augCoins = (walletData['balance_coins'] as num).toDouble();
        }
        if (walletData['today_coins'] != null) {
          _todayCoins = (walletData['today_coins'] as num).toDouble();
        }
        if (walletData['today_amount'] != null) {
          _todayRechargeAmount = (walletData['today_amount'] as num).toDouble();
        }
        if (walletData['history'] is List) {
          _walletHistory = List<Map<String, dynamic>>.from(walletData['history']);
        }
      }

      backendError = null;
    } catch (e) {
      backendError = e.toString();
    } finally {
      isLoadingBackend = false;
      notifyListeners();
    }
  }


  // --- Dynamic Mutations: Live Rates ---
  void updateMetalRates({
    int? gold22k,
    int? gold24k,
    int? gold18k,
    double? silver999,
  }) {
    _rates = _rates.copyWith(
      gold22k: gold22k,
      gold24k: gold24k,
      gold18k: gold18k,
      silver999: silver999,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  // --- Dynamic Mutations: Add Category ---
  JewelCategory addCategory(String name, {String? image}) {
    final cleanName = name.trim();
    final existing = _categories.where(
      (c) => c.name.toLowerCase() == cleanName.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      return existing.first;
    }

    final newCat = JewelCategory(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      image: image ?? 'assets/images/heritage_necklace.png',
      isCustom: true,
    );
    _categories.add(newCat);
    notifyListeners();
    return newCat;
  }

  // --- Dynamic Mutations: Add New Jewel ---
  ShopProduct addJewel({
    required String name,
    required String category,
    required String purity,
    required double weightGrams,
    String metal = 'Gold',
    double makingChargePercent = 12.0,
    int stonePrice = 0,
    String? image,
    String? description,
    String collection = 'Signature',
    int? customPrice,
  }) {
    // 1. Ensure category exists dynamically
    addCategory(category);

    final id = 'jewel-${DateTime.now().millisecondsSinceEpoch}';
    final desc = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Exquisitely handcrafted $purity $metal $category piece from Athirai Artisans.';

    final item = JewelleryItem(
      id: id,
      name: name.trim(),
      category: category.trim(),
      purity: purity.trim(),
      weightGrams: weightGrams,
      priceFormatted: customPrice != null ? rupees(customPrice) : 'Calculating...',
      description: desc,
      posX: 0.0,
      posZ: -3.0,
      assetPreview: image ?? '',
    );

    final product = ShopProduct(
      item,
      collection,
      metal: metal,
      makingChargePercent: makingChargePercent,
      stonePrice: stonePrice,
      isCustom: true,
      customPriceOverride: customPrice,
    );

    // Prepend to catalog so it appears immediately at the top
    _products.insert(0, product);
    notifyListeners();

    // Dynamically persist to Django backend REST API in background
    _api.createJewel(
      name: name.trim(),
      category: category.trim(),
      purity: purity.trim(),
      weightGrams: weightGrams,
      metal: metal,
      makingChargePercent: makingChargePercent,
      stonePrice: stonePrice,
      description: desc,
      imageUrl: image ?? '',
    ).catchError((e) {
      debugPrint('Background backend createJewel sync: $e');
      return null;
    });

    return product;
  }

  void deleteJewel(String id) {
    _products.removeWhere((p) => p.id == id);
    _quantities.remove(id);
    _saved.remove(id);
    notifyListeners();
  }

  // --- Cart & Saved / Wishlist State ---
  bool isSaved(String id) => _saved.contains(id);
  bool isWishlisted(String id) => _saved.contains(id);
  int quantity(String id) => _quantities[id] ?? 0;
  int get count => _quantities.values.fold(0, (sum, qty) => sum + qty);
  List<ShopProduct> get cart =>
      _products.where((p) => quantity(p.id) > 0).toList();
  int get subtotal => cart.fold(0, (sum, p) => sum + p.price * quantity(p.id));

  // --- AUG Coins, Wallet & Daily Rewards System ---
  double _augCoins = 3.0;
  double get augCoins => _augCoins;
  int get augCoinValueInRupees => 100; // 1 AUG Coin = ₹100 Gold value
  double _todayCoins = 0.0;
  double get todayCoins => _todayCoins;
  double _todayRechargeAmount = 0.0;
  double get todayRechargeAmount => _todayRechargeAmount;
  bool _useCoinsInCheckout = false;
  bool get useCoinsInCheckout => _useCoinsInCheckout;
  List<Map<String, dynamic>> _walletHistory = [];
  List<Map<String, dynamic>> get walletHistory => List.unmodifiable(_walletHistory);

  void toggleUseCoinsInCheckout() {
    _useCoinsInCheckout = !_useCoinsInCheckout;
    notifyListeners();
  }

  void setUseCoinsInCheckout(bool val) {
    _useCoinsInCheckout = val;
    notifyListeners();
  }

  /// Rupee discount calculated from redeemable AUG coins
  int get coinDiscountAmount {
    if (!_useCoinsInCheckout || _augCoins <= 0) return 0;
    final maxRedeemRupees = (_augCoins * augCoinValueInRupees).round();
    return maxRedeemRupees > subtotal ? subtotal : maxRedeemRupees;
  }

  /// Net payable amount after AUG coins & rewards redemption
  int get payableAmount => (subtotal - coinDiscountAmount).clamp(0, 999999999);

  /// Number of AUG coins to be redeemed for current cart
  double get coinsToRedeemForCart {
    if (!_useCoinsInCheckout || coinDiscountAmount <= 0) return 0.0;
    return (coinDiscountAmount / augCoinValueInRupees.toDouble()).clamp(0.0, _augCoins);
  }

  /// Claims 1 credit daily login reward
  /// "customer login paninadhum avangalukku one credit reward earn aagum."
  Future<bool> claimDailyLoginReward() async {
    try {
      final res = await _api.claimDailyReward();
      if (res != null) {
        final claimed = res['claimed'] as bool? ?? false;
        final newBal = (res['balance_coins'] as num?)?.toDouble();
        if (newBal != null) {
          _augCoins = newBal;
        } else if (claimed) {
          _augCoins += 1.0;
        }
        if (claimed) {
          _walletHistory.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'type': 'reward',
            'reward_type': 'daily_login',
            'direction': 'credit',
            'amount_paid': 0.0,
            'coins_credited': 1.0,
            'payment_method': 'reward',
            'source': 'Daily Login Bonus',
            'created_at': DateTime.now().toIso8601String(),
          });
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('ShopStore: claimDailyLoginReward error: $e');
    }
    return false;
  }

  /// Recharges AUG coins into customer vault
  Future<bool> rechargeWallet({
    required double amount,
    required double coins,
    String paymentMethod = 'upi',
  }) async {
    _augCoins += coins;
    _todayCoins += coins;
    _todayRechargeAmount += amount;
    _walletHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'recharge',
      'direction': 'credit',
      'amount_paid': amount,
      'coins_credited': coins,
      'payment_method': paymentMethod,
      'source': 'Wallet Recharge',
      'created_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    _api.rechargeWallet(amount: amount, coins: coins, paymentMethod: paymentMethod).then((res) {
      if (res != null && res['new_balance'] != null) {
        _augCoins = (res['new_balance'] as num).toDouble();
        notifyListeners();
      }
    }).catchError((_) {});

    return true;
  }

  /// Buys physical Gold coins or jewellery using AUG coins & rewards!
  /// "Based on AUG coins and rewards, customer can buy the gold."
  Future<bool> buyGoldWithCoins({
    required ShopProduct product,
    int qty = 1,
    double? customCoinsToRedeem,
  }) async {
    final totalInr = product.price * qty;
    final maxRedeemableCoins = (totalInr / augCoinValueInRupees).clamp(0.0, _augCoins);
    final coinsToUse = customCoinsToRedeem != null
        ? customCoinsToRedeem.clamp(0.0, _augCoins)
        : maxRedeemableCoins;

    if (coinsToUse <= 0 && _augCoins < 1) return false;

    _augCoins = (_augCoins - coinsToUse).clamp(0.0, double.infinity);
    _walletHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'purchase',
      'direction': 'debit',
      'amount_paid': coinsToUse * augCoinValueInRupees,
      'coins_credited': coinsToUse,
      'payment_method': 'purchase',
      'source': 'Gold Purchase: ${product.name} (x$qty)',
      'created_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    _api.buyGoldWithCoins(
      productName: '${product.name} (x$qty)',
      totalPrice: totalInr.toDouble(),
      coinsToRedeem: coinsToUse,
    ).catchError((_) => null);

    return true;
  }

  /// Completes checkout and deducts redeemed coins
  void completeCheckout() {
    if (_useCoinsInCheckout && coinsToRedeemForCart > 0) {
      final redeemed = coinsToRedeemForCart;
      _augCoins = (_augCoins - redeemed).clamp(0.0, double.infinity);
      _walletHistory.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'type': 'purchase',
        'direction': 'debit',
        'amount_paid': (redeemed * augCoinValueInRupees),
        'coins_credited': redeemed,
        'payment_method': 'purchase',
        'source': 'Order Checkout: ${cart.length} item(s)',
        'created_at': DateTime.now().toIso8601String(),
      });
      _useCoinsInCheckout = false;
    }
    clear();
  }

  // --- Delivery Address (Step 8: Delivery Address) ---
  String _deliveryName = 'Royal Patron';
  String get deliveryName => _deliveryName;
  String _deliveryPhone = '+91 98765 43210';
  String get deliveryPhone => _deliveryPhone;
  String _doorNo = '12/4';
  String get doorNo => _doorNo;
  String _streetName = 'Temple View Road, T Nagar';
  String get streetName => _streetName;
  String _town = 'T Nagar';
  String get town => _town;
  String _city = 'Chennai';
  String get city => _city;
  String _pincode = '600017';
  String get pincode => _pincode;
  String _state = 'Tamil Nadu';
  String get state => _state;

  void updateDeliveryAddress({
    required String name,
    required String phone,
    String? doorNo,
    String? streetName,
    String? town,
    String? city,
    String? pincode,
    String? state,
  }) {
    _deliveryName = name;
    _deliveryPhone = phone;
    if (doorNo != null) _doorNo = doorNo;
    if (streetName != null) _streetName = streetName;
    if (town != null) _town = town;
    if (city != null) _city = city;
    if (pincode != null) _pincode = pincode;
    if (state != null) _state = state;
    notifyListeners();
  }

  // --- Orders Management (Steps 8, 10, 11) ---
  List<Map<String, dynamic>> _myOrders = [];
  List<Map<String, dynamic>> get myOrders => List.unmodifiable(_myOrders);

  Future<void> loadOrders() async {
    final list = await _api.fetchMyOrders();
    if (list.isNotEmpty) {
      _myOrders = list;
      notifyListeners();
    }
  }

  // Step 7: 1 Rupee = 100 AUG Coins conversion
  int get augCoinsPerRupee => 100;
  double inrToCoins(num inr) => inr.toDouble() * 100.0;
  double coinsToInr(num coins) => coins.toDouble() / 100.0;

  // Step 8: Place Order strictly using AUG Coins
  Future<Map<String, dynamic>> placeOrderWithCoins({
    required String productName,
    required int totalAmountInr,
    String? productImage,
    String? metalPurity,
    double? weightGrams,
    int quantity = 1,
  }) async {
    final coinsNeeded = inrToCoins(totalAmountInr);
    if (_augCoins < coinsNeeded) {
      return {
        'success': false,
        'error': 'INSUFFICIENT_COINS',
        'coins_needed': coinsNeeded,
        'coins_available': _augCoins,
        'shortfall_coins': coinsNeeded - _augCoins,
        'shortfall_inr': (coinsNeeded - _augCoins) / 100.0,
      };
    }

    final res = await _api.createOrder(
      productName: productName,
      totalAmountInr: totalAmountInr,
      deliveryName: _deliveryName,
      deliveryPhone: _deliveryPhone,
      doorNo: _doorNo,
      streetName: _streetName,
      town: _town,
      city: _city,
      pincode: _pincode,
      state: _state,
      productImage: productImage,
      metalPurity: metalPurity,
      weightGrams: weightGrams,
      quantity: quantity,
    );

    _augCoins = (_augCoins - coinsNeeded).clamp(0.0, double.infinity);
    final orderData = res?['order'] as Map<String, dynamic>? ?? {
      'order_id': 'ATH-${DateTime.now().millisecondsSinceEpoch}',
      'invoice_number': 'INV-ATH-${DateTime.now().millisecondsSinceEpoch}',
      'product_name': productName,
      'total_amount': totalAmountInr,
      'coins_used': coinsNeeded,
      'status': 'Confirmed',
      'created_at': DateTime.now().toIso8601String(),
      'delivery_name': _deliveryName,
      'delivery_phone': _deliveryPhone,
      'delivery_address': '$_doorNo $_streetName, $_town $_city - $_pincode, $_state',
      'metal_purity': metalPurity ?? '22K Gold',
      'weight_grams': weightGrams ?? 10.0,
      'quantity': quantity,
    };

    _myOrders.insert(0, orderData);
    _walletHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'purchase',
      'direction': 'debit',
      'amount_paid': totalAmountInr.toDouble(),
      'coins_credited': coinsNeeded,
      'payment_method': 'AUG Coins',
      'order_id': orderData['order_id'],
      'source': 'Gold Purchase: $productName',
      'created_at': DateTime.now().toIso8601String(),
    });

    notifyListeners();
    return {
      'success': true,
      'order': orderData,
      'remaining_coins': _augCoins,
    };
  }

  // Step 9: Recharge AUG Coins via Razorpay
  Future<bool> buyAUGCoinsViaRazorpay({
    required double amountInr,
    required String mobileNumber,
  }) async {
    final coinsToCredit = inrToCoins(amountInr);
    final ok = await rechargeWallet(
      amount: amountInr,
      coins: coinsToCredit,
      paymentMethod: 'razorpay',
    );
    if (ok) {
      notifyListeners();
      return true;
    }
    // Offline resilience fallback
    _augCoins += coinsToCredit;
    _walletHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'recharge',
      'direction': 'credit',
      'amount_paid': amountInr,
      'coins_credited': coinsToCredit,
      'payment_method': 'razorpay',
      'source': 'Razorpay Coins Purchase ($mobileNumber)',
      'created_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();
    return true;
  }

  // Step 7 Point 5: Manual Coin Creation / Generation
  Future<bool> manualCreditAUGCoins({
    required double coins,
    double amountInr = 0.0,
    String source = 'Manual Admin / System Generation',
  }) async {
    await _api.manualCreditCoins(
      coins: coins,
      amountInr: amountInr,
      source: source,
    );
    _augCoins += coins;
    _walletHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'bonus',
      'direction': 'credit',
      'amount_paid': amountInr,
      'coins_credited': coins,
      'payment_method': 'system_manual',
      'source': source,
      'created_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();
    return true;
  }

  // Step 11: Download / fetch order receipt PDF bytes
  Future<List<int>?> downloadReceiptPdf(String orderId) async {
    return await _api.downloadOrderReceiptPdf(orderId);
  }

  /// Reset session data for tests
  void resetSessionForTest() {
    _augCoins = 0.0;
    _myOrders = [];
    _walletHistory.clear();
    _saved.clear();
    _quantities.clear();
    notifyListeners();
  }

  List<ShopProduct> get wishlist =>
      _products.where((p) => isSaved(p.id)).toList();
  int get wishlistCount => _saved.length;

  ShopProduct? findProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _saved.clear();
    _quantities.clear();
    notifyListeners();
  }


  void clearWishlist() {
    _saved.clear();
    notifyListeners();
  }

  void toggleSaved(String id) {
    if (!_products.any((p) => p.id == id)) return;
    if (!_saved.remove(id)) _saved.add(id);
    notifyListeners();
  }

  void toggleWishlist(String id) => toggleSaved(id);

  void addToWishlist(String id) {
    if (!_products.any((p) => p.id == id)) return;
    if (_saved.add(id)) notifyListeners();
  }

  void removeFromWishlist(String id) {
    if (_saved.remove(id)) notifyListeners();
  }

  void addAllWishlistToCart() {
    for (final p in wishlist) {
      final current = quantity(p.id);
      setQuantity(p.id, current > 0 ? current : 1);
    }
  }

  void addToCart(String id, [int qty = 1]) {
    setQuantity(id, quantity(id) + qty);
  }

  void removeFromCart(String id) {
    _quantities.remove(id);
    notifyListeners();
  }

  void setQuantity(String id, int quantity) {
    if (!_products.any((p) => p.id == id)) return;
    if (quantity <= 0) {
      _quantities.remove(id);
    } else {
      _quantities[id] = quantity.clamp(1, 10);
    }
    notifyListeners();
  }
}

/// Coins catalog dynamically calculated from rates
List<ShopProduct> _coinProducts() => [
  for (final metal in ['Gold', 'Silver'])
    for (final purity in metal == 'Gold' ? ['22K', '24K'] : ['999'])
      for (final weight
          in metal == 'Gold' ? [0.1, 0.25, 1.0] : [0.1, 0.25, 0.5, 1.0, 10.0])
        ShopProduct(
          JewelleryItem(
            id: '${metal.toLowerCase()}-coin-$purity-$weight',
            name:
                '$purity $metal Coin - ${weight < 1 ? '${(weight * 1000).round()} mg' : '${weight.toInt()} g'}',
            category: '$metal Coins',
            purity: purity,
            weightGrams: weight,
            priceFormatted: rupees(
              (weight *
                      (metal == 'Silver'
                          ? 100
                          : purity == '24K'
                          ? 8200
                          : 7500))
                  .round(),
            ),
            description:
                '$metal coin in $purity purity. Certified ${purity == '24K' ? '24K/999' : purity == '22K' ? '22K/916' : '999 Fine'} Assay Packaging with tamper-proof seal.',
            posX: 0,
            posZ: 0,
            assetPreview: 'assets/images/shop_${metal.toLowerCase()}_coins.png',
          ),
          '$metal Coins',
          metal: metal,
          makingChargePercent: metal == 'Gold' ? 3.0 : 5.0,
        ),
];
