import 'package:flutter/material.dart';

import '../../owner/presentation/owner_home_page.dart';
import '../../payment_request/presentation/cashier_home_page.dart';
import '../../platform_admin/presentation/platform_admin_mobile_home_page.dart';
import '../models/auth_user.dart';
import 'home_page.dart';

class RoleHomePage extends StatelessWidget {
  final AuthUser user;

  const RoleHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return switch (user.role) {
      'CASHIER' => CashierHomePage(user: user),
      'OWNER' => OwnerHomePage(user: user),
      'PLATFORM_ADMIN' => PlatformAdminMobileHomePage(user: user),
      _ => HomePage(user: user),
    };
  }
}
