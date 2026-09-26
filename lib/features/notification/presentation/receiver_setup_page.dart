import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../receiver_device/models/owner_branch.dart';
import '../../receiver_device/services/owner_branch_service.dart';
import '../../receiver_device/services/receiver_device_local_store.dart';
import '../../receiver_device/services/receiver_device_service.dart';

class ReceiverSetupPage extends StatefulWidget {
  final Future<void> Function()? onConfigured;
  final OwnerBranchService branchService;
  final ReceiverDeviceService receiverDeviceService;
  final ReceiverDeviceLocalStore localStore;

  ReceiverSetupPage({
    super.key,
    this.onConfigured,
    OwnerBranchService? branchService,
    ReceiverDeviceService? receiverDeviceService,
    ReceiverDeviceLocalStore? localStore,
  }) : branchService = branchService ?? OwnerBranchService(),
       receiverDeviceService = receiverDeviceService ?? ReceiverDeviceService(),
       localStore = localStore ?? ReceiverDeviceLocalStore();

  @override
  State<ReceiverSetupPage> createState() => _ReceiverSetupPageState();
}

class _ReceiverSetupPageState extends State<ReceiverSetupPage> {
  static const MethodChannel _channel = MethodChannel(
    'com.verifipay/notification_access',
  );

  final TextEditingController _nameController = TextEditingController(
    text: 'Receptor principal',
  );

  List<OwnerBranch> _branches = [];
  OwnerBranch? _selectedBranch;
  bool _loading = true;
  bool _saving = false;
  bool _hasToken = false;
  bool _notificationAccess = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        widget.branchService.findAll(),
        _channel.invokeMethod<bool>('hasDeviceToken'),
        _channel.invokeMethod<bool>('isNotificationAccessGranted'),
      ]);

      final branches = (results[0] as List<OwnerBranch>)
          .where((branch) => branch.active)
          .toList();

      if (!mounted) return;
      setState(() {
        _branches = branches;
        _selectedBranch = branches.isEmpty ? null : branches.first;
        _hasToken = results[1] == true;
        _notificationAccess = results[2] == true;
        _loading = false;
      });
    } on ApiException catch (e) {
      _show(e.message);
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _configure() async {
    final branch = _selectedBranch;
    final name = _nameController.text.trim();

    if (branch == null) {
      _show('Crea un local activo antes de vincular un receptor.');
      return;
    }

    if (name.isEmpty) {
      _show('Ingresa un nombre para el receptor.');
      return;
    }

    setState(() => _saving = true);

    try {
      final receiver = await widget.receiverDeviceService.create(
        branchId: branch.id,
        name: name,
      );

      await _channel.invokeMethod('saveDeviceToken', {
        'token': receiver.deviceToken,
      });

      await widget.localStore.saveCreated(receiver);

      if (widget.onConfigured != null) {
        await widget.onConfigured!();
      }

      if (!mounted) return;
      setState(() => _hasToken = true);
      _show('Receptor vinculado correctamente.');
    } on ApiException catch (e) {
      _show(e.message);
    } on PlatformException catch (e) {
      _show(e.message ?? 'No se pudo guardar el token del receptor.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openNotificationSettings() async {
    await _channel.invokeMethod('openNotificationSettings');
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receptor Yape'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vincular este dispositivo',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del receptor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<OwnerBranch>(
                        initialValue: _selectedBranch,
                        items: _branches
                            .map(
                              (branch) => DropdownMenuItem(
                                value: branch,
                                child: Text(branch.name),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (branch) =>
                                  setState(() => _selectedBranch = branch),
                        decoration: const InputDecoration(
                          labelText: 'Local',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _statusRow(
                        'Este dispositivo',
                        _hasToken ? 'Vinculado' : 'No vinculado',
                        _hasToken,
                      ),
                      _statusRow(
                        'Acceso a notificaciones',
                        _notificationAccess
                            ? 'Activo'
                            : 'Requiere configuracion',
                        _notificationAccess,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _configure,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.phonelink_setup_rounded),
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
                    ],
                  ),
                ),
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
