import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/token_storage.dart';
import '../models/verification_response.dart';

class VerificationHistoryService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<VerificationResponse>> findMyHistory() async {
    final token = await _tokenStorage.getToken();

    if (token == null) {
      throw Exception(
        'Tu sesión ha expirado. Inicia sesión nuevamente.',
      );
    }

    final response = await http.get(
      Uri.parse(ApiConstants.verifications),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ??
            'No se pudo obtener el historial',
      );
    }

    final List<dynamic> data =
        body['data'] as List<dynamic>;

    return data
        .map(
          (item) =>
              VerificationResponse.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}