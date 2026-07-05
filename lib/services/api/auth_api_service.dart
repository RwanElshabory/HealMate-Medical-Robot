import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../models/login_response_model.dart';

class AuthApiService {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      Endpoints.login,
      data: {
        "email": email,
        "password": password,
      },
    );

    final model = LoginResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    await ApiClient.setToken(model.token);
    await SecureStorageService.saveRole(model.role);
    await SecureStorageService.saveUserId(model.userId.toString());

    return model;
  }

  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    await ApiClient.dio.post(
      Endpoints.register,
      data: {
        "email": email,
        "password": password,
        "role": role,
      },
    );
  }

  Future<LoginResponseModel> getCurrentUser() async {
    final response = await ApiClient.dio.get(Endpoints.me);

    final data = Map<String, dynamic>.from(response.data);

    final normalized = {
      "token": await SecureStorageService.getToken() ?? "",
      "refreshToken": "",
      "expiration": "",
      "role": data["role"] ?? "",
      "user": {
        "id": data["id"] ?? 0,
        "email": data["email"] ?? "",
        "role": data["role"] ?? "",
      }
    };

    return LoginResponseModel.fromJson(normalized);
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
  }
}