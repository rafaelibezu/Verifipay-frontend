class VerificationRequest {
  final double amount;
  final String? reference;
  final String? securityCode;

  const VerificationRequest({
    required this.amount,
    this.reference,
    this.securityCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': 'YAPE',
      'amount': amount,
      'reference': reference,
      'securityCode': securityCode,
    };
  }
}