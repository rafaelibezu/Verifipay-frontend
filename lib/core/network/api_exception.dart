enum ApiErrorType { invalidCredentials, sessionExpired, network, backend }

class ApiException implements Exception {
  const ApiException(this.message, {required this.type, this.statusCode});

  final String message;
  final ApiErrorType type;
  final int? statusCode;

  @override
  String toString() => message;
}
