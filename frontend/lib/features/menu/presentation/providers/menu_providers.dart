import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/menu_remote_data_source.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/repositories/menu_repository.dart';

/// The menu repository.
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(MenuRemoteDataSource(ref.watch(dioProvider)));
});

/// The whole menu. Loaded once; filtering happens in the app without a new request.
final menuProvider = FutureProvider.autoDispose<List<MenuCategory>>((ref) async {
  final result = await ref.watch(menuRepositoryProvider).getMenu();
  return result.getOrThrow();
});

/// The selected category in the category bar (null = all).
final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, int?>(SelectedCategoryNotifier.new);

/// Keeps the selected category.
class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  /// Selects a category, or null for "All".
  void select(int? categoryId) => state = categoryId;
}
