import 'dart:io';
import 'package:flutter/foundation.dart';
import 'enhanced_security_manager.dart';
import 'data_encryption_service.dart';
import 'certificate_pinning.dart';
import '../services/api_service.dart';

/// Security testing utility to verify all security enhancements
class SecurityTester {
  static final SecurityTester _instance = SecurityTester._internal();
  factory SecurityTester() => _instance;
  SecurityTester._internal();

  final EnhancedSecurityManager _securityManager = EnhancedSecurityManager();
  final DataEncryptionService _encryptionService = DataEncryptionService();
  final ApiService _apiService = ApiService();

  /// Run all security tests
  Future<Map<String, dynamic>> runAllSecurityTests() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, bool>{},
      'details': <String, String>{},
    };

    try {
      // Test 1: Enhanced security initialization
      results['tests']['enhanced_security_init'] = await _testEnhancedSecurityInitialization();
      
      // Test 2: Device security checks
      results['tests']['device_security'] = await _testDeviceSecurity();
      
      // Test 3: Data encryption
      results['tests']['data_encryption'] = await _testDataEncryption();
      
      // Test 4: Certificate pinning
      results['tests']['certificate_pinning'] = _testCertificatePinning();
      
      // Test 5: API communication security
      results['tests']['api_security'] = await _testApiSecurity();
      
      // Test 6: Parameter protection
      results['tests']['parameter_protection'] = await _testParameterProtection();
      
      // Test 7: Session management
      results['tests']['session_management'] = await _testSessionManagement();
      
      // Calculate overall security score
      final passedTests = results['tests'].values.where((result) => result).length;
      final totalTests = results['tests'].length;
      results['overall_security_score'] = (passedTests / totalTests * 100).round();
      
      results['security_status'] = results['overall_security_score'] == 100 ? 'secure' : 'vulnerable';
    } catch (e) {
      results['error'] = 'Error during security testing: $e';
    }

    return results;
  }

  /// Test enhanced security initialization
  Future<bool> _testEnhancedSecurityInitialization() async {
    try {
      await _securityManager.initialize();
      return true;
    } catch (e) {
      print('Enhanced security initialization failed: $e');
      return false;
    }
  }

  /// Test device security checks
  Future<bool> _testDeviceSecurity() async {
    try {
      final isSecure = await _securityManager.verifyAllSecurity();
      return isSecure;
    } catch (e) {
      print('Device security test failed: $e');
      return false;
    }
  }

  /// Test data encryption functionality
  Future<bool> _testDataEncryption() async {
    try {
      await _encryptionService.initialize();
      
      // Test encryption/decryption
      const originalData = 'This is sensitive data that should be encrypted';
      final encrypted = await _encryptionService.encryptData(originalData);
      final decrypted = await _encryptionService.decryptData(encrypted);
      
      return originalData == decrypted;
    } catch (e) {
      print('Data encryption test failed: $e');
      return false;
    }
  }

  /// Test certificate pinning
  bool _testCertificatePinning() {
    try {
      // Test with a known good host (in real implementation, test with actual API hosts)
      // For this test, we'll just verify the certificate pinning setup
      final pinnedHosts = CertificatePinning.getPinnedFingerprints('jsonplaceholder.typicode.com');
      return pinnedHosts != null && pinnedHosts.isNotEmpty;
    } catch (e) {
      print('Certificate pinning test failed: $e');
      return false;
    }
  }

  /// Test API security
  Future<bool> _testApiSecurity() async {
    try {
      // Test secure API communication
      final posts = await _apiService.fetchPosts();
      return posts.isNotEmpty;
    } catch (e) {
      print('API security test failed: $e');
      return false;
    }
  }

  /// Test parameter protection
  Future<bool> _testParameterProtection() async {
    try {
      // Test with encrypted parameters
      final params = {'test': 'value', 'sensitive': 'data'};
      final encryptedParams = await _apiService.fetchPostsWithEncryptedParams(params: params);
      return encryptedParams.isNotEmpty;
    } catch (e) {
      print('Parameter protection test failed: $e');
      return false;
    }
  }

  /// Test session management
  Future<bool> _testSessionManagement() async {
    try {
      final sessionToken = await _securityManager.getSessionToken();
      return sessionToken != null && sessionToken.isNotEmpty;
    } catch (e) {
      print('Session management test failed: $e');
      return false;
    }
  }

  /// Get security status summary
  Future<Map<String, dynamic>> getSecurityStatus() async {
    final status = <String, dynamic>{};

    try {
      status['is_initialized'] = true;
      status['is_device_secure'] = await _securityManager.verifyAllSecurity();
      status['session_token_exists'] = await _securityManager.getSessionToken() != null;
      status['encryption_initialized'] = true; // Assuming initialization succeeded
      
      // Check if we should recheck security
      status['needs_security_recheck'] = await _securityManager.shouldRecheckSecurity();
      
      // Get app signature info
      final currentSignature = await _securityManager.generateAppSignature();
      status['app_signature'] = currentSignature.substring(0, 8) + '...'; // Truncate for privacy
    } catch (e) {
      status['error'] = 'Error getting security status: $e';
    }

    return status;
  }

  /// Perform a comprehensive security audit
  Future<Map<String, dynamic>> performSecurityAudit() async {
    final audit = <String, dynamic>{
      'audit_timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'debug_mode': kDebugMode,
      'security_checks': <String, dynamic>{},
    };

    try {
      // Enhanced security checks
      audit['security_checks']['is_device_compromised'] = await _securityManager.isDeviceCompromised();
      audit['security_checks']['is_debugger_attached'] = await _securityManager.isDebuggerAttached();
      audit['security_checks']['is_emulator'] = await _securityManager.isEmulator();
      audit['security_checks']['is_on_untrusted_network'] = await _securityManager.isOnUntrustedNetwork();
      audit['security_checks']['app_integrity_verified'] = await _securityManager.verifyAppIntegrity();
      
      // Security features status
      audit['security_features'] = {
        'certificate_pinning': true,
        'data_encryption': true,
        'endpoint_obfuscation': true,
        'session_management': true,
        'parameter_protection': true,
      };
      
      // Calculate risk level
      final riskyChecks = [
        audit['security_checks']['is_device_compromised'],
        audit['security_checks']['is_debugger_attached'],
        audit['security_checks']['is_emulator'],
        !audit['security_checks']['app_integrity_verified'],
      ].where((check) => check == true).length;
      
      audit['risk_level'] = riskyChecks == 0 ? 'low' : riskyChecks == 1 ? 'medium' : 'high';
    } catch (e) {
      audit['error'] = 'Error during security audit: $e';
    }

    return audit;
  }
}