import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../services/payment_request_service.dart';
import 'payment_request_detail_page.dart';

class NewPaymentRequestPage extends StatefulWidget {
  final PaymentRequestService service;

  NewPaymentRequestPage({super.key, PaymentRequestService? service})
    : service = service ?? PaymentRequestService();

  @override
  State<NewPaymentRequestPage> createState() => _NewPaymentRequestPageState();
}

class _NewPaymentRequestPageState extends State<NewPaymentRequestPage> {
  final _amountController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final text = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto positivo.')),
      );
      return;
    }

    if (!RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usa maximo 2 decimales.')));
      return;
    }

    setState(() => _loading = true);

    try {
      final paymentRequest = await widget.service.create(
        amount: amount,
        clientRequestId:
            'mobile-${DateTime.now().microsecondsSinceEpoch.toString()}',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentRequestDetailPage(
            paymentRequest: paymentRequest,
            service: widget.service,
          ),
        ),
      );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Nuevo cobro',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppTextField(
            controller: _amountController,
            label: 'Monto',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.payments_rounded,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loading ? null : _create,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_card_rounded),
            label: const Text('Crear cobro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
