class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'VERIFIPAY_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static const String login = '$baseUrl/auth/login';

  static const String refresh = '$baseUrl/auth/refresh';

  static const String logout = '$baseUrl/auth/logout';

  static const String me = '$baseUrl/auth/me';

  static const String verifications = '$baseUrl/verifications';
}
