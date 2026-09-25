import 'payment_request.dart';

class PaymentRequestPage {
  final List<PaymentRequest> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  const PaymentRequestPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PaymentRequestPage.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>? ?? [];

    return PaymentRequestPage(
      content: content
          .map((item) => PaymentRequest.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
    );
  }
}
