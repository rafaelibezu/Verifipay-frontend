import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class ReceiverSetupPage extends StatefulWidget {
  final Future<void> Function()? onConfigured;

  const ReceiverSetupPage({super.key, this.onConfigured});

  @override
  State<ReceiverSetupPage> createState() => _ReceiverSetupPageState();
}

class _ReceiverSetupPageState extends State<ReceiverSetupPage> {
  static const MethodChannel _channel = MethodChannel(
    'com.verifipay/notification_access',
  );

  final TextEditingController _tokenController = TextEditingController();

  bool _saving = false;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _loadTokenStatus();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadTokenStatus() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('hasDeviceToken');

      if (!mounted) return;

      setState(() {
        _hasToken = result ?? false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasToken = false;
      });
    }
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el token del receptor.')),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _channel.invokeMethod('saveDeviceToken', {'token': token});

      _tokenController.clear();

      await _loadTokenStatus();
      if (widget.onConfigured != null) {
        await widget.onConfigured!();
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receptor vinculado correctamente.')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'No se pudo guardar el token.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _clearToken() async {
    await _channel.invokeMethod('clearDeviceToken');

    await _loadTokenStatus();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Receptor desvinculado.')));
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
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
                            'Estado del receptor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hasToken
                                ? 'Dispositivo vinculado'
                                : 'Dispositivo no vinculado',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _hasToken
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _tokenController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Token del dispositivo',
                    hintText: 'Pega aquí el token generado',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveToken,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Vincular receptor',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
                if (_hasToken) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearToken,
                      child: const Text('Desvincular receptor'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
