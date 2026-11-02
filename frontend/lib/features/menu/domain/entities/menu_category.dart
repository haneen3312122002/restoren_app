import 'package:equatable/equatable.dart';

import 'menu_product.dart';

/// A menu category with its available products.
class MenuCategory extends Equatable {
  const MenuCategory({required this.id, required this.name, required this.products});

  final int id;
  final String name;
  final List<MenuProduct> products;

  @override
  List<Object?> get props => [id, name, products];
}
