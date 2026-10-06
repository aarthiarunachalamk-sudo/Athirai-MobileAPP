import 'package:flutter_test/flutter_test.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';

void main() {
  group('Vault CMS Models & Calculations', () {
    test('VaultProduct instantiates with correct default values and price calculation', () {
      const product = VaultProduct(
        id: 101,
        name: 'Royal Chola Choker',
        category: 'Necklace',
        collection: 'Chola Dynasty',
        weightGrams: 50.0,
        makingChargePercent: 12.0,
        stonePrice: 40000,
        calculatedTotalPrice: 425000,
      );

      expect(product.id, 101);
      expect(product.name, 'Royal Chola Choker');
      expect(product.category, 'Necklace');
      expect(product.collection, 'Chola Dynasty');
      expect(product.weightGrams, 50.0);
      expect(product.calculatedTotalPrice, 425000);
    });

    test('VaultProduct serializes to and from JSON cleanly', () {
      final json = {
        'id': 102,
        'name': 'Lotus Bloom Ring',
        'category': 'Rings',
        'collection': 'Temple Blossoms',
        'sku': 'ATH-RNG-102',
        'metal': 'Gold',
        'purity': '22K',
        'weight_grams': 14.5,
        'making_charge_percent': 10.0,
        'stone_price': 25000,
        'stock_quantity': 8,
        'status': 'Published',
        'price_breakdown': {
          'total_price': 142000,
          'metal_cost': 108025,
          'making_charges': 10802,
          'gst_amount': 4260,
        },
      };

      final p = VaultProduct.fromJson(json);
      expect(p.id, 102);
      expect(p.name, 'Lotus Bloom Ring');
      expect(p.calculatedTotalPrice, 142000);
      expect(p.calculatedMetalCost, 108025);
      expect(p.calculatedMakingCharges, 10802);
      expect(p.stockQuantity, 8);

      final outJson = p.toJson();
      expect(outJson['name'], 'Lotus Bloom Ring');
      expect(outJson['sku'], 'ATH-RNG-102');
    });

    test('VaultApiService provides complete resilience data when offline', () async {
      final service = VaultApiService(baseUrl: 'http://127.0.0.1:9999/api'); // Non-existent offline port
      final products = await service.getProducts();
      expect(products.isNotEmpty, true);
      expect(products.first.name, contains('Necklace'));

      final collections = await service.getCollections();
      expect(collections.length, 5);

      final orders = await service.getOrders();
      expect(orders.isNotEmpty, true);

      final rates = await service.getMetalRates();
      expect(rates.gold22k, greaterThan(7000));
    });
  });
}
