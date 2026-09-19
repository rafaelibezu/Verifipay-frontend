import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../verification/models/verification_response.dart';
import '../../verification/presentation/yape_verification_page.dart';
import '../../verification/services/verification_history_service.dart';
import '../models/auth_user.dart';
import '../../verification/presentation/verification_history_page.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import '../../notification/presentation/receiver_setup_page.dart';

class HomePage extends StatefulWidget {
  final AuthUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  final VerificationHistoryService _historyService =
      VerificationHistoryService();

  List<VerificationResponse> _verifications = [];

  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _refreshHome();
  }

  Future<void> _refreshHome() async {
    await _loadHistory();
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _loadHistory() async {
    try {
      final result = await _historyService.findMyHistory();

      if (!mounted) {
        return;
      }

      setState(() {
        _verifications = result.take(5).toList();
        _loadingHistory = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingHistory = false;
      });
    }
  }

  Future<void> _openYape() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const YapeVerificationPage()),
    );

    await _refreshHome();
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerificationHistoryPage()),
    );
  }

  void _openProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D2050).withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.phone_android_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Configurar receptor Yape',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReceiverSetupPage(),
                      ),
                    );
                  },
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _logout();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesion'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: Color(0xFFFFCDD2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleBottomMenuTap(int index) {
    switch (index) {
      case 1:
        _openHistory();
        break;
      case 2:
        _openProfileSheet();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: Image.asset(
                        AppAssets.logoVerifipay,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        _logout();
                      }
                    },
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.user.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.error),
                            SizedBox(width: 10),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 92),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Hola',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                widget.user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 34),

              const Text(
                '¿Qué deseas verificar?',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 28),

              _buildVerificationOption(
                title: 'Yape',
                subtitle: 'Verificar pago por Yape',
                asset: AppAssets.yapeLogo,
                onTap: _openYape,
                isPrimary: true,
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimas verificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  if (_verifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _openHistory();
                      },
                      child: const Text('Ver todas'),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (_loadingHistory)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_verifications.isEmpty)
                _buildEmptyHistory()
              else
                ..._verifications.map(_buildVerificationCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF40477A).withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildBottomNavigationItem(
              icon: Icons.home_rounded,
              label: 'Inicio',
              isSelected: true,
              onTap: () => _handleBottomMenuTap(0),
            ),
            _buildBottomNavigationItem(
              icon: Icons.history_rounded,
              label: 'Historial',
              onTap: () => _handleBottomMenuTap(1),
            ),
            _buildBottomNavigationItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              onTap: () => _handleBottomMenuTap(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final Color color = isSelected
        ? AppColors.primary
        : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationOption({
    required String title,
    required String subtitle,
    required String asset,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final Color titleColor = isPrimary ? Colors.white : AppColors.navy;
    final Color subtitleColor = isPrimary
        ? Colors.white.withValues(alpha: 0.78)
        : AppColors.textSecondary;
    final Color arrowColor = isPrimary ? Colors.white : AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 104,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: isPrimary ? null : const Color(0xFFF1F3FF),
          gradient: isPrimary
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7B35FF), Color(0xFF551FFF)],
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.24)
                  : const Color(0xFF7078B7).withValues(alpha: 0.12),
              blurRadius: isPrimary ? 24 : 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textSecondary,
            size: 35,
          ),
          SizedBox(height: 12),
          Text(
            'Aquí aparecerán tus últimas verificaciones',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(VerificationResponse verification) {
    final bool success =
        verification.status == 'DETECTED' || verification.status == 'VERIFIED';

    final Color statusColor = success
        ? AppColors.success
        : verification.status == 'AMBIGUOUS'
        ? const Color(0xFFF59E0B)
        : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Image.asset(
                _methodAsset(verification.method),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _statusIcon(verification.status),
                    color: statusColor,
                    size: 20,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S/ ${verification.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _methodLabel(verification.method),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _timeAgo(
                    verification.verifiedAt ??
                        verification.paymentTime ??
                        verification.createdAt,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: _statusChipBackground(verification.status),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _statusLabel(verification.status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'DETECTED':
      case 'VERIFIED':
        return 'Confirmado';

      case 'NOT_FOUND':
        return 'No encontrado';

      case 'AMBIGUOUS':
        return 'Coincidencia múltiple';

      case 'ERROR':
        return 'Error';

      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'DETECTED':
      case 'VERIFIED':
        return Icons.check_rounded;

      case 'NOT_FOUND':
        return Icons.close_rounded;

      case 'AMBIGUOUS':
        return Icons.search_rounded;

      case 'ERROR':
        return Icons.error_outline_rounded;

      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _statusChipBackground(String status) {
    switch (status) {
      case 'DETECTED':
      case 'VERIFIED':
        return const Color(0xFFDDF8E9);
      case 'AMBIGUOUS':
        return const Color(0xFFFFF3D6);
      default:
        return const Color(0xFFFFE1E8);
    }
  }

  String _methodAsset(String method) {
    return method.toUpperCase().contains('YAPE')
        ? AppAssets.yapeLogo
        : AppAssets.transferLogo;
  }

  String _methodLabel(String method) {
    return method.toUpperCase().contains('YAPE') ? 'Yape' : 'Transferencia';
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Hace un momento';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    }

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    }

    if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    }

    return 'Hace ${difference.inDays} d';
  }
}
