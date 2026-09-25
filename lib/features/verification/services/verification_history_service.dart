import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/verification_response.dart';

class VerificationHistoryService {
  VerificationHistoryService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<VerificationResponse>> findMyHistory() async {
    final data = await _apiClient.get(
      ApiConstants.verifications,
      authenticated: true,
    ) as List<dynamic>;

    return data
        .map(
          (item) => VerificationResponse.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
