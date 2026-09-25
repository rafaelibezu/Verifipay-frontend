import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/payment_request.dart';
import '../models/payment_request_page.dart';

class PaymentRequestService {
  PaymentRequestService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PaymentRequest> create({
    required double amount,
    required String clientRequestId,
  }) async {
    final data = await _apiClient.post(
      ApiConstants.paymentRequests,
      authenticated: true,
      body: {
        'amount': double.parse(amount.toStringAsFixed(2)),
        'clientRequestId': clientRequestId,
      },
    ) as Map<String, dynamic>;

    return PaymentRequest.fromJson(data);
  }

  Future<PaymentRequestPage> findMine({int page = 0, int size = 20}) async {
    final data = await _apiClient.get(
      '${ApiConstants.paymentRequests}?page=$page&size=$size',
      authenticated: true,
    ) as Map<String, dynamic>;

    return PaymentRequestPage.fromJson(data);
  }

  Future<PaymentRequest> findMineById(int id) async {
    final data = await _apiClient.get(
      '${ApiConstants.paymentRequests}/$id',
      authenticated: true,
    ) as Map<String, dynamic>;

    return PaymentRequest.fromJson(data);
  }

  Future<PaymentRequest> cancel(int id) async {
    final data = await _apiClient.post(
      '${ApiConstants.paymentRequests}/$id/cancel',
      authenticated: true,
    ) as Map<String, dynamic>;

    return PaymentRequest.fromJson(data);
  }
}
