import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/providers/auth_provider.dart';
import '../network/api_client.dart';

typedef Json = Map<String, dynamic>;

class _Repository {
  const _Repository(this.client);
  final ApiClient client;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      (await client.dio.get(path, queryParameters: query)).data['data'];
  Future<dynamic> post(String path, [Object? body]) async =>
      (await client.dio.post(path, data: body)).data['data'];
  Future<dynamic> patch(String path, [Object? body]) async =>
      (await client.dio.patch(path, data: body)).data['data'];
}

class CatalogRepository extends _Repository {
  const CatalogRepository(super.client);
  Future<List<Json>> products(
          {String? search,
          int page = 1,
          int limit = 20,
          String? sortBy,
          String? sortOrder}) async =>
      List<Json>.from(await get('/products', query: {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder
      }));
  Future<Json> product(String id) async =>
      Json.from(await get('/products/$id'));
  Future<List<Json>> categories() async =>
      List<Json>.from(await get('/products/categories/all'));
}

class OrderRepository extends _Repository {
  const OrderRepository(super.client);
  Future<List<Json>> orders({int page = 1, int limit = 20}) async =>
      List<Json>.from(
          await get('/orders', query: {'page': page, 'limit': limit}));
  Future<Json> order(String id) async => Json.from(await get('/orders/$id'));
  Future<Json> create(Json body) async =>
      Json.from(await post('/orders', body));
  Future<Json> updateStatus(String id, String status, {String? notes}) async =>
      Json.from(await patch('/orders/$id/status',
          {'status': status, if (notes != null) 'notes': notes}));
}

class DeliveryRepository extends _Repository {
  const DeliveryRepository(super.client);
  Future<List<Json>> mine() async =>
      List<Json>.from(await get('/deliveries/agent/me'));
  Future<Json> trackOrder(String orderId) async =>
      Json.from(await get('/deliveries/track/$orderId'));
  Future<void> location(String id, double lat, double lng) async =>
      patch('/deliveries/$id/location', {'lat': lat, 'lng': lng});
  Future<void> delivered(String id, {String? notes}) async =>
      post('/deliveries/$id/delivered', {if (notes != null) 'notes': notes});
  Future<void> failed(String id, String reason) async =>
      post('/deliveries/$id/failed', {'reason': reason});
}

class InventoryRepository extends _Repository {
  const InventoryRepository(super.client);
  Future<List<Json>> items(
          {int page = 1, int limit = 20, String? search}) async =>
      List<Json>.from(await get('/inventory', query: {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search
      }));
  Future<List<Json>> movements(String productId) async =>
      List<Json>.from(await get('/inventory/movements/$productId'));
  Future<void> adjust(Json body) async => post('/inventory/adjust', body);
  Future<Json> transfer(Json body) async =>
      Json.from(await post('/inventory/transfer', body));
}

class ReportRepository extends _Repository {
  const ReportRepository(super.client);
  Future<Json> dashboard() async => Json.from(await get('/reports/dashboard'));
  Future<List<Json>> sales({String? from, String? to}) async =>
      List<Json>.from(await get('/reports/sales',
          query: {if (from != null) 'from': from, if (to != null) 'to': to}));
  Future<List<Json>> valuation() async =>
      List<Json>.from(await get('/reports/inventory-valuation'));
  Future<List<Json>> topCustomers() async =>
      List<Json>.from(await get('/reports/top-customers'));
}

final catalogRepositoryProvider =
    Provider((ref) => CatalogRepository(ref.watch(apiClientProvider)));
final orderRepositoryProvider =
    Provider((ref) => OrderRepository(ref.watch(apiClientProvider)));
final deliveryRepositoryProvider =
    Provider((ref) => DeliveryRepository(ref.watch(apiClientProvider)));
final inventoryRepositoryProvider =
    Provider((ref) => InventoryRepository(ref.watch(apiClientProvider)));
final reportRepositoryProvider =
    Provider((ref) => ReportRepository(ref.watch(apiClientProvider)));
final productsProvider = FutureProvider<List<Json>>(
    (ref) => ref.watch(catalogRepositoryProvider).products());
final categoriesProvider = FutureProvider<List<Json>>(
    (ref) => ref.watch(catalogRepositoryProvider).categories());
final ordersProvider = FutureProvider<List<Json>>(
    (ref) => ref.watch(orderRepositoryProvider).orders());
final deliveriesProvider = FutureProvider<List<Json>>(
    (ref) => ref.watch(deliveryRepositoryProvider).mine());
final inventoryProvider = FutureProvider<List<Json>>(
    (ref) => ref.watch(inventoryRepositoryProvider).items());
final reportDashboardProvider = FutureProvider<Json>(
    (ref) => ref.watch(reportRepositoryProvider).dashboard());
