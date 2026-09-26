import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/receiver_device.dart';
import '../models/receiver_device_current.dart';

class ReceiverDeviceService {
  ReceiverDeviceService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ReceiverDeviceCurrent?> getCurrentReceiver() async {
    try {
      final data = await _apiClient.get(
        '${ApiConstants.ownerReceiverDevices}/current',
        authenticated: true,
      ) as Map<String, dynamic>;

      return ReceiverDeviceCurrent.fromJson(data);
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<ReceiverDevice> create({
    required int branchId,
    required String name,
  }) async {
    final data = await _apiClient.post(
      ApiConstants.ownerReceiverDevices,
      authenticated: true,
      body: {'branchId': branchId, 'name': name},
    ) as Map<String, dynamic>;

    return ReceiverDevice.fromJson(data);
  }

  Future<void> deactivate(int id) async {
    await _apiClient.patch(
      '${ApiConstants.ownerReceiverDevices}/$id/status',
      authenticated: true,
    );
  }
}
