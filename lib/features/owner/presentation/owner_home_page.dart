import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../notification/presentation/receiver_setup_page.dart';

class OwnerHomePage extends StatelessWidget {
  final AuthUser user;
  final AuthService authService;

  OwnerHomePage({super.key, required this.user, AuthService? authService})
    : authService = authService ?? AuthService();

  Future<void> _logout(BuildContext context) async {
    await authService.logout();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyName = user.companyName?.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: Image.asset(
                      AppAssets.logoVerifipay,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Hola, ${user.name}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              companyName == null || companyName.isEmpty
                  ? 'OWNER'
                  : '$companyName - OWNER',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceiverSetupPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFEDE7FF),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receiver Device',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Configura o revisa el receptor Yape',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
