import 'package:flutter/services.dart';

class DeviceSecurity {
  static const _channel = MethodChannel('security/device');

  static Future<void> checkDeviceSecurity() async {
    try {
      final bool compromised = await _channel.invokeMethod(
        'isDeviceCompromised',
      );
      if (compromised) {
        throw Exception('Security risk detected!');
      }
    } catch (e) {
      rethrow;
    }
  }
}
