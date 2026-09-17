import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/notification_permission_service.dart';

class NotificationAccessPage
    extends StatefulWidget {
  final VoidCallback onGranted;

  const NotificationAccessPage({
    super.key,
    required this.onGranted,
  });

  @override
  State<NotificationAccessPage> createState() =>
      _NotificationAccessPageState();
}

class _NotificationAccessPageState
    extends State<NotificationAccessPage>
    with WidgetsBindingObserver {
  final NotificationPermissionService
      _permissionService =
      NotificationPermissionService();

  bool _checking = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _openSettings() async {
    await _permissionService.openSettings();
  }

  Future<void> _checkPermission() async {
    if (_checking) {
      return;
    }

    setState(() {
      _checking = true;
    });

    final granted =
        await _permissionService.isGranted();

    if (!mounted) {
      return;
    }

    setState(() {
      _checking = false;
    });

    if (granted) {
      widget.onGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8163FF),
                      Color(0xFF4F20F6),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary
                          .withValues(
                        alpha: 0.22,
                      ),
                      blurRadius: 28,
                      offset:
                          const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 52,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Detecta pagos automáticamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'VerifiPay necesita acceso a las notificaciones para detectar los pagos de Yape recibidos en este dispositivo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 30),

              _item(
                Icons.payments_outlined,
                'Detectar pagos recibidos',
              ),

              const SizedBox(height: 14),

              _item(
                Icons.lock_outline_rounded,
                'El acceso se configura directamente en Android',
              ),

              const SizedBox(height: 14),

              _item(
                Icons.visibility_off_outlined,
                'VerifiPay procesará únicamente las notificaciones necesarias para validar pagos',
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      _checking
                          ? null
                          : _openSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Activar acceso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed:
                    _checking
                        ? null
                        : _checkPermission,
                child: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Ya lo activé',
                      ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0ECFF),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 9),
            child: Text(
              text,
              style: const TextStyle(
                color:
                    AppColors.textPrimary,
                fontWeight:
                    FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}