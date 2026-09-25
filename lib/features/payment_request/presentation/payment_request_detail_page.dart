import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../models/payment_request.dart';
import '../services/payment_request_service.dart';
import 'payment_request_ui.dart';

class PaymentRequestDetailPage extends StatefulWidget {
  final PaymentRequest paymentRequest;
  final PaymentRequestService service;

  PaymentRequestDetailPage({
    super.key,
    required this.paymentRequest,
    PaymentRequestService? service,
  }) : service = service ?? PaymentRequestService();

  @override
  State<PaymentRequestDetailPage> createState() =>
      _PaymentRequestDetailPageState();
}

class _PaymentRequestDetailPageState extends State<PaymentRequestDetailPage> {
  late PaymentRequest _paymentRequest = widget.paymentRequest;
  bool _loading = false;

  Future<void> _refresh() async {
    await _run(() => widget.service.findMineById(_paymentRequest.id));
  }

  Future<void> _cancel() async {
    await _run(() => widget.service.cancel(_paymentRequest.id));
  }

  Future<void> _run(Future<PaymentRequest> Function() action) async {
    setState(() => _loading = true);

    try {
      final result = await action();
      if (!mounted) return;
      setState(() => _paymentRequest = result);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = paymentRequestStatusColor(_paymentRequest.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Detalle del cobro',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatPaymentAmount(_paymentRequest.amount),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _StatusChip(paymentRequest: _paymentRequest),
                const SizedBox(height: 18),
                _row('Codigo', _paymentRequest.clientRequestId),
                _row(
                  'Creado',
                  DateFormatters.dateTime(_paymentRequest.createdAt),
                ),
                _row(
                  'Expira',
                  DateFormatters.dateTime(_paymentRequest.expiresAt),
                ),
                if (_paymentRequest.paidAt != null)
                  _row(
                    'Pagado',
                    DateFormatters.dateTime(_paymentRequest.paidAt),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loading ? null : _refresh,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar estado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          if (_paymentRequest.canCancel) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _cancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar cobro'),
              style: OutlinedButton.styleFrom(
                foregroundColor: statusColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PaymentRequest paymentRequest;

  const _StatusChip({required this.paymentRequest});

  @override
  Widget build(BuildContext context) {
    final color = paymentRequestStatusColor(paymentRequest.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        paymentRequestStatusLabel(paymentRequest.status),
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}
