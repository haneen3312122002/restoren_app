import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../../features/admin/presentation/providers/auth_providers.dart';

/// 
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_isAdminCall(options.path)) {
          final token = ref.read(authViewModelProvider)?.token;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401 && _isAdminCall(error.requestOptions.path)) {
          ref.read(authViewModelProvider.notifier).logout();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

// is this request for a protected admin path?
bool _isAdminCall(String path) => path.startsWith('/api/admin');
