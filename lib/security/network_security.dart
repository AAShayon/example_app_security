import 'dart:io';
import 'package:dio/dio.dart';
import 'enhanced_network_security.dart';
import 'certificate_pinning.dart';

class NetworkSecurity {
  static final EnhancedNetworkSecurity _enhancedSecurity = EnhancedNetworkSecurity();

  static HttpClient secureHttpClient() {
    return SecureHttpClient.create();
  }

  // Use the enhanced Dio client for more advanced security
  static Dio secureDioClient() {
    return _enhancedSecurity.createSecureDio();
  }

  // Obfuscate endpoints
  static String obfuscateEndpoint(String endpoint) {
    return _enhancedSecurity.obfuscateEndpoint(endpoint);
  }

  // Get obfuscated base URL
  static String getObfuscatedBaseUrl() {
    return _enhancedSecurity.getBaseUrl();
  }

  // Set base URL dynamically
  static void setBaseUrl(String baseUrl) {
    _enhancedSecurity.setBaseUrl(baseUrl);
  }

  // Make a secure request with certificate pinning
  static Future<Map<String, dynamic>> makeSecureRequest({
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return await SecureHttpClient.makeSecureRequest(
      url: url,
      method: method,
      headers: headers,
      body: body,
    );
  }
}
