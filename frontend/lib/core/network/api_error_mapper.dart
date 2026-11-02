import 'package:dio/dio.dart';

import '../errors/failures.dart';
import '../utils/result.dart';

// turns Dio errors into a clear [Failure] and reads the server's error message.
class ApiErrorMapper {
  const ApiErrorMapper._();

  // turns any error into a Failure:
  static Failure map(Object error) {
    if (error is Failure) return error;
    if (error is! DioException) return const UnknownFailure();

    final response = error.response;
    if (response == null) return const NetworkFailure();

    final data = response.data;
    final fieldErrors = _readFieldErrors(data);
    final message = _readMessage(data, fieldErrors);

    switch (response.statusCode) {
      case 400:
        return ValidationFailure(message ?? 'Please check the entered data.', fieldErrors: fieldErrors);
      case 401:
        return message != null ? AuthFailure(message) : const AuthFailure();
      case 404:
        return NotFoundFailure(message ?? 'Not found.');
      case 429:
        return UnknownFailure(message ?? 'Too many requests. Please wait a moment.');
      default:
        return UnknownFailure(message ?? 'Something went wrong. Please try again.');
    }
  }

  /// Runs a request and returns a [Result] instead of throwing. Used in all repositories.
  static Future<Result<T>> guard<T>(Future<T> Function() call) async {
    try {
      return Success(await call());
    } catch (e) {
      return ResultFailure(map(e));
    }
  }

  /// Reads `errors` from the ASP.NET validation response.
  static Map<String, List<String>> _readFieldErrors(dynamic data) {
    if (data is! Map || data['errors'] is! Map) return const {};
    final errors = data['errors'] as Map;
    return {
      for (final entry in errors.entries)
        entry.key.toString(): (entry.value is List)
            ? (entry.value as List).map((e) => e.toString()).toList()
            : [entry.value.toString()],
    };
  }

  /// Takes `message`, or the field messages, or `title`.
  static String? _readMessage(dynamic data, Map<String, List<String>> fieldErrors) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (fieldErrors.isNotEmpty) return fieldErrors.values.expand((m) => m).join('\n');
      final title = data['title'];
      if (title is String && title.isNotEmpty) return title;
    }
    if (data is String && data.isNotEmpty && data.length < 300) return data;
    return null;
  }
}
