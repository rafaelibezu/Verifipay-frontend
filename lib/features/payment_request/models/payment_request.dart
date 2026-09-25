enum PaymentRequestStatus {
  waiting('WAITING'),
  paid('PAID'),
  ambiguous('AMBIGUOUS'),
  expired('EXPIRED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const PaymentRequestStatus(this.value);

  final String value;

  static PaymentRequestStatus fromJson(String? value) {
    return PaymentRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentRequestStatus.unknown,
    );
  }
}

class PaymentRequest {
  final int id;
  final int companyId;
  final int? branchId;
  final int cashierId;
  final double amount;
  final PaymentRequestStatus status;
  final String clientRequestId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? paidAt;

  const PaymentRequest({
    required this.id,
    required this.companyId,
    required this.branchId,
    required this.cashierId,
    required this.amount,
    required this.status,
    required this.clientRequestId,
    required this.createdAt,
    required this.expiresAt,
    required this.paidAt,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      cashierId: json['cashierId'],
      amount: (json['amount'] as num).toDouble(),
      status: PaymentRequestStatus.fromJson(json['status'] as String?),
      clientRequestId: json['clientRequestId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
    );
  }

  bool get canCancel => status == PaymentRequestStatus.waiting;
}
