import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/verification_response.dart';

class VerificationDetailPage extends StatelessWidget {
  final VerificationResponse verification;

  const VerificationDetailPage({
    super.key,
    required this.verification,
  });

  @override
  Widget build(BuildContext context) {
    final success =
        verification.status == 'DETECTED' ||
        verification.status == 'VERIFIED';

    final color = success
        ? AppColors.success
        : verification.status == 'AMBIGUOUS'
            ? const Color(0xFFF59E0B)
            : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Detalle',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success
                    ? Icons.check_rounded
                    : Icons.close_rounded,
                color: color,
                size: 48,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              success
                  ? 'Pago detectado'
                  : 'Pago no encontrado',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              children: [
                _row(
                  'Monto',
                  'S/ ${verification.amount.toStringAsFixed(2)}',
                ),
                const Divider(height: 28),
                _row(
                  'Método',
                  verification.method,
                ),
                const Divider(height: 28),
                _row(
                  'Estado',
                  verification.status,
                ),
                if (verification.securityCode != null) ...[
                  const Divider(height: 28),
                  _row(
                    'Código',
                    verification.securityCode!,
                  ),
                ],
                if (verification.branchName.isNotEmpty) ...[
                  const Divider(height: 28),
                  _row(
                    'Local',
                    verification.branchName,
                  ),
                ],
                if (verification.cashierName.isNotEmpty) ...[
                  const Divider(height: 28),
                  _row(
                    'Cajero',
                    verification.cashierName,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}