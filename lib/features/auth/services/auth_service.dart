import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'token_storage.dart';

class AuthService {
  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
    http.Client? httpClient,
  }) : _tokenStorage = tokenStorage ?? TokenStorage(),
       _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage),
       _httpClient = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final ApiClient _apiClient;
  final http.Client _httpClient;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ApiException(
          body['message'] ?? 'Credenciales invalidas.',
          type: response.statusCode == 401 || response.statusCode == 403
              ? ApiErrorType.invalidCredentials
              : ApiErrorType.backend,
        );
      }

      final data = body['data'] as Map<String, dynamic>;

      final loginResponse = LoginResponse.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      return loginResponse;
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

  Future<AuthUser?> getCurrentUser() async {
    final token = await _tokenStorage.getAccessToken();

    if (token == null) {
      return null;
    }

    try {
      final data = await _apiClient.get(
        ApiConstants.me,
        authenticated: true,
      ) as Map<String, dynamic>;

      return AuthUser.fromJson(data);
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.sessionExpired) {
        await _tokenStorage.clearTokens();
      }

      return null;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.trim().isNotEmpty) {
        await _httpClient.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } finally {
      await _tokenStorage.clearTokens();
    }
  }
}
