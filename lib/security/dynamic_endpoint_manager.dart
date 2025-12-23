import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'enhanced_security_manager.dart';

/// Dynamic API endpoint manager that fetches encrypted endpoint configurations
class DynamicEndpointManager {
  static final DynamicEndpointManager _instance = DynamicEndpointManager._internal();
  factory DynamicEndpointManager() => _instance;
  DynamicEndpointManager._internal();

  static const MethodChannel _channel = MethodChannel('dynamic_endpoints');
  final EnhancedSecurityManager _securityManager = EnhancedSecurityManager();
  
  Map<String, String>? _endpoints;
  int? _lastUpdateTimestamp;
  String? _currentKey;

  /// Initialize the endpoint manager
  Future<void> initialize() async {
    await _loadEndpoints();
  }

  /// Load endpoints from secure native storage
  Future<void> _loadEndpoints() async {
    try {
      // Fetch encrypted endpoints from native layer
      final encryptedEndpoints = await _channel.invokeMethod('getEncryptedEndpoints');
      
      if (encryptedEndpoints != null && encryptedEndpoints.isNotEmpty) {
        // Decrypt the endpoints
        final decryptedEndpoints = await _decryptEndpoints(encryptedEndpoints);
        _endpoints = decryptedEndpoints;
      } else {
        // Fallback to default encrypted endpoints if none found
        _endpoints = await _getDefaultEndpoints();
      }
    } catch (e) {
      // If native method fails, use fallback
      _endpoints = await _getDefaultEndpoints();
    }
  }

  /// Get default endpoints (encrypted and stored securely)
  Future<Map<String, String>> _getDefaultEndpoints() async {
    // These are encrypted default endpoints that are securely stored
    // In a real implementation, these would be securely stored in native storage
    return {
      'restrooms_search': _decryptEndpoint('L2FwaS92MS9yZXN0cm9vbXMvc2VhcmNo'), // '/api/v1/restrooms/search' when base64 decoded
      'restrooms_by_location': _decryptEndpoint('L2FwaS92MS9yZXN0cm9vbXMvYnVfbG9jYXRpb24='), // '/api/v1/restrooms/by_location' when base64 decoded
      'posts': _decryptEndpoint('L2FwaS9wb3N0cw=='), // '/api/posts' when base64 decoded
      'users': _decryptEndpoint('L2FwaS91c2Vycw=='), // '/api/users' when base64 decoded
      'comments': _decryptEndpoint('L2FwaS9jb21tZW50cw=='), // '/api/comments' when base64 decoded
    };
  }

  /// Get a specific endpoint by name
  String? getEndpoint(String name) {
    return _endpoints?[name];
  }

  /// Get all endpoints
  Map<String, String> getAllEndpoints() {
    return _endpoints ?? {};
  }

  /// Update endpoints (called when configuration changes)
  Future<void> updateEndpoints(Map<String, String> newEndpoints) async {
    _endpoints = newEndpoints;
    _lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Encrypt and store endpoints in native storage
    try {
      final encryptedEndpoints = await _encryptEndpoints(newEndpoints);
      await _channel.invokeMethod('setEncryptedEndpoints', {
        'endpoints': encryptedEndpoints,
      });
    } catch (e) {
      // Handle error - in production, you might want to store locally as backup
    }
  }

  /// Encrypt endpoints for storage
  Future<String> _encryptEndpoints(Map<String, String> endpoints) async {
    final jsonString = jsonEncode(endpoints);
    final sessionToken = await _securityManager.getSessionToken() ?? 'default';
    
    // Create encryption key from session token
    final key = _deriveKey(sessionToken);
    
    // Simple encryption using XOR (in production, use proper encryption like AES)
    final encrypted = _simpleEncrypt(jsonString, key);
    return base64Encode(encrypted);
  }

  /// Decrypt endpoints from storage
  Future<Map<String, String>> _decryptEndpoints(String encryptedEndpoints) async {
    try {
      final encryptedBytes = base64Decode(encryptedEndpoints);
      final sessionToken = await _securityManager.getSessionToken() ?? 'default';
      
      // Create decryption key from session token
      final key = _deriveKey(sessionToken);
      
      // Simple decryption using XOR (in production, use proper encryption like AES)
      final decryptedBytes = _simpleDecrypt(encryptedBytes, key);
      final jsonString = String.fromCharCodes(decryptedBytes);
      
      final endpoints = jsonDecode(jsonString) as Map<String, dynamic>;
      return Map<String, String>.from(endpoints);
    } catch (e) {
      // If decryption fails, return empty map
      return {};
    }
  }

  /// Derive encryption key from session token
  String _deriveKey(String sessionToken) {
    final bytes = utf8.encode(sessionToken);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes).substring(0, 32); // Use first 32 chars as key
  }

  /// Simple encryption using XOR (use proper encryption in production)
  List<int> _simpleEncrypt(String input, String key) {
    final inputBytes = utf8.encode(input);
    final keyBytes = utf8.encode(key);
    final result = <int>[];

    for (int i = 0; i < inputBytes.length; i++) {
      result.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return result;
  }

  /// Simple decryption using XOR (use proper decryption in production)
  List<int> _simpleDecrypt(List<int> input, String key) {
    // XOR is symmetric, so encryption and decryption are the same
    return _simpleEncrypt(String.fromCharCodes(input), key);
  }

  /// Decrypt a single endpoint that was stored as encrypted
  String _decryptEndpoint(String encryptedEndpoint) {
    try {
      // Base64 decode the endpoint
      final decodedBytes = base64Decode(encryptedEndpoint);
      return String.fromCharCodes(decodedBytes);
    } catch (e) {
      // Return the encrypted string as fallback
      return encryptedEndpoint;
    }
  }

  /// Check if endpoints need to be refreshed
  bool shouldRefreshEndpoints() {
    if (_lastUpdateTimestamp == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final refreshInterval = 1 * 60 * 60 * 1000; // Refresh every hour in milliseconds

    return (currentTime - _lastUpdateTimestamp!) > refreshInterval;
  }

  /// Validate that the endpoint configuration is legitimate
  bool isValidConfiguration() {
    // Check if we have endpoints and they follow expected patterns
    if (_endpoints == null || _endpoints!.isEmpty) return false;

    // Validate that endpoints don't contain obvious malicious patterns
    for (final endpoint in _endpoints!.values) {
      if (endpoint.contains('192.168.') || 
          endpoint.contains('10.0.') || 
          endpoint.contains('.local') ||
          endpoint.contains('localhost')) {
        // These might be development endpoints - validate in production
        return false;
      }
    }

    return true;
  }
}

/// Native endpoint configuration manager
/// This would be implemented in the native layer (Android/iOS) for maximum security
class NativeEndpointConfig {
  static const MethodChannel _channel = MethodChannel('native_endpoint_config');

  /// Fetch the latest encrypted endpoint configuration from native layer
  static Future<Map<String, String>> fetchEncryptedConfig() async {
    try {
      final result = await _channel.invokeMethod('fetchEncryptedConfig');
      if (result != null && result is Map) {
        return Map<String, String>.from(result);
      }
      return {};
    } catch (e) {
      // Return empty map if native method fails
      return {};
    }
  }

  /// Store encrypted endpoint configuration in native layer
  static Future<void> storeEncryptedConfig(Map<String, String> config) async {
    try {
      await _channel.invokeMethod('storeEncryptedConfig', {
        'config': config,
      });
    } catch (e) {
      // Handle error appropriately
    }
  }

  /// Verify app integrity at the native level
  static Future<bool> verifyAppIntegrity() async {
    try {
      final result = await _channel.invokeMethod('verifyAppIntegrity');
      return result == true;
    } catch (e) {
      return false;
    }
  }
}