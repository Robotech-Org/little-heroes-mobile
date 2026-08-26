abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    super.message, {
    this.statusCode,
  });
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection.',
  ]);
}

class CacheException extends AppException {
  const CacheException([
    super.message = 'Failed to access local storage.',
  ]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'You are not authorized.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}

class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Invalid data provided.',
  ]);
}

class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The request timed out.',
  ]);
}