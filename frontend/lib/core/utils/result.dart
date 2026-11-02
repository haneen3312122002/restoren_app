import '../errors/failures.dart';

// the result of something that can succeed or fail, instead of throwing exceptions up.
///
/// ```dart
/// switch (await repository.getMenu()) {
///   case Success(:final value): ...
///   case ResultFailure(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();
}

//it worked, here is the value.
class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

// it failed, here is why.
class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}

// helper methods on [Result].
extension ResultX<T> on Result<T> {
  // Returns the value or throws the [Failure]. Useful inside a FutureProvider
  /// so the error reaches the UI as an AsyncError.
  T getOrThrow() => switch (this) {
        Success(:final value) => value,
        ResultFailure(:final failure) => throw failure,
      };
}
