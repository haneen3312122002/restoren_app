import 'package:equatable/equatable.dart';

/// A product in the customer menu.
class MenuProduct extends Equatable {
  const MenuProduct({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.ingredients = const [],
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? description;
  final List<String> ingredients;
  final double price;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, description, ingredients, price, imageUrl];
}
