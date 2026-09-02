class ApiConstants {
  // Construtor privado para impedir instanciar a classe
  ApiConstants._();

  // URL Base
  static const String baseUrl = 'https://macieljuniormaximodevasconcelos.com/api/v1';
  
  // Endpoints específicos (opcional, mas recomendado)
  static const String login = '$baseUrl/auth/login/';
  static const String refresh = '$baseUrl/auth/refresh/';
  static const String tokenRefresh = '$baseUrl/token/refresh/';

  // Timeouts e configurações
  static const Duration connectTimeout = Duration(seconds: 15);
}