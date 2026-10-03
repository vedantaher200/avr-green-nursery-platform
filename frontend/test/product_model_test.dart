import 'package:flutter_test/flutter_test.dart';
import 'package:avrgreen/features/catalog/data/models/product_model.dart';

void main() {
  group('Product.fromJson Type Saftey Tests (Regression)', () {
    test('Correctly parses quantity_available when returned as a string from Postgres SUM()', () {
      final jsonWithStrings = {
        'id': '123',
        'tenant_id': '456',
        'nursery_name': 'Test Nursery',
        'sku': 'SKU-001',
        'common_name': 'Chilli Plant',
        'price': 2.50,
        'quantity_available': '1200',
        'total_stock': '1200',
        'ready_stock': '1200',
      };

      // This would have previously thrown a TypeError: type 'String' is not a subtype of type 'int'
      final product = Product.fromJson(jsonWithStrings);

      expect(product.availableStock, equals(1200));
      expect(product.readyStock, equals(1200));
    });

    test('Correctly parses quantity_available when returned natively as an integer', () {
      final jsonWithInts = {
        'id': '123',
        'tenant_id': '456',
        'nursery_name': 'Test Nursery',
        'sku': 'SKU-001',
        'common_name': 'Tomato Plant',
        'price': '3.00',
        'quantity_available': 500,
        'total_stock': 500,
        'ready_stock': 500,
      };

      final product = Product.fromJson(jsonWithInts);

      expect(product.availableStock, equals(500));
      expect(product.readyStock, equals(500));
      expect(product.price, equals(3.0));
    });

    test('Correctly falls back to default when values are null', () {
      final jsonWithNulls = {
        'id': '123',
        'tenant_id': '456',
        'nursery_name': 'Test Nursery',
        'sku': 'SKU-001',
        'common_name': 'Cabbage',
        'quantity_available': null,
        'total_stock': null,
        'ready_stock': null,
      };

      final product = Product.fromJson(jsonWithNulls);

      expect(product.availableStock, equals(50)); // the documented fallback in Product.fromJson
      expect(product.readyStock, equals(50));
    });
  });
}
