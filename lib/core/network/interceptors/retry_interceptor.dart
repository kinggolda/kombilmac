import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.maxRetries,
    required this.baseDelay,
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final currentAttempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (!_shouldRetry(err) || currentAttempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final nextAttempt = currentAttempt + 1;
    final nextDelay = baseDelay * nextAttempt;

    await Future<void>.delayed(nextDelay);

    try {
      final requestOptions = err.requestOptions;

      final options = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        followRedirects: requestOptions.followRedirects,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        validateStatus: requestOptions.validateStatus,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: {
          ...requestOptions.extra,
          'retry_attempt': nextAttempt,
        },
      );

      final response = await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
        cancelToken: requestOptions.cancelToken,
      );

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException error) {
    final type = error.type;
    final statusCode = error.response?.statusCode;

    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError) {
      return true;
    }

    if (type == DioExceptionType.badResponse && statusCode != null) {
      return statusCode >= 500;
    }

    return false;
  }
}

