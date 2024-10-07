import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../exceptions/api_exceptions.dart';

part 'http_client.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final options = BaseOptions(
    baseUrl: kApiUri,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  );

  final logger = PrettyDioLogger(
    logPrint: (o) => log,
    compact: true,
    maxWidth: 90,
    enabled: kDebugMode,
    filter: (options, args) => //
        !args.isResponse || !args.hasUint8ListData,
  );

  final client = Dio(options);

  client.interceptors
    ..add(logger)
    ..add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) {
          if (err.error is SocketException) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const NoInternetException(),
              ),
            );
          } else if (err.error is PlatformException) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const InternetPermissionException(),
              ),
            );
          } else if (err.type == DioExceptionType.connectionTimeout) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const TimedOut.request(),
              ),
            );
          } else if (err.type == DioExceptionType.receiveTimeout) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const TimedOut.respose(),
              ),
            );
          } else if (err.response?.statusCode == 400) {
            final description =
                err.response?.data['message'] ?? 'Unknown error';
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: BadRequest(description as String? ?? ''),
              ),
            );
          } else if (err.response?.statusCode == 401) {
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const Unauthorized(),
              ),
            );
          } else if (err.response?.statusCode == 404) {
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const NotFound(),
              ),
            );
          } else if (err.response?.statusCode == 429) {
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: const TooManyRequests(),
              ),
            );
          } else if (err.response != null) {
            final statusCode = err.response!.statusCode!;
            final reason = err.response?.data['reason'] ?? 'Unknown error';
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: err.type,
                error: ServerException(statusCode, reason as String? ?? ''),
              ),
            );
          }

          return handler.next(err);
        },
      ),
    );

  return client;
}
