class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'http://192.168.100.13:8080/api/v1';

  static const String login =
      '$baseUrl/auth/login';

  static const String me =
      '$baseUrl/auth/me';

  static const String verifications =
      '$baseUrl/verifications';
}