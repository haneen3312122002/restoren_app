import '../../../../core/utils/result.dart';
import '../entities/menu_category.dart';

/// Where the menu data comes from.
abstract class MenuRepository {
  /// Gets the whole menu grouped by category.
  Future<Result<List<MenuCategory>>> getMenu();
}
