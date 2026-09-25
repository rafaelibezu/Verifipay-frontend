import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/verification_request.dart';
import '../models/verification_response.dart';

class VerificationService {
  VerificationService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<VerificationResponse> verifyYape(VerificationRequest request) async {
    final data = await _apiClient.post(
      ApiConstants.verifications,
      body: request.toJson(),
      authenticated: true,
    ) as Map<String, dynamic>;

    return VerificationResponse.fromJson(data);
  }
}
