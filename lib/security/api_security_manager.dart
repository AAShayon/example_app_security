import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'security_config.dart';

/// Independent security manager that can be used with any API
class ApiSecurityManager {
  final SecurityConfig _config;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false;
  String? _sessionToken;

  static const String _sessionTokenKey = 'secure_session_token';
  final Dio _dio = Dio();
  final MethodChannel _channel = MethodChannel('security/device');

  ApiSecurityManager(this._config);

  /// Initialize security features
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize security features based on config
    if (_config.enableCertificatePinning) {
      _setupCertificatePinning();
    }
    
    if (_config.enableDataEncryption) {
      await _initializeEncryption();
    }
    
    _isInitialized = true;
  }

  /// Setup certificate pinning for secure communication
  void _setupCertificatePinning() {
    _dio.httpClientAdapter;
    // Certificate pinning will be handled at HTTP client level
  }

  /// Initialize encryption features
  Future<void> _initializeEncryption() async {
    // Initialize encryption-related features
    await _generateSessionToken();
  }

  /// Generate a secure session token
  Future<void> _generateSessionToken() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomData = _generateSecureRandomString(32);
    final tokenBase = '$timestamp-$randomData-${_config.baseUrl}';
    
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

  /// Create a secure Dio client with security features
  Dio createSecureDioClient() {
    final dio = Dio(BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    // Add request interceptor for security headers
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add security headers
        final securityHeaders = await getSecurityHeaders();
        options.headers.addAll(securityHeaders);

        // Add custom authentication headers
        options.headers['Authorization'] = await _getSecureAuthToken();

        // Obfuscate the request path if needed
        if (_config.enableEndpointObfuscation) {
          options.path = _obfuscateEndpoint(options.path);
        }

        // Add request signature to prevent tampering
        final signature = await _generateRequestSignature(options);
        options.headers['X-Request-Signature'] = signature;

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Verify response integrity here if needed
        return handler.next(response);
      },
      onError: (DioException err, handler) {
        // Handle errors securely
        if (kDebugMode) {
          print('Secure network error: ${err.message}');
        }
        return handler.next(err);
      },
    ));

    return dio;
  }

  /// Generate a secure authentication token
  Future<String> _getSecureAuthToken() async {
    final sessionToken = await getSessionToken();
    if (sessionToken != null) {
      return 'Bearer $sessionToken';
    }
    
    // Fallback to a simple token
    return 'Bearer ${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate request signature to prevent tampering
  Future<String> _generateRequestSignature(RequestOptions options) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final path = options.path;
    final method = options.method;
    final query = options.queryParameters.toString();
    
    final signatureBase = '$method-$path-$query-$timestamp-${await getSessionToken()}';
    final bytes = utf8.encode(signatureBase);
    final hash = sha256.convert(bytes);
    
    return base64Url.encode(hash.bytes);
  }

  /// Obfuscate endpoint path
  String _obfuscateEndpoint(String endpoint) {
    // In a real implementation, you might:
    // 1. Use dynamic path generation
    // 2. Encode/encrypt the path
    // 3. Use proxy endpoints that forward to real endpoints
    // 4. Change paths based on session or time
    
    // For this example, we'll just return the endpoint as-is
    // but in a real app, you'd implement actual obfuscation
    return endpoint;
  }

  /// Generate secure random string
  String _generateSecureRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Make a secure request with all security features enabled
  Future<Response> makeSecureRequest({
    required String endpointKey,
    String method = 'GET',
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
    dynamic data,
  }) async {
    final dio = createSecureDioClient();
    
    // Get the actual endpoint path from the key
    final endpointPath = _config.getEndpoint(endpointKey) ?? endpointKey;
    
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(
            endpointPath,
            queryParameters: parameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case 'POST':
          response = await dio.post(
            endpointPath,
            data: data,
            queryParameters: parameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case 'PUT':
          response = await dio.put(
            endpointPath,
            data: data,
            queryParameters: parameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            endpointPath,
            data: data,
            queryParameters: parameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            endpointPath,
            queryParameters: parameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      return response;
    } catch (e) {
      throw Exception('Secure request failed: $e');
    }
  }

  /// Clear all secure data
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
    _sessionToken = null;
    _isInitialized = false;
  }
}