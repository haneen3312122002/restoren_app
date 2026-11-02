import '../../domain/entities/admin_entities.dart';

/// JSON conversions for the admin entities.
class AdminModels {
  const AdminModels._();

  /// Login response -> session.
  static AdminSession sessionFromJson(Map<String, dynamic> json) => AdminSession(
        token: json['token'] as String,
        username: json['username'] as String? ?? '',
        role: json['role'] as String? ?? '',
        expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
      );

  /// Session -> JSON (to save in shared_preferences).
  static Map<String, dynamic> sessionToJson(AdminSession s) => {
        'token': s.token,
        'username': s.username,
        'role': s.role,
        'expiresAt': s.expiresAt.toIso8601String(),
      };

  /// Category from JSON.
  static Category categoryFromJson(Map<String, dynamic> json) =>
      Category(id: json['id'] as int, name: json['name'] as String? ?? '');

  /// Admin product from JSON.
  static AdminProduct productFromJson(Map<String, dynamic> json) => AdminProduct(
        id: json['id'] as int,
        categoryId: json['categoryId'] as int,
        categoryName: json['categoryName'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        ingredients: (json['ingredients'] as List? ?? const []).map((e) => e.toString()).toList(),
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        isAvailable: json['isAvailable'] as bool? ?? true,
      );

  /// Product form -> JSON.
  static Map<String, dynamic> draftToJson(ProductDraft d) => {
        'name': d.name.trim(),
        'description': (d.description?.trim().isEmpty ?? true) ? null : d.description!.trim(),
        'ingredients': d.ingredients,
        'price': num.parse(d.price.trim()),
        'imageUrl': (d.imageUrl?.trim().isEmpty ?? true) ? null : d.imageUrl!.trim(),
        'categoryId': d.categoryId,
        'isAvailable': d.isAvailable,
      };
}
