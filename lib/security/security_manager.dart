import 'device_security.dart';
import 'screen_security.dart';
import 'app_integrity.dart';
import 'enhanced_security_manager.dart';

class SecurityManager {
  static Future<void> initialize() async {
    // Run basic checks first
    await AppIntegrity.checkDebugMode();
    await DeviceSecurity.checkDeviceSecurity();
    await ScreenSecurity.secureScreen();

    // Then run enhanced security checks
    await EnhancedSecurityManager().initialize();
  }
}
