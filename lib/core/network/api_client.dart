import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static Future<void> init() async {
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers["Authorization"] = "Bearer $token";
    }
  }

  static Future<void> setToken(String token) async {
    dio.options.headers["Authorization"] = "Bearer $token";
    await SecureStorageService.saveToken(token);
  }

  static Future<void> clearToken() async {
    dio.options.headers.remove("Authorization");
    await SecureStorageService.clearAll();
  }
}