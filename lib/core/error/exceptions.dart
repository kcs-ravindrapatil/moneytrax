class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppDatabaseException extends AppException {
  const AppDatabaseException([super.message = 'Database operation failed.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed.']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Invalid input.']);
}

class ConsentException extends AppException {
  const ConsentException([super.message = 'Consent operation failed.']);
}
