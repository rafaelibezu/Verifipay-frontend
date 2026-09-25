import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/payment_request.dart';

String paymentRequestStatusLabel(PaymentRequestStatus status) {
  return switch (status) {
    PaymentRequestStatus.waiting => 'Pendiente',
    PaymentRequestStatus.paid => 'Pagado',
    PaymentRequestStatus.ambiguous => 'Ambiguo',
    PaymentRequestStatus.expired => 'Expirado',
    PaymentRequestStatus.cancelled => 'Cancelado',
    PaymentRequestStatus.unknown => 'Desconocido',
  };
}

Color paymentRequestStatusColor(PaymentRequestStatus status) {
  return switch (status) {
    PaymentRequestStatus.paid => AppColors.success,
    PaymentRequestStatus.waiting => AppColors.primary,
    PaymentRequestStatus.ambiguous => const Color(0xFFF59E0B),
    PaymentRequestStatus.expired ||
    PaymentRequestStatus.cancelled ||
    PaymentRequestStatus.unknown => AppColors.error,
  };
}

String formatPaymentAmount(double amount) => 'S/ ${amount.toStringAsFixed(2)}';
