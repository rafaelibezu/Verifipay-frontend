import 'package:flutter/services.dart';

class ReceiverSetupService {
  static const MethodChannel _channel =
      MethodChannel('com.verifipay/notification_access');

  Future<bool> hasDeviceToken() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('hasDeviceToken');

      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}