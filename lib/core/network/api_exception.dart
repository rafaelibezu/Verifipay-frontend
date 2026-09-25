enum ApiErrorType { invalidCredentials, sessionExpired, network, backend }

class ApiException implements Exception {
  const ApiException(this.message, {required this.type});

  final String message;
  final ApiErrorType type;

  @override
  String toString() => message;
}
