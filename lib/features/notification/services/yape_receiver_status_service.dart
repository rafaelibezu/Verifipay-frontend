import 'package:flutter/services.dart';

class YapeReceiverStatus {
  const YapeReceiverStatus({
    required this.isConnected,
    required this.pendingPayments,
  });

  final bool isConnected;
  final int pendingPayments;
}

class YapeReceiverStatusService {
  static const MethodChannel _channel = MethodChannel(
    'com.verifipay/notification_access',
  );

  Future<YapeReceiverStatus> getStatus() async {
    final results = await Future.wait([
      _isNotificationAccessGranted(),
      _getPendingPayments(),
    ]);

    return YapeReceiverStatus(
      isConnected: results[0] as bool,
      pendingPayments: results[1] as int,
    );
  }

  Future<bool> _isNotificationAccessGranted() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isNotificationAccessGranted',
      );

      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<int> _getPendingPayments() async {
    try {
      final result = await _channel.invokeMethod<int>(
        'getPendingYapeEventCount',
      );

      return result ?? 0;
    } on MissingPluginException {
      return 0;
    } on PlatformException {
      return 0;
    }
  }
}
