import 'package:dio/dio.dart';
import '../security/network_security.dart';
import '../security/enhanced_network_security.dart';
import '../security/data_encryption_service.dart';
import '../security/enhanced_security_manager.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final EnhancedNetworkSecurity _networkSecurity = EnhancedNetworkSecurity();
  final EnhancedSecurityManager _securityManager = EnhancedSecurityManager();
  final DataEncryptionService _encryptionService = DataEncryptionService();
  final ParameterProtectionService _paramProtection = ParameterProtectionService();

  // Getters for testing and external access
  EnhancedNetworkSecurity get networkSecurity => _networkSecurity;
  EnhancedSecurityManager get securityManager => _securityManager;
  DataEncryptionService get encryptionService => _encryptionService;
  ParameterProtectionService get paramProtection => _paramProtection;

  Future<List<dynamic>> fetchPosts() async {
    try {
      // Initialize encryption service if not already done
      await _encryptionService.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint('/posts');

      final response = await dio.get(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        // Decrypt response if needed
        final data = response.data as List;
        return data;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPost(int id) async {
    try {
      // Initialize encryption service if not already done
      await _encryptionService.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint('/posts/$id');

      final response = await dio.get(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        // Decrypt response if needed
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to send encrypted parameters
  Future<List<dynamic>> fetchPostsWithEncryptedParams({
    Map<String, dynamic>? params,
  }) async {
    try {
      // Initialize services if not already done
      await _encryptionService.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint('/posts');

      // Encrypt and obfuscate parameters if provided
      Map<String, dynamic>? processedParams;
      if (params != null) {
        // Obfuscate parameter names
        final obfuscatedParams = _paramProtection.obfuscateParameterNames(params);

        // Encrypt sensitive parameter values
        processedParams = await _paramProtection.encryptSensitiveParameters(obfuscatedParams);
      }

      final response = await dio.get(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
        queryParameters: processedParams,
      );

      if (response.statusCode == 200) {
        // Decrypt response if needed
        final data = response.data as List;
        return data;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Alternative method using the enhanced security request
  Future<List<dynamic>> fetchPostsWithEnhancedSecurity() async {
    try {
      // Initialize encryption service if not already done
      await _encryptionService.initialize();

      final response = await _networkSecurity.secureRequest(
        endpoint: '/posts',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
