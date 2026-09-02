

class AuthResponse {
  final String refreshToken;
  final String accessToken;

  AuthResponse({required this.refreshToken, required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      refreshToken: json['refreshToken'],
      accessToken: json['accessToken'],
    );
  }



}