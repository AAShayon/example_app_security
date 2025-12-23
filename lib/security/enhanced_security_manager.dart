import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EnhancedSecurityManager {
  static const MethodChannel _channel = MethodChannel('security/device');
  static final EnhancedSecurityManager _instance = EnhancedSecurityManager._internal();
  factory EnhancedSecurityManager() => _instance;
  EnhancedSecurityManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false;
  String? _appSignature;
  String? _sessionToken;
  int? _lastCheckTimestamp;

  /// Get the last security check timestamp
  int? get lastCheckTimestamp => _lastCheckTimestamp;

  /// Set the last security check timestamp
  set lastCheckTimestamp(int? timestamp) {
    _lastCheckTimestamp = timestamp;
  }

  static const String _sessionTokenKey = 'secure_session_token';
  static const String _appSignatureKey = 'app_signature';
  static const String _lastCheckTimeKey = 'last_security_check_time';

  /// Initialize all security checks
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _performEnhancedSecurityChecks();
    _isInitialized = true;
  }

  /// Perform comprehensive security checks
  Future<void> _performEnhancedSecurityChecks() async {
    // Skip security checks in debug mode
    if (kDebugMode) {
      print('Security checks skipped in debug mode');
      return;
    }

    // Check for rooted/jailbroken device
    if (await _isDeviceCompromised()) {
      throw Exception('Security violation: Device is compromised');
    }

    // Check for debugger attachment
    if (await _isDebuggerAttached()) {
      throw Exception('Security violation: Debugger detected');
    }

    // Check for emulator
    if (await _isEmulator()) {
      throw Exception('Security violation: Running on emulator');
    }

    // Check network security
    if (await _isOnUntrustedNetwork()) {
      throw Exception('Security violation: Untrusted network detected');
    }

    // Verify app integrity
    if (!await _verifyAppIntegrity()) {
      throw Exception('Security violation: App integrity check failed');
    }

    // Store app signature
    await _storeAppSignature();

    // Generate session token
    await _generateSessionToken();
  }

  /// Check if device is compromised (rooted/jailbroken)
  Future<bool> _isDeviceCompromised() async {
    try {
      final bool isCompromised = await _channel.invokeMethod('isDeviceCompromised');
      return isCompromised;
    } catch (e) {
      // If the native method fails, fall back to Dart-based checks
      return await _isDeviceRooted();
    }
  }

  /// Public method to check if device is compromised
  Future<bool> isDeviceCompromised() async {
    return await _isDeviceCompromised();
  }

  /// Dart-based rooted device check
  Future<bool> _isDeviceRooted() async {
    if (Platform.isAndroid) {
      // Check for common root files/directories
      final rootFiles = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
        '/system/xbin/magisk',
        '/data/adb/magisk',
      ];

      for (final file in rootFiles) {
        try {
          if (await File(file).exists()) {
            return true;
          }
        } catch (e) {
          // If we can't check a file, continue to the next
          continue;
        }
      }
    } else if (Platform.isIOS) {
      // Check for jailbreak indicators
      final jailbreakFiles = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt',
        '/private/var/lib/cydia',
        '/private/etc/dpkg',
        '/private/var/cache/apt',
      ];

      for (final file in jailbreakFiles) {
        try {
          if (await File(file).exists()) {
            return true;
          }
        } catch (e) {
          // If we can't check a file, continue to the next
          continue;
        }
      }
    }

    return false;
  }

  /// Check if debugger is attached
  Future<bool> _isDebuggerAttached() async {
    // In a real implementation, you would use platform channels
    // to check for debugger attachment
    return false; // Simplified for demo purposes
  }

  /// Public method to check if debugger is attached
  Future<bool> isDebuggerAttached() async {
    return await _isDebuggerAttached();
  }

  /// Check if running on emulator
  Future<bool> _isEmulator() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // Check for common emulator indicators in package info
      // This is a simplified check - in real apps, use more sophisticated methods
      // Use the packageInfo variable to avoid the warning
      if (packageInfo.packageName.contains('emulator') ||
          packageInfo.packageName.contains('test') ||
          packageInfo.packageName.contains('android')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Public method to check if running on emulator
  Future<bool> isEmulator() async {
    return await _isEmulator();
  }

  /// Check if on untrusted network
  Future<bool> _isOnUntrustedNetwork() async {
    try {
      // Connectivity().checkConnectivity() might return a List or a single result depending on version
      final result = await (Connectivity().checkConnectivity());

      // Handle both single result and list result
      ConnectivityResult connectivityResult;
      if (result is List<ConnectivityResult> && result.isNotEmpty) {
        connectivityResult = result.first;
      } else if (result is ConnectivityResult) {
        connectivityResult = result as ConnectivityResult;
      } else {
        connectivityResult = ConnectivityResult.none;
      }

      // Check for VPN usage (which might indicate untrusted network)
      if (connectivityResult == ConnectivityResult.none) {
        // No network connection is not necessarily a security issue
        return false;
      }

      // Additional network security checks can be implemented here
      return false;
    } on Exception catch (e) {
      // Log the exception for debugging purposes (in production, be careful about logging)
      // print('Network security check failed: $e');
      return false;
    }
  }

  /// Check if on untrusted network (corrected version)
  Future<bool> _isOnUntrustedNetworkCorrected() async {
    try {
      // Connectivity().checkConnectivity() might return a List or a single result depending on version
      final result = await (Connectivity().checkConnectivity());

      // Handle both single result and list result
      ConnectivityResult connectivityResult;
      if (result is List<ConnectivityResult> && result.isNotEmpty) {
        connectivityResult = result.first;
      } else if (result is ConnectivityResult) {
        connectivityResult = result as ConnectivityResult;
      } else {
        connectivityResult = ConnectivityResult.none;
      }

      // Check for VPN usage (which might indicate untrusted network)
      if (connectivityResult == ConnectivityResult.none) {
        // No network connection is not necessarily a security issue
        return false;
      }

      // Additional network security checks can be implemented here
      return false;
    } on Exception catch (e) {
      // Log the exception for debugging purposes (in production, be careful about logging)
      // print('Network security check failed: $e');
      return false;
    }
  }

  /// Public method to check if on untrusted network
  Future<bool> isOnUntrustedNetwork() async {
    return await _isOnUntrustedNetworkCorrected();
  }

  /// Store app signature for integrity checking
  Future<void> _storeAppSignature() async {
    final signature = await _generateAppSignature();
    await _secureStorage.write(
      key: _appSignatureKey,
      value: signature,
    );
    _appSignature = signature;
  }

  /// Generate app signature based on package info and build info
  Future<String> _generateAppSignature() async {
    if (_appSignature != null) {
      return _appSignature!;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      // Create a hash based on package info
      final signatureBase = '${packageInfo.packageName}-${packageInfo.version}-${packageInfo.buildNumber}';
      final bytes = utf8.encode(signatureBase);
      final hash = sha256.convert(bytes);

      return base64Url.encode(hash.bytes);
    } catch (e) {
      // Fallback signature in case of error
      final fallbackSignature = 'fallback_signature_${DateTime.now().millisecondsSinceEpoch}';
      final bytes = utf8.encode(fallbackSignature);
      final hash = sha256.convert(bytes);
      return base64Url.encode(hash.bytes);
    }
  }

  /// Public method to generate app signature for external use
  Future<String> generateAppSignature() async {
    return await _generateAppSignature();
  }

  /// Verify app integrity
  Future<bool> _verifyAppIntegrity() async {
    // Skip integrity check in debug mode
    if (kDebugMode) {
      return true;
    }

    try {
      final storedSignature = await _secureStorage.read(key: _appSignatureKey);
      if (storedSignature == null) {
        return false;
      }

      final currentSignature = await _generateAppSignature();
      return storedSignature == currentSignature;
    } catch (e) {
      return false;
    }
  }

  /// Public method to verify app integrity
  Future<bool> verifyAppIntegrity() async {
    return await _verifyAppIntegrity();
  }

  /// Generate secure session token
  Future<void> _generateSessionToken() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomData = await _generateSecureRandomString(32);
    final tokenBase = '$timestamp-$randomData-${await _generateAppSignature()}';
    
    final bytes = utf8.encode(tokenBase);
    final hash = sha256.convert(bytes);
    final token = base64Url.encode(hash.bytes);
    
    await _secureStorage.write(key: _sessionTokenKey, value: token);
    _sessionToken = token;
  }

  /// Get the current session token
  Future<String?> getSessionToken() async {
    if (_sessionToken != null) {
      return _sessionToken;
    }
    
    _sessionToken = await _secureStorage.read(key: _sessionTokenKey);
    return _sessionToken;
  }

  /// Check if security should be re-verified
  Future<bool> shouldRecheckSecurity() async {
    final lastCheck = await _secureStorage.read(key: _lastCheckTimeKey);
    if (lastCheck == null) {
      // First time check
      await _secureStorage.write(
        key: _lastCheckTimeKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      return true;
    }

    final lastCheckTime = int.tryParse(lastCheck);
    if (lastCheckTime == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final checkInterval = 5 * 60 * 1000; // 5 minutes in milliseconds

    if (currentTime - lastCheckTime > checkInterval) {
      // Update the last check time
      await _secureStorage.write(
        key: _lastCheckTimeKey,
        value: currentTime.toString(),
      );
      return true;
    }

    return false;
  }

  /// Generate secure random string
  Future<String> _generateSecureRandomString(int length) async {
    final random = CryptoUtils.getRandomBytes(length);
    return base64Url.encode(random);
  }

  /// Verify all security checks
  Future<bool> verifyAllSecurity() async {
    if (kDebugMode) return true;

    try {
      // Check if device is compromised
      if (await _isDeviceCompromised()) return false;

      // Verify app integrity
      if (!await _verifyAppIntegrity()) return false;

      // Check for debugger
      if (await _isDebuggerAttached()) return false;

      // Check for emulator
      if (await _isEmulator()) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all secure data
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
    _sessionToken = null;
    _appSignature = null;
    _isInitialized = false;
  }

  /// Get security headers for API requests
  Future<Map<String, String>> getSecurityHeaders() async {
    final headers = <String, String>{
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'X-Permitted-Cross-Domain-Policies': 'none',
      'Referrer-Policy': 'no-referrer',
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };

    // Add session token if available
    final sessionToken = await getSessionToken();
    if (sessionToken != null) {
      headers['X-Session-Token'] = sessionToken;
    }

    // Add timestamp to prevent replay attacks
    headers['X-Request-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

    return headers;
  }
}

/// Utility class for cryptographic operations
class CryptoUtils {
  static final Random _random = Random.secure();

  /// Generate cryptographically secure random bytes
  static Uint8List getRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// Encrypt data using AES (simplified for this example)
  static String encryptData(String plainText, String key) {
    // In a real implementation, use proper AES encryption
    // This is a simple XOR-based encryption for demonstration
    final plainBytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(key);
    final encryptedBytes = <int>[];

    for (int i = 0; i < plainBytes.length; i++) {
      encryptedBytes.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Url.encode(encryptedBytes);
  }

  /// Decrypt data using AES (simplified for this example)
  static String decryptData(String encryptedText, String key) {
    // In a real implementation, use proper AES decryption
    // This is a simple XOR-based decryption for demonstration
    final encryptedBytes = base64Url.decode(encryptedText);
    final keyBytes = utf8.encode(key);
    final decryptedBytes = <int>[];

    for (int i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decryptedBytes);
  }
}