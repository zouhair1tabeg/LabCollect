import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';

/// Centralized API service using Dio with retry, logging, and token refresh
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Auth Interceptor ────────────────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secure.read(key: AppConstants.secureTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired — clear auth
            await _secure.deleteAll();
          }
          handler.next(error);
        },
      ),
    );

    // ── Retry Interceptor ───────────────────────────────
    _dio.interceptors.add(_RetryInterceptor(_dio));

    // ── Logging Interceptor (debug only) ────────────────
    if (kDebugMode) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

// ── Retry Interceptor ───────────────────────────────────

class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 3;
  static const List<int> _retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final isTimeout =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    // Don't retry on non-retryable errors
    if (!isTimeout &&
        (statusCode == null || !_retryableStatusCodes.contains(statusCode))) {
      return handler.next(err);
    }

    // Check retry count
    final retries = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if (retries >= _maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff delay
    final delayMs = 1000 * (1 << retries); // 1s, 2s, 4s
    await Future.delayed(Duration(milliseconds: delayMs));

    // Retry with incremented count
    final options = err.requestOptions;
    options.extra['retryCount'] = retries + 1;

    try {
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}

// ── Logging Interceptor ─────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    dev.log('→ ${options.method} ${options.uri}', name: 'API');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'API',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log(
      '✗ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.uri}: ${err.message}',
      name: 'API',
      error: err,
    );
    handler.next(err);
  }
}
