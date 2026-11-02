import 'package:flutter_test/flutter_test.dart';
import 'package:restoren_app/core/validation/validators.dart';
import 'package:restoren_app/features/orders/domain/entities/order.dart';

/// Tests for the form checks (same rules as the backend) and the status order.
void main() {
  test('customer name must be 2..100 characters', () {
    expect(Validators.customerName('H'), isNotNull);
    expect(Validators.customerName('Haneen'), isNull);
    expect(Validators.customerName('x' * 101), isNotNull);
  });

  test('phone accepts digits with optional + spaces and dashes', () {
    expect(Validators.phone('+962 79 123 4567'), isNull);
    expect(Validators.phone('0791234567'), isNull);
    expect(Validators.phone('abc'), isNotNull);
    expect(Validators.phone('12'), isNotNull);
  });

  test('price must be > 0 with at most two decimals', () {
    expect(Validators.price('4.50'), isNull);
    expect(Validators.price('0'), isNotNull);
    expect(Validators.price('1.234'), isNotNull);
    expect(Validators.price('abc'), isNotNull);
  });

  test('image url must be http or https when present', () {
    expect(Validators.imageUrl(''), isNull);
    expect(Validators.imageUrl('https://example.com/a.jpg'), isNull);
    expect(Validators.imageUrl('ftp://example.com/a.jpg'), isNotNull);
  });

  test('ingredients are trimmed and de-duplicated', () {
    expect(Validators.parseIngredients(' Beef , cheese, beef,, Tomato '), ['Beef', 'cheese', 'Tomato']);
  });

  test('order status moves one step forward and Delivered is final', () {
    expect(OrderStatus.pending.next, OrderStatus.preparing);
    expect(OrderStatus.ready.next, OrderStatus.delivered);
    expect(OrderStatus.delivered.next, isNull);
    expect(OrderStatus.fromApi('Ready'), OrderStatus.ready);
  });
}
