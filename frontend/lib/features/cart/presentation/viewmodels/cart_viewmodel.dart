import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../menu/domain/entities/menu_product.dart';
import '../../domain/entities/cart_item.dart';

/// The cart. Kept in memory only (no table or API because customers don't have accounts).
final cartViewModelProvider = NotifierProvider<CartViewModel, List<CartItem>>(CartViewModel.new);

/// Cart total for display.
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartViewModelProvider);
  return items.fold<int>(0, (sum, i) => sum + i.lineTotalCents) / 100;
});

/// Number of items in the cart (for the badge on the cart icon).
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartViewModelProvider).fold<int>(0, (sum, i) => sum + i.quantity);
});

/// Cart logic: add, increase, decrease, remove, clear.
class CartViewModel extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Adds a product. If it's already there, increases its quantity instead of adding a new line.
  void add(MenuProduct product) {
    final index = state.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      increment(product.id);
      return;
    }
    state = [
      ...state,
      CartItem(
        productId: product.id,
        name: product.name,
        unitPrice: product.price,
        quantity: CartItem.minQuantity,
        imageUrl: product.imageUrl,
      ),
    ];
  }

  /// Adds one to the quantity (up to 50).
  void increment(int productId) {
    state = [
      for (final item in state)
        if (item.productId == productId && item.quantity < CartItem.maxQuantity)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  /// Takes one off the quantity. If it was 1, removes the line.
  void decrement(int productId) {
    state = [
      for (final item in state)
        if (item.productId != productId)
          item
        else if (item.quantity > CartItem.minQuantity)
          item.copyWith(quantity: item.quantity - 1),
    ];
  }

  /// Removes the whole line.
  void remove(int productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  /// Empties the cart (only after a successful order, or with the "Clear" button).
  void clear() => state = const [];
}
