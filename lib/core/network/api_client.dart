import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/auth/models/login_response.dart';
import '../../features/auth/services/token_storage.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
    : _httpClient = httpClient ?? http.Client(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;

  Future<dynamic> get(String url, {bool authenticated = false}) {
    return _send(method: 'GET', url: url, authenticated: authenticated);
  }

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) {
    return _send(
      method: 'POST',
      url: url,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    required bool authenticated,
    bool retrying = false,
  }) async {
    try {
      final response = await _request(
        method: method,
        url: url,
        body: body,
        authenticated: authenticated,
      );

      if (authenticated && response.statusCode == 401 && !retrying) {
        final refreshed = await _refreshTokens();

        if (refreshed) {
          return await _send(
            method: method,
            url: url,
            body: body,
            authenticated: authenticated,
            retrying: true,
          );
        }

        await _tokenStorage.clearTokens();
        throw const ApiException(
          'Tu sesion ha expirado. Inicia sesion nuevamente.',
          type: ApiErrorType.sessionExpired,
        );
      }

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con VerifiPay.',
        type: ApiErrorType.network,
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con VerifiPay.',
        type: ApiErrorType.network,
      );
    } on FormatException {
      throw const ApiException(
        'Respuesta invalida del servidor.',
        type: ApiErrorType.backend,
      );
    }
  }

  Future<http.Response> _request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    required bool authenticated,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.trim().isEmpty) {
        throw const ApiException(
          'Tu sesion ha expirado. Inicia sesion nuevamente.',
          type: ApiErrorType.sessionExpired,
        );
      }

      headers['Authorization'] = 'Bearer $accessToken';
    }

    final uri = Uri.parse(url);
    final encodedBody = body == null ? null : jsonEncode(body);

    return switch (method) {
      'GET' => _httpClient.get(uri, headers: headers),
      'POST' => _httpClient.post(uri, headers: headers, body: encodedBody),
      _ => throw UnsupportedError('Metodo HTTP no soportado: $method'),
    };
  }

  dynamic _decodeResponse(http.Response response) {
    final decoded = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message'] ?? 'No se pudo completar la solicitud.';

      throw ApiException(
        message,
        type: response.statusCode == 401
            ? ApiErrorType.sessionExpired
            : response.statusCode == 400 || response.statusCode == 403
            ? ApiErrorType.invalidCredentials
            : ApiErrorType.backend,
      );
    }

    return decoded['data'];
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return false;
    }

    try {
      final response = await _httpClient.post(
        Uri.parse(ApiConstants.refresh),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
