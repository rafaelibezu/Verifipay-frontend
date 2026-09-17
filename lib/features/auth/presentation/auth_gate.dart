import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

import '../../notification/presentation/notification_access_page.dart';
import '../../notification/services/notification_permission_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final NotificationPermissionService _notificationPermissionService =
      NotificationPermissionService();

  bool _notificationGranted = false;

  bool _loading = true;
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await _authService.getCurrentUser();

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _user = null;
        _notificationGranted = false;
        _loading = false;
      });

      return;
    }

    final notificationGranted = await _notificationPermissionService
        .isGranted();

    if (!mounted) {
      return;
    }

    setState(() {
      _user = user;
      _notificationGranted = notificationGranted;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _SplashPage();
    }

    if (_user != null) {
      if (!_notificationGranted) {
        return NotificationAccessPage(
          onGranted: () {
            setState(() {
              _notificationGranted = true;
            });
          },
        );
      }

      return HomePage(user: _user!);
    }

    return const LoginPage();
  }
}

class _SplashPage extends StatefulWidget {
  const _SplashPage();

  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.65, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppAssets.logoVerifipay,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Verificando tu sesión...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
