// ============================================
// FILE: lib/services/api_service.dart
// ============================================

import 'package:dio/dio.dart';
import '../app.dart';
import '../config/api_config.dart';
import '../config/app_routes.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Inisialisasi interceptor untuk auto-attach token
  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized -> bersihkan sesi & redirect ke login.
          if (error.response?.statusCode == 401) {
            await StorageService.clearAll();
            final nav = appNavigatorKey.currentState;
            // Hindari menumpuk login berkali-kali bila beberapa request 401
            // bersamaan; pushNamedAndRemoveUntil mengosongkan stack.
            if (nav != null) {
              nav.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;
}
