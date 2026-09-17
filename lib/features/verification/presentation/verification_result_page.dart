import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../models/verification_response.dart';
import 'verification_history_page.dart';

class VerificationResultPage extends StatelessWidget {
  const VerificationResultPage({super.key, required this.verification});

  final VerificationResponse verification;

  bool get isSuccess =>
      verification.status == 'DETECTED' || verification.status == 'VERIFIED';

  DateTime? get _displayDate =>
      verification.paymentTime ??
      verification.verifiedAt ??
      verification.createdAt;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.error;
    final icon = isSuccess ? Icons.check_rounded : Icons.close_rounded;
    final title = isSuccess ? 'Pago confirmado' : 'Pago no encontrado';
    final subtitle = isSuccess
        ? 'La operacion ha sido verificada\nen tiempo real.'
        : 'No se ha encontrado la operacion\nen Yape o en los bancos asociados.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.navy,
        ),
        title: const Text(
          'Resultado',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          children: [
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 54),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailsCard(),
            const SizedBox(height: 18),
            _buildActionBanner(),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (isSuccess) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isSuccess ? 'Nueva verificacion' : 'Intentar nuevamente',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isSuccess)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerificationHistoryPage(),
                    ),
                  );
                },
                child: const Text(
                  'Ver historial',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              )
            else
              SizedBox(
                height: 54,
                child: TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF0EFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Nueva verificacion',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF677099).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(
            'Monto',
            'S/ ${verification.amount.toStringAsFixed(2)}',
            bold: true,
          ),
          _divider(),
          _row('Metodo', _methodLabel(), asset: _methodAsset()),
          _divider(),
          _row(
            isSuccess ? 'N de operacion' : 'Referencia',
            verification.securityCode ?? verification.reference ?? '-',
          ),
          _divider(),
          _row(
            isSuccess ? 'Fecha' : 'Fecha de consulta',
            DateFormatters.date(_displayDate),
          ),
          _divider(),
          _row('Hora', DateFormatters.time(_displayDate)),
          if (isSuccess && verification.branchName.isNotEmpty) ...[
            _divider(),
            _row('Local', verification.branchName),
          ],
          if (isSuccess && verification.cashierName.isNotEmpty) ...[
            _divider(),
            _row('Cajero', verification.cashierName),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBanner() {
    final color = isSuccess ? AppColors.success : AppColors.error;
    final background = isSuccess
        ? const Color(0xFFDDF8E9)
        : const Color(0xFFFFDDE6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.warning_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              isSuccess
                  ? 'Puede entregar el producto\nEl pago ha sido confirmado.'
                  : 'No entregar el producto\nhasta confirmar\nVerifica los datos e intenta nuevamente o solicita un comprobante al cliente.',
              style: TextStyle(
                color: color,
                fontSize: 13,
                height: 1.22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, String? asset}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (asset != null) ...[
            Image.asset(asset, width: 26, height: 26),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: bold ? 17 : 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: AppColors.border);
  }

  String _methodAsset() {
    return verification.method.toUpperCase().contains('YAPE')
        ? AppAssets.yapeLogo
        : AppAssets.transferLogo;
  }

  String _methodLabel() {
    return verification.method.toUpperCase().contains('YAPE')
        ? 'Yape'
        : 'Transferencia';
  }
}
