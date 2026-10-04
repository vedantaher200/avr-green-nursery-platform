import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Single authenticated API client used by repositories/providers, never widgets.
class ApiClient {
  ApiClient(this._storage)
      : dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment('API_URL',
              defaultValue: 'http://localhost:5000/api/v1/'),
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'application/json'},
        ));

  final FlutterSecureStorage _storage;
  final Dio dio;

  void configure() {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      if (options.path.startsWith('/')) {
        options.path = options.path.substring(1);
      }
      final token = await _storage.read(key: 'access_token');
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
  }
}
