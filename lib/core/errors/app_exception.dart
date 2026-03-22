import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class HttpRequestException extends AppException {
  const HttpRequestException(
    super.message, {
    this.statusCode,
  });

  final int? statusCode;
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class UnknownAppException extends AppException {
  const UnknownAppException(super.message);
}

AppException mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkException(
        'Request timed out. Please check your connection and retry.',
      );
    case DioExceptionType.connectionError:
      return const NetworkException(
        'Unable to connect to server. Please check your internet connection.',
      );
    case DioExceptionType.badResponse:
      final statusCode = exception.response?.statusCode;
      final message = _extractResponseError(exception.response?.data) ??
          'Server returned an invalid response.';
      return HttpRequestException(message, statusCode: statusCode);
    case DioExceptionType.cancel:
      return const NetworkException('Request was cancelled.');
    case DioExceptionType.badCertificate:
      return const NetworkException('Invalid SSL certificate.');
    case DioExceptionType.unknown:
      return UnknownAppException(exception.message ?? 'Unexpected network error.');
  }
}

String? _extractResponseError(dynamic data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'] ?? data['detail'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }
  return null;
}

