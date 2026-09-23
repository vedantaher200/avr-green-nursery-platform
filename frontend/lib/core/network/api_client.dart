import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Single authenticated API client used by repositories/providers, never widgets.
class ApiClient {
  ApiClient(this._storage)
      : dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment('API_URL',
              // `localhost` works for Flutter web and Windows, which are the
              // supported local-development targets. Android emulators should
              // supply `--dart-define=API_URL=http://10.0.2.2:5000/api/v1`.
              defaultValue: 'http://localhost:5000/api/v1'),
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'application/json'},
        ));

  final FlutterSecureStorage _storage;
  final Dio dio;

  void configure() {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await _storage.read(key: 'access_token');
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
  }
}
