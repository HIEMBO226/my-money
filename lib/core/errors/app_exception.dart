sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class ExportException extends AppException {
  const ExportException(super.message);
}

final class SecurityException extends AppException {
  const SecurityException(super.message);
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
