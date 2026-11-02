import 'package:equatable/equatable.dart';

/// One line in the cart. The price here is only for display; the server calculates the real price.
class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
  });

  /// Same limit as the server.
  static const int minQuantity = 1;
  static const int maxQuantity = 50;

  final int productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;

  /// Price in cents (a whole number) to avoid decimal errors when adding.
  int get unitPriceCents => (unitPrice * 100).round();

  /// Line total in cents.
  int get lineTotalCents => unitPriceCents * quantity;

  /// Line total for display.
  double get lineTotal => lineTotalCents / 100;

  /// A new copy with a different quantity (the state is immutable).
  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
      );

  @override
  List<Object?> get props => [productId, name, unitPrice, quantity, imageUrl];
}
