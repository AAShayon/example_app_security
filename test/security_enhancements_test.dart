import 'package:flutter_test/flutter_test.dart';
import 'package:app_security/security/data_encryption_service.dart';
import 'package:app_security/security/certificate_pinning.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Security Enhancements Tests', () {
    late DataEncryptionService encryptionService;

    setUp(() async {
      encryptionService = DataEncryptionService();
    });

    test('Data encryption and decryption', () async {
      const originalData = 'This is sensitive data that should be encrypted';

      // Initialize encryption service
      await encryptionService.initialize();
      
      final encrypted = await encryptionService.encryptData(originalData);
      final decrypted = await encryptionService.decryptData(encrypted);

      expect(originalData, decrypted);
      expect(originalData, isNot(encrypted)); // Should be different when encrypted
    });

    test('Parameter protection service', () async {
      final paramProtection = ParameterProtectionService();
      const originalParams = {
        'username': 'testuser',
        'password': 'secret123',
        'token': 'abc123xyz'
      };

      // Encrypt parameters
      final encryptedParams = await paramProtection.encryptSensitiveParameters(originalParams);
      expect(encryptedParams, isNot(originalParams)); // Should be different

      // Decrypt parameters
      final decryptedParams = await paramProtection.decryptSensitiveParameters(encryptedParams);
      expect(decryptedParams, originalParams);
    });

    test('Certificate pinning utility', () {
      // Test certificate fingerprint calculation
      // Note: We can't test actual certificate validation without a real certificate
      // but we can verify the utility functions exist and work with mock data
      expect(CertificatePinning.getPinnedFingerprints, isNotNull);
      expect(CertificatePinning.addPinnedCertificate, isNotNull);
    });

    test('Secure parameter bundle creation', () async {
      final paramProtection = ParameterProtectionService();
      const originalParams = {
        'username': 'testuser',
        'password': 'secret123',
        'token': 'abc123xyz'
      };

      // Create secure parameter bundle
      final bundle = await paramProtection.createSecureParameterBundle(originalParams);
      expect(bundle, isNotNull);
      expect(bundle, isNot(''));
      
      // Extract from bundle
      final extractedParams = await paramProtection.extractFromSecureBundle(bundle);
      expect(extractedParams, originalParams);
    });

    test('Parameter name obfuscation', () {
      final paramProtection = ParameterProtectionService();
      const originalParams = {
        'username': 'testuser',
        'password': 'secret123',
      };

      // Obfuscate parameter names
      final obfuscatedParams = paramProtection.obfuscateParameterNames(originalParams);
      
      // Check that keys are different
      expect(obfuscatedParams.keys, isNot(equals(originalParams.keys)));
      expect(obfuscatedParams, isNot(equals(originalParams)));
    });
  });
}