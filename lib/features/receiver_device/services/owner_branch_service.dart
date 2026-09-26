import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/owner_branch.dart';

class OwnerBranchService {
  OwnerBranchService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<OwnerBranch>> findAll() async {
    final data = await _apiClient.get(
      ApiConstants.ownerBranches,
      authenticated: true,
    ) as List<dynamic>;

    return data
        .map((item) => OwnerBranch.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
