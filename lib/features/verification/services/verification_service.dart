import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/token_storage.dart';
import '../models/verification_request.dart';
import '../models/verification_response.dart';

class VerificationService {
  final TokenStorage _tokenStorage =
      TokenStorage();

  Future<VerificationResponse> verifyYape(
    VerificationRequest request,
  ) async {
    final token =
        await _tokenStorage.getToken();

    if (token == null) {
      throw Exception(
        'Tu sesión ha expirado. Inicia sesión nuevamente.',
      );
    }

    try {
      final response = await http.post(
        Uri.parse(
          ApiConstants.verifications,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
              'No se pudo verificar el pago',
        );
      }

      return VerificationResponse.fromJson(
        body['data'],
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'No se pudo conectar con VerifiPay',
      );
    }
  }
}