import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../notification/presentation/receiver_setup_page.dart';
import '../../receiver_device/models/receiver_device_current.dart';
import '../../receiver_device/models/receiver_device_local_state.dart';
import '../../receiver_device/services/receiver_device_local_store.dart';
import '../../receiver_device/services/receiver_device_service.dart';

class OwnerHomePage extends StatefulWidget {
  final AuthUser user;
  final AuthService authService;
  final ReceiverDeviceService receiverDeviceService;
  final ReceiverDeviceLocalStore receiverDeviceLocalStore;

  OwnerHomePage({
    super.key,
    required this.user,
    AuthService? authService,
    ReceiverDeviceService? receiverDeviceService,
    ReceiverDeviceLocalStore? receiverDeviceLocalStore,
  }) : authService = authService ?? AuthService(),
       receiverDeviceService = receiverDeviceService ?? ReceiverDeviceService(),
       receiverDeviceLocalStore =
           receiverDeviceLocalStore ?? ReceiverDeviceLocalStore();

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  static const MethodChannel _channel = MethodChannel(
    'com.verifipay/notification_access',
  );

  ReceiverDeviceCurrent? _remoteReceiver;
  ReceiverDeviceLocalState? _localReceiver;
  bool _hasDeviceToken = false;
  bool _notificationAccess = false;
  int _pendingCount = 0;
  bool _loading = true;
  bool _deactivating = false;
  String? _receiverLoadError;
  String? _reconciliationError;

  @override
  void initState() {
    super.initState();
    _loadReceiverStatus();
  }

  Future<void> _loadReceiverStatus() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _receiverLoadError = null;
        _reconciliationError = null;
      });
    }

    ReceiverDeviceCurrent? remoteReceiver;
    String? receiverLoadError;
    try {
      remoteReceiver = await widget.receiverDeviceService.getCurrentReceiver();
    } on ApiException catch (error) {
      receiverLoadError = error.message;
    } catch (_) {
      receiverLoadError = 'No se pudo consultar el estado del receiver.';
    }

    final results = await Future.wait<dynamic>([
      widget.receiverDeviceLocalStore
          .read()
          .then<dynamic>((value) => value)
          .catchError((Object _) => null),
      _channel
          .invokeMethod<bool>('hasDeviceToken')
          .then<dynamic>((value) => value)
          .catchError((Object _) => null),
      _channel
          .invokeMethod<bool>('isNotificationAccessGranted')
          .then<dynamic>((value) => value)
          .catchError((Object _) => null),
      _channel
          .invokeMethod<int>('getPendingYapeEventCount')
          .then<dynamic>((value) => value)
          .catchError((Object _) => null),
    ]);

    var localReceiver = results[0] as ReceiverDeviceLocalState?;
    var hasDeviceToken = results[1] == true;
    String? reconciliationError;

    if (receiverLoadError == null && remoteReceiver == null && hasDeviceToken) {
      try {
        await _channel.invokeMethod('clearDeviceToken');
        await widget.receiverDeviceLocalStore.clear();
        hasDeviceToken = false;
        localReceiver = null;
      } catch (_) {
        reconciliationError =
            'No se pudo limpiar el token local obsoleto. Reintenta.';
      }
    }

    if (!mounted) return;
    setState(() {
      _remoteReceiver = remoteReceiver;
      _localReceiver = localReceiver;
      _hasDeviceToken = hasDeviceToken;
      _notificationAccess = results[2] == true;
      _pendingCount = results[3] as int? ?? 0;
      _receiverLoadError = receiverLoadError;
      _reconciliationError = reconciliationError;
      _loading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await widget.authService.logout();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiverSetupPage(onConfigured: _loadReceiverStatus),
      ),
    );

    await _loadReceiverStatus();
  }

  Future<void> _openNotificationSettings() async {
    await _channel.invokeMethod('openNotificationSettings');
  }

  Future<void> _deactivateReceiver() async {
    final receiver = _remoteReceiver;
    if (receiver == null) return;

    setState(() => _deactivating = true);

    try {
      await widget.receiverDeviceService.deactivate(receiver.id);
      if (_hasDeviceToken) await _channel.invokeMethod('clearDeviceToken');
      await widget.receiverDeviceLocalStore.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receptor desactivado correctamente.')),
      );
      await _loadReceiverStatus();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _deactivating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = widget.user.companyName?.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReceiverStatus,
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
                'Hola, ${widget.user.name}',
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
              _buildReceiverPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiverPanel() {
    final receiver = _remoteReceiver;
    final localReceiver = _localReceiver;
    final backendLabel = _receiverLoadError != null
        ? 'Error de consulta'
        : receiver == null
        ? 'No configurado'
        : 'Activo';
    final thisDeviceLabel = _receiverLoadError != null
        ? _hasDeviceToken
              ? 'No verificado'
              : 'Sin verificar'
        : receiver != null
        ? _hasDeviceToken
              ? 'Vinculado'
              : 'Otro dispositivo'
        : _reconciliationError != null
        ? 'Token local sin limpiar'
        : _hasDeviceToken
        ? 'Estado local obsoleto'
        : 'No vinculado';
    final branchName = receiver?.branchName ?? localReceiver?.branchName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEDE7FF),
                child: Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receiver Device',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (branchName != null && branchName.isNotEmpty)
                      Text(
                        'Sucursal: $branchName',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _statusRow('Backend', backendLabel, receiver != null),
          _statusRow(
            'Este dispositivo',
            thisDeviceLabel,
            receiver != null && _hasDeviceToken,
          ),
          if (receiver?.lastSeenAt != null)
            _statusRow(
              'Última actividad',
              receiver!.lastSeenAt!.toLocal().toString(),
              true,
            ),
          _statusRow(
            'Acceso a notificaciones',
            _notificationAccess ? 'Activo' : 'Requiere configuracion',
            _notificationAccess,
          ),
          _statusRow(
            'Eventos pendientes',
            _pendingCount.toString(),
            _pendingCount == 0,
          ),
          if (_receiverLoadError != null) ...[
            const SizedBox(height: 4),
            Text(
              _receiverLoadError!,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : _loadReceiverStatus,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
          if (_reconciliationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _reconciliationError!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openSetup,
              icon: const Icon(Icons.phonelink_setup_rounded),
              label: const Text('Vincular dispositivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openNotificationSettings,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Abrir ajustes de notificaciones'),
            ),
          ),
          if (receiver != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deactivating ? null : _deactivateReceiver,
                icon: const Icon(Icons.block_rounded),
                label: const Text('Desactivar receiver'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          Text(
            value,
            style: TextStyle(
              color: ok ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
