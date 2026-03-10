/// Custom exception classes for structured error handling across the app.

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Thrown when there is no internet or network-related failure.
class NetworkException extends AppException {
  NetworkException([String message = 'فشل الاتصال بالإنترنت. يرجى التحقق من اتصالك.'])
      : super(message, code: 'NETWORK_ERROR');
}

/// Thrown when the server returns an unexpected error.
class ServerException extends AppException {
  final int? statusCode;
  ServerException([String message = 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.', this.statusCode])
      : super(message, code: 'SERVER_ERROR');
}

/// Thrown when data parsing fails.
class ParseException extends AppException {
  ParseException([String message = 'خطأ في معالجة البيانات.'])
      : super(message, code: 'PARSE_ERROR');
}

/// Thrown when request exceeds the allowed time.
class TimeoutException extends AppException {
  TimeoutException([String message = 'انتهت مهلة الاتصال. يرجى المحاولة لاحقاً.'])
      : super(message, code: 'TIMEOUT_ERROR');
}
