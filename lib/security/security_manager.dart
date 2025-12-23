import 'device_security.dart';
import 'screen_security.dart';
import 'app_integrity.dart';

class SecurityManager {
  static Future<void> initialize() async {
    await AppIntegrity.checkDebugMode();
    await DeviceSecurity.checkDeviceSecurity();
    await ScreenSecurity.secureScreen();
  }
}
