class LoginResponseModel {
  final String token;
  final String refreshToken;
  final String expiration;
  final String role;
  final int userId;
  final String email;

  LoginResponseModel({
    required this.token,
    required this.refreshToken,
    required this.expiration,
    required this.role,
    required this.userId,
    required this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final user = (json["user"] as Map<String, dynamic>? ?? {});

    return LoginResponseModel(
      token: json["token"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
      expiration: json["expiration"] ?? "",
      role: json["role"] ?? user["role"] ?? "",
      userId: user["id"] ?? 0,
      email: user["email"] ?? "",
    );
  }
}