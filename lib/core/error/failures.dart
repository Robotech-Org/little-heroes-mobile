abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Failed to access local storage.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'You are not authorized.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request timed out.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong.',
  ]);
}