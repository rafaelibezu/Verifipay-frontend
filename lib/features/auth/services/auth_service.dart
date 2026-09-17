import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'token_storage.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<LoginResponse> login(
    LoginRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          request.toJson(),
        ),
      );

      final Map<String, dynamic> body =
          jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          body['message'] ??
              'No se pudo iniciar sesión',
        );
      }

      final data =
          body['data'] as Map<String, dynamic>;

      return LoginResponse.fromJson(data);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'No se pudo conectar con VerifiPay',
      );
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    final token =
        await _tokenStorage.getToken();

    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: {
          'Authorization':
              'Bearer $token',
          'Content-Type':
              'application/json',
        },
      );

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        await _tokenStorage.deleteToken();
        return null;
      }

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body);

      final data =
          body['data']
              as Map<String, dynamic>;

      return AuthUser.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}