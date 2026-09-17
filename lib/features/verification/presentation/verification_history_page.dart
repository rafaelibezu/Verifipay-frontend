import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../models/verification_response.dart';
import '../services/verification_history_service.dart';

enum _HistoryFilter { all, yape, transfer }

class VerificationHistoryPage extends StatefulWidget {
  const VerificationHistoryPage({super.key});

  @override
  State<VerificationHistoryPage> createState() =>
      _VerificationHistoryPageState();
}

class _VerificationHistoryPageState extends State<VerificationHistoryPage> {
  final VerificationHistoryService _historyService =
      VerificationHistoryService();

  List<VerificationResponse> _verifications = [];
  _HistoryFilter _filter = _HistoryFilter.all;
  bool _loading = true;

  List<VerificationResponse> get _filteredVerifications {
    return _verifications.where((verification) {
      final method = verification.method.toUpperCase();

      return switch (_filter) {
        _HistoryFilter.all => true,
        _HistoryFilter.yape => method.contains('YAPE'),
        _HistoryFilter.transfer => !method.contains('YAPE'),
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _historyService.findMyHistory();

      if (!mounted) return;

      setState(() {
        _verifications = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredVerifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.navy,
        ),
        title: const Text(
          'Historial',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Row(
              children: [
                _buildFilterChip('Todos', _HistoryFilter.all),
                const SizedBox(width: 10),
                _buildFilterChip('Yape', _HistoryFilter.yape),
                const SizedBox(width: 10),
                _buildFilterChip('Transferencias', _HistoryFilter.transfer),
              ],
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 52,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Todavia no tienes verificaciones',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...items.map(_buildCard),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, _HistoryFilter filter) {
    final selected = _filter == filter;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() => _filter = filter);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(VerificationResponse verification) {
    final success = _isSuccess(verification.status);
    final color = _statusColor(verification.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetail(verification),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: success
                ? Border.all(color: AppColors.success.withValues(alpha: 0.35))
                : null,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF677099).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(_statusIcon(verification.status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S/ ${verification.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _methodLabel(verification.method),
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatters.shortRelative(_displayDate(verification)),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(VerificationResponse verification) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _HistoryDetailSheet(verification: verification);
      },
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
              onTap: () => Navigator.pop(context),
            ),
            _buildBottomNavigationItem(
              icon: Icons.history_rounded,
              label: 'Historial',
              isSelected: true,
              onTap: () {},
            ),
            _buildBottomNavigationItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              onTap: () {},
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
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
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

  bool _isSuccess(String status) =>
      status == 'DETECTED' || status == 'VERIFIED';

  Color _statusColor(String status) {
    if (_isSuccess(status)) return AppColors.success;
    if (status == 'AMBIGUOUS') return const Color(0xFFF59E0B);
    return AppColors.error;
  }

  IconData _statusIcon(String status) {
    if (_isSuccess(status)) return Icons.check_rounded;
    if (status == 'AMBIGUOUS') return Icons.search_rounded;
    return Icons.close_rounded;
  }
}

class _HistoryDetailSheet extends StatelessWidget {
  const _HistoryDetailSheet({required this.verification});

  final VerificationResponse verification;

  bool get _success =>
      verification.status == 'DETECTED' || verification.status == 'VERIFIED';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detalle de la operacion',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _detailRow(
              'Estado',
              _success ? 'Pago confirmado' : 'No encontrado',
              chipColor: _success ? AppColors.success : AppColors.error,
            ),
            _detailRow(
              'Metodo',
              _methodLabel(verification.method),
              asset: _methodAsset(verification.method),
            ),
            _detailRow('Monto', 'S/ ${verification.amount.toStringAsFixed(2)}'),
            _detailRow(
              'N de operacion',
              verification.securityCode ?? verification.reference ?? '-',
            ),
            _detailRow(
              'Fecha y hora',
              DateFormatters.dateTime(_displayDate(verification)),
            ),
            if (verification.branchName.isNotEmpty)
              _detailRow('Local', verification.branchName),
            if (verification.cashierName.isNotEmpty)
              _detailRow('Cajero', verification.cashierName),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? chipColor,
    String? asset,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
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
          if (asset != null) ...[
            Image.asset(asset, width: 26, height: 26),
            const SizedBox(width: 8),
          ],
          if (chipColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: chipColor, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    value,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

DateTime? _displayDate(VerificationResponse verification) {
  return verification.paymentTime ??
      verification.verifiedAt ??
      verification.createdAt;
}

String _methodAsset(String method) {
  return method.toUpperCase().contains('YAPE')
      ? AppAssets.yapeLogo
      : AppAssets.transferLogo;
}

String _methodLabel(String method) {
  return method.toUpperCase().contains('YAPE') ? 'Yape' : 'Transferencia';
}
