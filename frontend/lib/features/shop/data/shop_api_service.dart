import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../showroom/domain/models/jewellery_item.dart';
import '../domain/shop_store.dart';

class ShopApiService {
  final ApiClient _client;

  ShopApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Fetches live metal rates from backend: GET /api/rates/
  Future<MetalRates?> fetchLiveRates() async {
    try {
      final response = await _client.get(ApiEndpoints.rates, requireAuth: false);
      if (response.isSuccess && response.data != null) {
        final ratesData = response.data!['rates'] ?? response.data;
        if (ratesData is Map<String, dynamic>) {
          return MetalRates(
            gold24k: (ratesData['gold_24k'] as num?)?.toInt() ?? 7980,
            gold22k: (ratesData['gold_22k'] as num?)?.toInt() ?? 7450,
            gold18k: (ratesData['gold_18k'] as num?)?.toInt() ?? 6100,
            silver999: (ratesData['silver_999'] as num?)?.toDouble() ?? 98.50,
            lastUpdated: DateTime.now(),
          );
        }
      }
    } catch (e) {
      debugPrint('ShopApiService: error fetching live rates: $e');
    }
    return null;
  }

  /// Fetches dynamic jewellery categories: GET /api/categories/
  Future<List<JewelCategory>> fetchCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.categories, requireAuth: false);
      if (response.isSuccess && response.data != null) {
        final list = response.data!['categories'];
        if (list is List) {
          final categories = <JewelCategory>[];
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final id = item['id']?.toString() ?? 'cat-${item['name']}';
              final name = item['name']?.toString() ?? '';
              final image = item['image_url']?.toString() ?? '';
              if (name.isNotEmpty) {
                categories.add(
                  JewelCategory(
                    id: id,
                    name: name,
                    image: image.isNotEmpty ? image : _fallbackCategoryImage(name),
                  ),
                );
              }
            }
          }
          if (categories.isNotEmpty) return categories;
        }
      }
    } catch (e) {
      debugPrint('ShopApiService: error fetching categories: $e');
    }
    return [];
  }

  /// Fetches dynamic products: GET /api/jewels/
  Future<List<ShopProduct>> fetchJewels({String? category, String? search}) async {
    try {
      String url = ApiEndpoints.jewels;
      final queryParams = <String>[];
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }
      if (queryParams.isNotEmpty) {
        url = '$url?${queryParams.join('&')}';
      }

      final response = await _client.get(url, requireAuth: false);
      if (response.isSuccess && response.data != null) {
        final list = response.data!['jewels'];
        if (list is List) {
          final products = <ShopProduct>[];
          for (final raw in list) {
            if (raw is Map<String, dynamic>) {
              final id = raw['id']?.toString() ?? 'jewel-${DateTime.now().millisecondsSinceEpoch}';
              final name = raw['name']?.toString() ?? 'Athirai Jewel';
              final catName = raw['category_name']?.toString() ??
                  (raw['category'] is Map ? raw['category']['name']?.toString() : 'Jewellery') ??
                  'Jewellery';
              final metal = raw['metal']?.toString() ?? 'Gold';
              final purity = raw['purity']?.toString() ?? '22K';
              final weight = (raw['weight_grams'] as num?)?.toDouble() ??
                  double.tryParse(raw['weight_grams']?.toString() ?? '20.0') ??
                  20.0;
              final makingCharge = (raw['making_charge_percent'] as num?)?.toDouble() ??
                  double.tryParse(raw['making_charge_percent']?.toString() ?? '12.0') ??
                  12.0;
              final stonePrice = (raw['stone_price'] as num?)?.toInt() ??
                  int.tryParse(raw['stone_price']?.toString() ?? '0') ??
                  0;
              final description = raw['description']?.toString() ?? '';
              final imageUrl = raw['image_url']?.toString() ?? '';
              final dynamicPrice = (raw['dynamic_price'] as num?)?.toInt();

              final item = JewelleryItem(
                id: id,
                name: name,
                category: catName,
                purity: purity,
                weightGrams: weight,
                priceFormatted: dynamicPrice != null ? rupees(dynamicPrice) : '₹ 0',
                description: description.isNotEmpty
                    ? description
                    : 'Exquisitely handcrafted $purity $metal $catName from Athirai Artisans.',
                posX: 0.0,
                posZ: -3.0,
                assetPreview: imageUrl.isNotEmpty ? imageUrl : _fallbackProductImage(catName, name),
              );

              products.add(
                ShopProduct(
                  item,
                  'Heritage',
                  metal: metal,
                  makingChargePercent: makingCharge,
                  stonePrice: stonePrice,
                  customPriceOverride: dynamicPrice,
                ),
              );
            }
          }
          if (products.isNotEmpty) return products;
        }
      }
    } catch (e) {
      debugPrint('ShopApiService: error fetching jewels: $e');
    }
    return [];
  }

  /// Adds a new jewel dynamically via POST /api/jewels/
  Future<ShopProduct?> createJewel({
    required String name,
    required String category,
    required String purity,
    required double weightGrams,
    String metal = 'Gold',
    double makingChargePercent = 12.0,
    int stonePrice = 0,
    String description = '',
    String imageUrl = '',
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.jewels,
        body: {
          'name': name,
          'category': category,
          'purity': purity,
          'weight_grams': weightGrams,
          'metal': metal,
          'making_charge_percent': makingChargePercent,
          'stone_price': stonePrice,
          'description': description,
          'image_url': imageUrl,
        },
        requireAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        final raw = response.data!['jewel'] ?? response.data;
        if (raw is Map<String, dynamic>) {
          final id = raw['id']?.toString() ?? 'jewel-${DateTime.now().millisecondsSinceEpoch}';
          final dynamicPrice = (raw['dynamic_price'] as num?)?.toInt();

          final item = JewelleryItem(
            id: id,
            name: name,
            category: category,
            purity: purity,
            weightGrams: weightGrams,
            priceFormatted: dynamicPrice != null ? rupees(dynamicPrice) : '₹ 0',
            description: description,
            posX: 0.0,
            posZ: -3.0,
            assetPreview: imageUrl.isNotEmpty ? imageUrl : _fallbackProductImage(category, name),
          );

          return ShopProduct(
            item,
            'Custom',
            metal: metal,
            makingChargePercent: makingChargePercent,
            stonePrice: stonePrice,
            customPriceOverride: dynamicPrice,
          );
        }
      }
    } catch (e) {
      debugPrint('ShopApiService: error creating jewel: $e');
    }
    return null;
  }

  /// Fetches customer wallet state: GET /api/wallet/
  Future<Map<String, dynamic>?> fetchWallet() async {
    try {
      final response = await _client.get(ApiEndpoints.wallet, requireAuth: false);
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ShopApiService: error fetching wallet: $e');
    }
    return null;
  }

  /// Claims daily 1 credit login reward: POST /api/wallet/claim-daily/
  Future<Map<String, dynamic>?> claimDailyReward() async {
    try {
      final response = await _client.post(ApiEndpoints.claimDailyReward, body: {}, requireAuth: false);
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ShopApiService: error claiming daily reward: $e');
    }
    return null;
  }

  /// Recharges wallet with coins: POST /api/recharge/verify/
  Future<Map<String, dynamic>?> rechargeWallet({
    required double amount,
    required double coins,
    String paymentMethod = 'upi',
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.rechargeVerify,
        body: {
          'amount': amount,
          'coins': coins,
          'payment_method': paymentMethod,
        },
        requireAuth: false,
      );
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ShopApiService: error recharging wallet: $e');
    }
    return null;
  }

  /// Purchases gold coins or jewellery using AUG coins & rewards: POST /api/gold/buy-with-coins/
  Future<Map<String, dynamic>?> buyGoldWithCoins({
    required String productName,
    required double totalPrice,
    required double coinsToRedeem,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.buyGoldWithCoins,
        body: {
          'product_name': productName,
          'total_price': totalPrice,
          'coins_to_redeem': coinsToRedeem,
        },
        requireAuth: false,
      );
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ShopApiService: error buying gold with coins: $e');
    }
    return null;
  }

  /// Step 8 & 10: Place order with delivery address using AUG Coins
  Future<Map<String, dynamic>?> createOrder({
    required String productName,
    required int totalAmountInr,
    required String deliveryName,
    required String deliveryPhone,
    String doorNo = '',
    String streetName = '',
    String town = '',
    String city = 'Chennai',
    String pincode = '600001',
    String state = 'Tamil Nadu',
    String? deliveryAddress,
    String? productImage,
    String? metalPurity,
    double? weightGrams,
    int quantity = 1,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.orderCreate,
        body: {
          'product_name': productName,
          'total_amount': totalAmountInr,
          'delivery_name': deliveryName,
          'delivery_phone': deliveryPhone,
          'door_no': doorNo,
          'street_name': streetName,
          'town': town,
          'city': city,
          'pincode': pincode,
          'state': state,
          'delivery_address': deliveryAddress ?? '$doorNo $streetName, $town $city - $pincode, $state',
          'product_image': productImage ?? '',
          'metal_purity': metalPurity ?? '22K Gold',
          'weight_grams': weightGrams ?? 10.0,
          'quantity': quantity,
        },
        requireAuth: false,
      );
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
      return response.data;
    } catch (e) {
      debugPrint('ShopApiService: createOrder error: $e');
    }
    return null;
  }

  /// Step 10: Fetch user's Order Summary list
  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    try {
      final response = await _client.get(
        ApiEndpoints.myOrders,
        requireAuth: false,
      );
      if (response.isSuccess && response.data != null) {
        final list = response.data!['orders'];
        if (list is List) {
          return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint('ShopApiService: fetchMyOrders error: $e');
    }
    return [];
  }

  /// Step 11: Download / Fetch Order Receipt PDF bytes
  Future<List<int>?> downloadOrderReceiptPdf(String orderId) async {
    try {
      final url = Uri.parse(ApiEndpoints.orderReceiptPdf(orderId));
      final response = await http.get(url);
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('ShopApiService: downloadOrderReceiptPdf error: $e');
    }
    return null;
  }

  /// Step 7 Point 5: Manual Coin Creation / Generation
  Future<Map<String, dynamic>?> manualCreditCoins({
    required double coins,
    double amountInr = 0.0,
    String source = 'Manual Generation',
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.manualCoinCredit,
        body: {
          'coins': coins,
          'amount_inr': amountInr,
          'source': source,
        },
        requireAuth: false,
      );
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ShopApiService: manualCreditCoins error: $e');
    }
    return null;
  }


  static String _fallbackCategoryImage(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('necklace')) return 'assets/images/heritage_necklace.png';
    if (lower.contains('ring')) return 'assets/images/shop_ring.png';
    if (lower.contains('bangle')) return 'assets/images/shop_bangle.png';
    if (lower.contains('chain')) return 'assets/images/shop_chain.png';
    if (lower.contains('earring')) return 'assets/images/shop_earrings.png';
    if (lower.contains('coin')) return 'assets/images/shop_gold_coins.png';
    return 'assets/images/heritage_necklace.png';
  }

  static String _fallbackProductImage(String category, String name) {
    final lower = '$category $name'.toLowerCase();
    if (lower.contains('choker') || lower.contains('dynast')) {
      return 'assets/images/shop_necklace.png';
    }
    if (lower.contains('temple') || lower.contains('blossom') || lower.contains('necklace')) {
      return 'assets/images/heritage_necklace.png';
    }
    if (lower.contains('coin')) {
      return lower.contains('silver')
          ? 'assets/images/shop_silver_coins.png'
          : 'assets/images/shop_gold_coins.png';
    }
    if (lower.contains('ring')) return 'assets/images/shop_ring.png';
    if (lower.contains('bangle') || lower.contains('kada')) return 'assets/images/shop_bangle.png';
    if (lower.contains('earring') || lower.contains('jhumka')) return 'assets/images/shop_earrings.png';
    return 'assets/images/heritage_necklace.png';
  }
}
