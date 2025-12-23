import 'package:flutter/services.dart';

class ScreenSecurity {
  static const _channel = MethodChannel('security/screen');

  static Future<void> secureScreen() async {
    await _channel.invokeMethod('secureScreen');
  }
}
