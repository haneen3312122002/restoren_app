import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restoren_app/features/cart/domain/entities/cart_item.dart';
import 'package:restoren_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:restoren_app/features/menu/domain/entities/menu_product.dart';

/// Tests for the cart logic.
void main() {
  const burger = MenuProduct(id: 1, name: 'Burger', price: 8.50);
  const juice = MenuProduct(id: 2, name: 'Juice', price: 0.10);

  late ProviderContainer container;
  CartViewModel cart() => container.read(cartViewModelProvider.notifier);
  List<CartItem> items() => container.read(cartViewModelProvider);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('adding the same product twice increases quantity instead of a new line', () {
    cart().add(burger);
    cart().add(burger);

    expect(items(), hasLength(1));
    expect(items().single.quantity, 2);
  });

  test('decrement at quantity 1 removes the line', () {
    cart().add(burger);
    cart().add(juice);
    cart().decrement(burger.id);

    expect(items().map((i) => i.productId), [juice.id]);
  });

  test('quantity cannot go above 50', () {
    cart().add(burger);
    for (var i = 0; i < 60; i++) {
      cart().increment(burger.id);
    }

    expect(items().single.quantity, CartItem.maxQuantity);
  });

  test('total and count update on every change without floating point errors', () {
    cart().add(burger); // 8.50
    cart().add(juice); // 0.10
    cart().increment(juice.id); // 0.20
    cart().increment(juice.id); // 0.30

    expect(container.read(cartTotalProvider), 8.80);
    expect(container.read(cartCountProvider), 4);

    cart().remove(burger.id);
    expect(container.read(cartTotalProvider), closeTo(0.30, 0.0001));
  });

  test('clear empties the cart', () {
    cart().add(burger);
    cart().add(juice);
    cart().clear();

    expect(items(), isEmpty);
    expect(container.read(cartTotalProvider), 0);
  });
}
