import 'package:dio/dio.dart';
import '../services/token_service.dart';
import 'auth_event_notifier.dart';

final dioClient = Dio(
  BaseOptions(
    baseUrl: 'https://api.thepetsocial.net',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.add(_AuthInterceptor());

class _AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final isRetry = err.requestOptions.extra['isRetry'] == true;

    if (is401 && !isRetry && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await TokenService.getRefreshToken();
        if (refreshToken != null) {
          final refreshDio = Dio(
            BaseOptions(baseUrl: 'https://api.thepetsocial.net'),
          );
          final response = await refreshDio.post(
            '/api/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          final newToken = response.data['token'] as String?;
          final newRefresh = response.data['refreshToken'] as String?;

          if (newToken != null) {
            await TokenService.saveToken(newToken);
            if (newRefresh != null) {
              await TokenService.saveRefreshToken(newRefresh);
            }
            final opts = err.requestOptions
              ..headers['Authorization'] = 'Bearer $newToken'
              ..extra['isRetry'] = true;
            final retried = await dioClient.fetch(opts);
            handler.resolve(retried);
            return;
          }
        }
      } catch (_) {
        // Refresh failed — fall through to logout
      } finally {
        _isRefreshing = false;
      }

      await TokenService.clear();
      AuthEventNotifier.instance.onUnauthorized();
    }

    handler.next(err);
  }
}
