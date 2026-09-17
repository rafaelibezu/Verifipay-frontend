import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/presentation/auth_gate.dart';

void main() {
  runApp(
    const VerifiPayApp(),
  );
}

class VerifiPayApp
    extends StatelessWidget {
  const VerifiPayApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,
      title: 'VerifiPay',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            AppColors.background,
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              AppColors.primary,
        ),
      ),
      home: const AuthGate(),
    );
  }
}