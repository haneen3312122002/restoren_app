// the kinds of errors the repositories can return.
// sealed, so any switch on it has to handle every kind.
sealed class Failure {
  const Failure(this.message);

  // a clear message we show to the user:
  final String message;
}

// can't reach the server:
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Cannot reach the server. Check your connection and try again.']);
}

// wrong data or a rule the server rejected (400), with per-field errors if there are any:
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  // field errors from the server (field name -> messages):
  final Map<String, List<String>> fieldErrors;
}

// not logged in, or the token expired (401):
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Your session has ended. Please log in again.']);
}

// the thing we asked for doesn't exist (404):
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

/// Any other error we didn't expect.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
