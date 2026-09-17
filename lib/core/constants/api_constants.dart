class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';
  static const String login = '$baseUrl/auth/login';

  static const String me = '$baseUrl/auth/me';

  static const String verifications = '$baseUrl/verifications';
}
