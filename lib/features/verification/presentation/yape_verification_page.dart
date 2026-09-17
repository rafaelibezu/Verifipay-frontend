import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../models/verification_request.dart';
import 'verification_loading_page.dart';

class YapeVerificationPage
    extends StatefulWidget {
  const YapeVerificationPage({
    super.key,
  });

  @override
  State<YapeVerificationPage> createState() =>
      _YapeVerificationPageState();
}

class _YapeVerificationPageState
    extends State<YapeVerificationPage> {
  final _formKey =
      GlobalKey<FormState>();

  final _amountController =
      TextEditingController();

  final _securityCodeController =
      TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  void _verify() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(
      _amountController.text
          .replaceAll(',', '.'),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VerificationLoadingPage(
          request: VerificationRequest(
            amount: amount,
            securityCode:
                _securityCodeController
                        .text
                        .trim()
                        .isEmpty
                    ? null
                    : _securityCodeController
                        .text
                        .trim(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.navy,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Verificar Yape',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(0xFF794EFF),
                        Color(0xFF5123E9),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor:
                            Colors.white,
                        child: Icon(
                          Icons
                              .payments_outlined,
                          color:
                              AppColors.primary,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Pago por Yape',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ingresa los datos del pago para comprobarlo.',
                        style: TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Monto recibido',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller:
                      _amountController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(
                      RegExp(r'[0-9.,]'),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                  decoration:
                      InputDecoration(
                    prefixText: 'S/  ',
                    hintText: '0.00',
                    prefixStyle:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppColors.primary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.border,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.primary,
                        width: 1.6,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa el monto';
                    }

                    final amount =
                        double.tryParse(
                      value.replaceAll(
                        ',',
                        '.',
                      ),
                    );

                    if (amount == null ||
                        amount <= 0) {
                      return 'Ingresa un monto válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Código de seguridad',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Opcional. Ayuda a identificar el pago con mayor precisión.',
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller:
                      _securityCodeController,
                  keyboardType:
                      TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                  decoration:
                      InputDecoration(
                    hintText:
                        'Ej. 382',
                    prefixIcon:
                        const Icon(
                      Icons
                          .lock_outline_rounded,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.border,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.primary,
                        width: 1.6,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _verify,
                    style:
                        ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Verificar pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFF1EEFF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons
                            .verified_user_outlined,
                        color:
                            AppColors.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'VerifiPay valida el pago usando eventos reales registrados por el sistema.',
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}