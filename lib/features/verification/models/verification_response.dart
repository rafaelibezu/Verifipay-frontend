class VerificationResponse {
  final int id;
  final String method;
  final double amount;
  final String status;
  final String? reference;
  final String? securityCode;
  final DateTime? paymentTime;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final String cashierName;
  final String branchName;

  const VerificationResponse({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
    this.reference,
    this.securityCode,
    this.paymentTime,
    this.verifiedAt,
    this.createdAt,
    required this.cashierName,
    required this.branchName,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      id: json['id'],
      method: json['method'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      reference: json['reference'],
      securityCode: json['securityCode'],
      paymentTime: json['paymentTime'] != null
          ? DateTime.parse(json['paymentTime'])
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      cashierName: json['cashierName'] ?? '',
      branchName: json['branchName'] ?? '',
    );
  }
}
