import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../navigation/app_navigator.dart';
import '../storage/token_storage.dart';

class DioClient {
  DioClient._();

  static final Dio dio = _buildDio();
  static final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Completer<String?>? _refreshCompleter;

  static const List<String> _publicPaths = [
    '/auth/token/',
    '/auth/token/refresh/',
    '/auth/register/',
    '/auth/logout/',
  ];

  static Dio _buildDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    client.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth =
              (options.extra['requiresAuth'] as bool?) ?? true;

          if (!requiresAuth || _isPublicPath(options.path)) {
            handler.next(options);
            return;
          }

          final accessToken = await TokenStorage.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final statusCode = error.response?.statusCode;
          final requiresAuth =
              (requestOptions.extra['requiresAuth'] as bool?) ?? true;
          final alreadyRetried =
              (requestOptions.extra['retried'] as bool?) ?? false;

          final shouldTryRefresh = requiresAuth &&
              !_isPublicPath(requestOptions.path) &&
              statusCode == 401 &&
              !alreadyRetried;

          if (!shouldTryRefresh) {
            handler.next(error);
            return;
          }

          final newAccessToken = await _refreshAccessToken();

          if (newAccessToken == null || newAccessToken.isEmpty) {
            await TokenStorage.clearTokens();
            AppNavigator.toLoginAndClearStack();
            handler.next(error);
            return;
          }

          try {
            final newHeaders =
                Map<String, dynamic>.from(requestOptions.headers);
            newHeaders['Authorization'] = 'Bearer $newAccessToken';

            final response = await dio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              cancelToken: requestOptions.cancelToken,
              onSendProgress: requestOptions.onSendProgress,
              onReceiveProgress: requestOptions.onReceiveProgress,
              options: Options(
                method: requestOptions.method,
                headers: newHeaders,
                responseType: requestOptions.responseType,
                contentType: requestOptions.contentType,
                sendTimeout: requestOptions.sendTimeout,
                receiveTimeout: requestOptions.receiveTimeout,
                extra: {
                  ...requestOptions.extra,
                  'retried': true,
                },
              ),
            );

            handler.resolve(response);
          } catch (e) {
            await TokenStorage.clearTokens();
            AppNavigator.toLoginAndClearStack();
            handler.next(error);
          }
        },
      ),
    );

    return client;
  }

  static bool _isPublicPath(String path) {
    return _publicPaths.any((publicPath) => path.contains(publicPath));
  }

  static Future<String?> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final response = await _refreshDio.post(
        '/auth/token/refresh/',
        data: {
          'refresh': refreshToken,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final newAccess = data['access']?.toString();
      final newRefresh = data['refresh']?.toString() ?? refreshToken;

      if (newAccess == null || newAccess.isEmpty) {
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      _refreshCompleter!.complete(newAccess);
      return _refreshCompleter!.future;
    } catch (_) {
      _refreshCompleter!.complete(null);
      return _refreshCompleter!.future;
    } finally {
      Future.microtask(() {
        _refreshCompleter = null;
      });
    }
  }
}