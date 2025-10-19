sealed class AppError implements Exception {
  const AppError([this.message, this.original]);
  final String? message;
  final dynamic original;

  @override
  String toString() => '$runtimeType(message: $message, original: $original)';
}

final class NetworkError extends AppError {
  const NetworkError([super.message, super.original]);
}

final class UnexpectedError extends AppError {
  const UnexpectedError([super.message, super.original]);
}

final class ParsingError extends AppError {
  const ParsingError([super.message, super.original]);
}

abstract class ApiError extends AppError {
  const ApiError(this.statusCode, [super.message, super.original]);
  final int statusCode;

  @override
  String toString() =>
      '$runtimeType(code: $statusCode, message: $message, original: $original)';
}

final class ClientApiError extends ApiError {
  const ClientApiError(super.statusCode, [super.message, super.original]);
}

final class ServerApiError extends ApiError {
  const ServerApiError(super.statusCode, [super.message, super.original]);
}
