sealed class AppError implements Exception {
  const AppError([this.message]);
  final String? message;
}

final class NetworkError extends AppError {
  const NetworkError([super.message]);
}

final class UnexpectedError extends AppError {
  const UnexpectedError([super.message]);
}

final class ParsingError extends AppError {
  const ParsingError([super.message]);
}

final class ApiError extends AppError {
  const ApiError(this.statusCode, [String? message]) : super(message);
  final int statusCode;
}

final class ServerApiError extends AppError {
  const ServerApiError(this.statusCode, [String? message]) : super(message);
  final int statusCode;
}

// final class WrongRequestApiError extends ApiError {
//   const RateLimitApiError([String? message]) : super(429, message);
// }

// final class UnexpectedApiError extends ApiError {
//   const UnexpectedApiError([super.message]) : super(429, message);
// }

// TODO это переименовать
// плюс эти ошибки характерны конкретно для апи spoonacular
// final class PaymentRequiredError extends ApiError {
//   const PaymentRequiredError([String? message]) : super(402, message);
// }

// final class NotFoundApiError extends ApiError {
//   const NotFoundApiError([String? message]) : super(404, message);
// }
