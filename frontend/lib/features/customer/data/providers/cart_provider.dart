import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avrgreen/features/catalog/data/models/product_model.dart';

enum CartAddResult {
  success,
  nurseryConflict,
}

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final String? currentTenantId;
  final String? currentNurseryName;

  const CartState({
    this.items = const [],
    this.currentTenantId,
    this.currentNurseryName,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get gst => double.parse((subtotal * 0.18).toStringAsFixed(2));

  double get deliveryFee => (subtotal > 0 && subtotal < 1000) ? 99.0 : 0.0;

  double get grandTotal => double.parse((subtotal + gst + deliveryFee).toStringAsFixed(2));

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    String? currentTenantId,
    String? currentNurseryName,
    bool clearNursery = false,
  }) {
    return CartState(
      items: items ?? this.items,
      currentTenantId: clearNursery ? null : (currentTenantId ?? this.currentTenantId),
      currentNurseryName: clearNursery ? null : (currentNurseryName ?? this.currentNurseryName),
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  CartAddResult addItem(Product product, {int quantity = 1}) {
    // Single-Nursery Cart Enforcement: Cart cannot mix products from different nurseries
    if (state.items.isNotEmpty &&
        state.currentTenantId != null &&
        state.currentTenantId != product.tenantId) {
      return CartAddResult.nurseryConflict;
    }

    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final current = state.items[existingIndex];
      final newQuantity = current.quantity + quantity;
      final updatedList = List<CartItem>.from(state.items);
      updatedList[existingIndex] = current.copyWith(quantity: newQuantity);
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: quantity)],
        currentTenantId: product.tenantId,
        currentNurseryName: product.nurseryName,
      );
    }
    return CartAddResult.success;
  }

  void clearAndAdd(Product product, {int quantity = 1}) {
    state = CartState(
      items: [CartItem(product: product, quantity: quantity)],
      currentTenantId: product.tenantId,
      currentNurseryName: product.nurseryName,
    );
  }

  void removeItem(String productId) {
    final updatedList = state.items.where((i) => i.product.id != productId).toList();
    if (updatedList.isEmpty) {
      state = const CartState();
    } else {
      state = state.copyWith(items: updatedList);
    }
  }

  void updateQuantity(String productId, int delta) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == productId);
    if (existingIndex < 0) return;

    final current = state.items[existingIndex];
    final newQty = current.quantity + delta;

    if (newQty <= 0) {
      removeItem(productId);
    } else {
      final updatedList = List<CartItem>.from(state.items);
      updatedList[existingIndex] = current.copyWith(quantity: newQty);
      state = state.copyWith(items: updatedList);
    }
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
