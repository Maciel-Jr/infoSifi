class ApiConstants {
  // Construtor privado para impedir instanciar a classe
  ApiConstants._();

  // URL Base
  static const String baseUrl =
      'https://macieljuniormaximodevasconcelos.com/api/v1';

  // Endpoints específicos (opcional, mas recomendado)
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';
  static const String forgotPassword = '$baseUrl/auth/forgot-password/';
  static const String resetPassword = '$baseUrl/auth/reset-password/';
  static const String refresh = '$baseUrl/auth/token/refresh/';
  static const String tokenRefresh = '$baseUrl/token/refresh/';
  static const String atendimentosCreate = '$baseUrl/atendimentos/create/';
  static const String atendimentos = '$baseUrl/atendimentos/';
  static const String atendimentosDashboard =
      '$baseUrl/atendimentos/dashboard/';

  static String atendimento(int id) => '$atendimentos$id/';

  // Timeouts e configurações
  static const Duration connectTimeout = Duration(seconds: 15);
}
