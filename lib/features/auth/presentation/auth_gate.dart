import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
  });

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}

class _AuthGateState
    extends State<AuthGate> {
  final AuthService _authService =
      AuthService();

  bool _loading = true;
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user =
        await _authService
            .getCurrentUser();

    if (!mounted) {
      return;
    }

    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _SplashPage();
    }

    if (_user != null) {
      return HomePage(
        user: _user!,
      );
    }

    return const LoginPage();
  }
}

class _SplashPage
    extends StatefulWidget {
  const _SplashPage();

  @override
  State<_SplashPage> createState() =>
      _SplashPageState();
}

class _SplashPageState
    extends State<_SplashPage>
    with
        SingleTickerProviderStateMixin {
  late AnimationController
      _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 1300,
      ),
    )..repeat(
            reverse: true,
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.65,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent:
                  _controller,
              curve:
                  Curves.easeInOut,
            ),
          ),
          child:
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent:
                    _controller,
                curve:
                    Curves.easeInOut,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment
                              .bottomRight,
                      colors: [
                        Color(
                          0xFF8163FF,
                        ),
                        Color(
                          0xFF4F20F6,
                        ),
                      ],
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      27,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors
                            .primary
                            .withValues(
                          alpha: 0.22,
                        ),
                        blurRadius:
                            26,
                        offset:
                            const Offset(
                          0,
                          12,
                        ),
                      ),
                    ],
                  ),
                  child:
                      const Icon(
                    Icons
                        .check_rounded,
                    color:
                        Colors.white,
                    size: 58,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'VerifiPay',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.navy,
                    letterSpacing:
                        -1,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Verificando tu sesión...',
                  style: TextStyle(
                    color:
                        AppColors
                            .textSecondary,
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