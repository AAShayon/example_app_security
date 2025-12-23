import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'enhanced_security_manager.dart';

/// Service for encrypting and decrypting sensitive data
class DataEncryptionService {
  static final DataEncryptionService _instance = DataEncryptionService._internal();
  factory DataEncryptionService() => _instance;
  DataEncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final EnhancedSecurityManager _securityManager = EnhancedSecurityManager();

  // Keys for secure storage
  static const String _encryptionKeyStorageKey = 'encryption_key';
  static const String _saltStorageKey = 'encryption_salt';

  /// Initialize the encryption service
  Future<void> initialize() async {
    await _securityManager.initialize();
    await _ensureEncryptionKeyExists();
  }

  /// Ensure that an encryption key exists in secure storage
  Future<void> _ensureEncryptionKeyExists() async {
    final existingKey = await _secureStorage.read(key: _encryptionKeyStorageKey);
    if (existingKey == null) {
      await _generateAndStoreEncryptionKey();
    }
  }

  /// Generate and store a new encryption key
  Future<void> _generateAndStoreEncryptionKey() async {
    // Generate a secure random encryption key
    final keyBytes = CryptoUtils.getRandomBytes(32); // 256-bit key
    final key = base64Url.encode(keyBytes);
    
    // Generate a salt for additional security
    final saltBytes = CryptoUtils.getRandomBytes(16);
    final salt = base64Url.encode(saltBytes);
    
    // Store the key and salt securely
    await _secureStorage.write(key: _encryptionKeyStorageKey, value: key);
    await _secureStorage.write(key: _saltStorageKey, value: salt);
  }

  /// Get the encryption key from secure storage
  Future<String> _getEncryptionKey() async {
    final key = await _secureStorage.read(key: _encryptionKeyStorageKey);
    if (key == null) {
      // If no key exists, generate one
      await _generateAndStoreEncryptionKey();
      return await _getEncryptionKey();
    }
    return key;
  }

  /// Get the salt from secure storage
  Future<String> _getSalt() async {
    final salt = await _secureStorage.read(key: _saltStorageKey);
    if (salt == null) {
      // If no salt exists, generate one
      await _generateAndStoreEncryptionKey();
      return await _getSalt();
    }
    return salt;
  }

  /// Encrypt sensitive data
  Future<String> encryptData(String plainText) async {
    try {
      // Get the encryption key and salt
      final key = await _getEncryptionKey();
      final salt = await _getSalt();
      
      // Create a derived key using the main key and salt
      final derivedKey = _deriveKey(key, salt);
      
      // Perform encryption
      final encrypted = _encryptWithKey(plainText, derivedKey);
      
      // Add integrity check
      final integrityHash = _createIntegrityHash(encrypted, derivedKey);
      
      // Return encrypted data with integrity check
      return '$encrypted:$integrityHash';
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  /// Decrypt sensitive data
  Future<String> decryptData(String encryptedText) async {
    try {
      // Split the encrypted text and integrity hash
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }
      
      final encrypted = parts[0];
      final integrityHash = parts[1];
      
      // Get the encryption key and salt
      final key = await _getEncryptionKey();
      final salt = await _getSalt();
      
      // Create a derived key using the main key and salt
      final derivedKey = _deriveKey(key, salt);
      
      // Verify integrity
      if (!_verifyIntegrityHash(encrypted, integrityHash, derivedKey)) {
        throw Exception('Data integrity check failed');
      }
      
      // Perform decryption
      return _decryptWithKey(encrypted, derivedKey);
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  /// Derive a key using the main key and salt
  String _deriveKey(String key, String salt) {
    // Create a derived key by hashing the key and salt together
    final keyBytes = base64Url.decode(key);
    final saltBytes = base64Url.decode(salt);
    
    final combined = Uint8List.fromList([...keyBytes, ...saltBytes]);
    final hash = sha256.convert(combined);
    
    return base64Url.encode(hash.bytes);
  }

  /// Encrypt using a derived key (simplified XOR-based encryption for demonstration)
  String _encryptWithKey(String plainText, String key) {
    final plainBytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(key);
    final encryptedBytes = <int>[];

    for (int i = 0; i < plainBytes.length; i++) {
      encryptedBytes.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Url.encode(encryptedBytes);
  }

  /// Decrypt using a derived key (simplified XOR-based decryption for demonstration)
  String _decryptWithKey(String encryptedText, String key) {
    final encryptedBytes = base64Url.decode(encryptedText);
    final keyBytes = utf8.encode(key);
    final decryptedBytes = <int>[];

    for (int i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decryptedBytes);
  }

  /// Create an integrity hash for the encrypted data
  String _createIntegrityHash(String encryptedData, String key) {
    final dataAndKey = '$encryptedData$key';
    final bytes = utf8.encode(dataAndKey);
    final hash = sha256.convert(bytes);
    return base64Url.encode(hash.bytes);
  }

  /// Verify the integrity of encrypted data
  bool _verifyIntegrityHash(String encryptedData, String integrityHash, String key) {
    final expectedHash = _createIntegrityHash(encryptedData, key);
    return expectedHash == integrityHash;
  }

  /// Encrypt request parameters
  Future<Map<String, dynamic>> encryptParameters(Map<String, dynamic> params) async {
    final encryptedParams = <String, dynamic>{};
    
    for (final entry in params.entries) {
      if (entry.value is String) {
        // Encrypt string values
        encryptedParams[entry.key] = await encryptData(entry.value as String);
      } else {
        // Keep non-string values as-is (or encrypt them differently if needed)
        encryptedParams[entry.key] = entry.value;
      }
    }
    
    return encryptedParams;
  }

  /// Decrypt response parameters
  Future<Map<String, dynamic>> decryptParameters(Map<String, dynamic> params) async {
    final decryptedParams = <String, dynamic>{};
    
    for (final entry in params.entries) {
      if (entry.value is String) {
        try {
          // Try to decrypt string values
          decryptedParams[entry.key] = await decryptData(entry.value as String);
        } catch (e) {
          // If decryption fails, keep the original value
          decryptedParams[entry.key] = entry.value;
        }
      } else {
        // Keep non-string values as-is
        decryptedParams[entry.key] = entry.value;
      }
    }
    
    return decryptedParams;
  }

  /// Securely store sensitive data
  Future<void> storeSensitiveData(String key, String data) async {
    final encryptedData = await encryptData(data);
    await _secureStorage.write(key: key, value: encryptedData);
  }

  /// Retrieve and decrypt sensitive data
  Future<String?> retrieveSensitiveData(String key) async {
    final encryptedData = await _secureStorage.read(key: key);
    if (encryptedData == null) {
      return null;
    }
    
    try {
      return await decryptData(encryptedData);
    } catch (e) {
      // If decryption fails, return null
      return null;
    }
  }

  /// Clear all encrypted data
  Future<void> clearAllEncryptedData() async {
    await _secureStorage.deleteAll();
  }
}

/// Parameter protection service
class ParameterProtectionService {
  static final ParameterProtectionService _instance = ParameterProtectionService._internal();
  factory ParameterProtectionService() => _instance;
  ParameterProtectionService._internal();

  final DataEncryptionService _encryptionService = DataEncryptionService();

  /// Obfuscate parameter names to prevent discovery
  Map<String, dynamic> obfuscateParameterNames(Map<String, dynamic> params) {
    // In a real implementation, you might use a mapping of obfuscated names
    // This is a simplified example
    final obfuscatedParams = <String, dynamic>{};
    
    for (final entry in params.entries) {
      // Generate an obfuscated parameter name
      final obfuscatedName = _generateObfuscatedName(entry.key);
      obfuscatedParams[obfuscatedName] = entry.value;
    }
    
    return obfuscatedParams;
  }

  /// Generate an obfuscated name for a parameter
  String _generateObfuscatedName(String originalName) {
    // This is a simple example - in a real implementation, use more sophisticated techniques
    // like time-based or session-based obfuscation
    return 'p_${DateTime.now().millisecondsSinceEpoch}_${originalName.hashCode.toUnsigned(32).toRadixString(36)}';
  }

  /// Encrypt sensitive parameter values
  Future<Map<String, dynamic>> encryptSensitiveParameters(Map<String, dynamic> params) async {
    return await _encryptionService.encryptParameters(params);
  }

  /// Decrypt sensitive parameter values
  Future<Map<String, dynamic>> decryptSensitiveParameters(Map<String, dynamic> params) async {
    return await _encryptionService.decryptParameters(params);
  }

  /// Create a secure parameter bundle
  Future<String> createSecureParameterBundle(Map<String, dynamic> params) async {
    // Encrypt the parameters
    final encryptedParams = await encryptSensitiveParameters(params);
    
    // Convert to JSON
    final jsonString = jsonEncode(encryptedParams);
    
    // Encrypt the entire parameter bundle
    return await _encryptionService.encryptData(jsonString);
  }

  /// Extract parameters from a secure bundle
  Future<Map<String, dynamic>> extractFromSecureBundle(String bundle) async {
    // Decrypt the bundle
    final decryptedJsonString = await _encryptionService.decryptData(bundle);
    
    // Parse the JSON
    final params = jsonDecode(decryptedJsonString) as Map<String, dynamic>;
    
    // Decrypt individual parameters
    return await decryptSensitiveParameters(params);
  }
}