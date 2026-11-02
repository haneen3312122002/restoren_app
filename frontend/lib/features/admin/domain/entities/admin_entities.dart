import 'package:equatable/equatable.dart';

// The admin session after login.
class AdminSession extends Equatable {
  const AdminSession({
    required this.token,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  final String token;
  final String username;
  final String role;
  final DateTime expiresAt;

  // Has the token expired?
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  @override
  //to compare the session with another session
  List<Object?> get props => [token, username, role, expiresAt];
}

// A category (for the dropdown in the product form).
class Category extends Equatable {
  const Category({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// A product as the admin sees it (hidden ones too).
class AdminProduct extends Equatable {
  const AdminProduct({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.isAvailable,
    this.description,
    this.ingredients = const [],
    this.imageUrl,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final List<String> ingredients;
  final double price;
  final String? imageUrl;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, categoryId, categoryName, name, description, ingredients, price, imageUrl, isAvailable];
}

/// Product form data (same for add and edit).
class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.price,
    required this.categoryId,
    required this.isAvailable,
    this.description,
    this.ingredients = const [],
    this.imageUrl,
  });

  final String name;
  final String? description;
  final List<String> ingredients;
  final String price; // kept as text so we send it exactly as typed (no double rounding errors)
  final String? imageUrl;
  final int categoryId;
  final bool isAvailable;
}
