import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

/// [MenuRepository] implementation using the API.
class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._remote);

  final MenuRemoteDataSource _remote;

  @override
  Future<Result<List<MenuCategory>>> getMenu() => ApiErrorMapper.guard(_remote.getMenu);
}
