import 'package:dio/dio.dart';

import '../models/menu_models.dart';

/// Calls the API to get the menu.
class MenuRemoteDataSource {
  const MenuRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/menu
  Future<List<MenuCategoryModel>> getMenu() async {
    final response = await _dio.get<List<dynamic>>('/api/menu');
    return (response.data ?? const [])
        .map((c) => MenuCategoryModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
