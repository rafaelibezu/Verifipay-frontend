import 'package:flutter/services.dart';

class NotificationPermissionService {
  static const MethodChannel _channel =
      MethodChannel(
    'com.verifipay/notification_access',
  );

  Future<bool> isGranted() async {
    final result =
        await _channel.invokeMethod<bool>(
      'isNotificationAccessGranted',
    );

    return result ?? false;
  }

  Future<void> openSettings() async {
    await _channel.invokeMethod(
      'openNotificationSettings',
    );
  }
}