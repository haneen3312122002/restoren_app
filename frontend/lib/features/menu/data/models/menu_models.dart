import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_product.dart';

/// Menu product from JSON.
class MenuProductModel extends MenuProduct {
  const MenuProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.description,
    super.ingredients,
    super.imageUrl,
  });

  factory MenuProductModel.fromJson(Map<String, dynamic> json) {
    return MenuProductModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List? ?? const []).map((e) => e.toString()).toList(),
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Menu category (with its products) from JSON.
class MenuCategoryModel extends MenuCategory {
  const MenuCategoryModel({required super.id, required super.name, required super.products});

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      products: (json['products'] as List? ?? const [])
          .map((p) => MenuProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
