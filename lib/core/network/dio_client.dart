import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule_app/core/env/app_config.dart';
import 'package:schedule_app/core/network/interceptors/retry_interceptor.dart';

Dio createDioClient(AppConfig config) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.connectTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxRetries: config.retries,
      baseDelay: const Duration(milliseconds: 300),
    ),
  );

  if (config.enableDebugLogs && !kReleaseMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  return dio;
}

