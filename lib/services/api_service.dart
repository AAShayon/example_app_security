import 'package:dio/dio.dart';
import '../security/network_security.dart';
import '../security/enhanced_network_security.dart';
import '../security/data_encryption_service.dart';
import '../security/enhanced_security_manager.dart';
import '../security/dynamic_endpoint_manager.dart';

class ApiService {
  final EnhancedNetworkSecurity _networkSecurity = EnhancedNetworkSecurity();
  final EnhancedSecurityManager _securityManager = EnhancedSecurityManager();
  final DataEncryptionService _encryptionService = DataEncryptionService();
  final ParameterProtectionService _paramProtection = ParameterProtectionService();
  final DynamicEndpointManager _dynamicEndpointManager = DynamicEndpointManager();

  // Getters for testing and external access
  EnhancedNetworkSecurity get networkSecurity => _networkSecurity;
  EnhancedSecurityManager get securityManager => _securityManager;
  DataEncryptionService get encryptionService => _encryptionService;
  ParameterProtectionService get paramProtection => _paramProtection;
  DynamicEndpointManager get dynamicEndpointManager => _dynamicEndpointManager;

  Future<List<dynamic>> fetchPosts() async {
    try {
      // Initialize encryption service if not already done
      await _encryptionService.initialize();
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final endpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

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
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final baseEndpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';
      final endpoint = '$baseEndpoint/$id';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

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
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final endpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

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
      await _dynamicEndpointManager.initialize();

      // Get the dynamic endpoint for posts
      final endpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';

      final response = await _networkSecurity.secureRequest(
        endpoint: endpoint,
        method: 'GET',
      );

      if (response.statusCode != null && response.statusCode == 200) {
        final data = response.data as List;
        return data;
      } else {
        final statusCode = response.statusCode ?? 'unknown';
        throw Exception('Failed to load posts: $statusCode');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST request method
  Future<dynamic> createPost(Map<String, dynamic> data) async {
    try {
      // Initialize services if not already done
      await _encryptionService.initialize();
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final endpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

      final response = await dio.post(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
        data: data,
      );

      if (response.statusCode != null && (response.statusCode == 200 || response.statusCode == 201)) {
        // Decrypt response if needed
        return response.data;
      } else {
        final statusCode = response.statusCode ?? 'unknown';
        throw Exception('Failed to create post: $statusCode');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PUT request method
  Future<dynamic> updatePost(int id, Map<String, dynamic> data) async {
    try {
      // Initialize services if not already done
      await _encryptionService.initialize();
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final baseEndpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';
      final endpoint = '$baseEndpoint/$id';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

      final response = await dio.put(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
        data: data,
      );

      if (response.statusCode != null && response.statusCode == 200) {
        // Decrypt response if needed
        return response.data;
      } else {
        final statusCode = response.statusCode ?? 'unknown';
        throw Exception('Failed to update post: $statusCode');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PATCH request method
  Future<dynamic> patchPost(int id, Map<String, dynamic> data) async {
    try {
      // Initialize services if not already done
      await _encryptionService.initialize();
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final baseEndpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';
      final endpoint = '$baseEndpoint/$id';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

      final response = await dio.patch(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
        data: data,
      );

      if (response.statusCode != null && response.statusCode == 200) {
        // Decrypt response if needed
        return response.data;
      } else {
        final statusCode = response.statusCode ?? 'unknown';
        throw Exception('Failed to patch post: $statusCode');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// DELETE request method
  Future<bool> deletePost(int id) async {
    try {
      // Initialize services if not already done
      await _encryptionService.initialize();
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Get the dynamic endpoint for posts
      final baseEndpoint = _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';
      final endpoint = '$baseEndpoint/$id';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(endpoint);

      final response = await dio.delete(
        obfuscatedEndpoint,
        options: Options(
          headers: await _securityManager.getSecurityHeaders(),
        ),
      );

      if (response.statusCode != null && (response.statusCode == 200 || response.statusCode == 204)) {
        return true;
      } else {
        final statusCode = response.statusCode ?? 'unknown';
        throw Exception('Failed to delete post: $statusCode');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic request method
  Future<dynamic> makeRequest({
    required String method,
    String? endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    try {
      // Initialize services if not already done
      await _encryptionService.initialize();
      await _dynamicEndpointManager.initialize();

      // Use the enhanced security client
      final dio = NetworkSecurity.secureDioClient();

      // Use provided endpoint or get from dynamic manager
      String actualEndpoint = endpoint ?? _dynamicEndpointManager.getEndpoint('posts') ?? '/posts';

      // Obfuscate the endpoint
      final obfuscatedEndpoint = NetworkSecurity.obfuscateEndpoint(actualEndpoint);

      // Encrypt and obfuscate parameters if provided
      Map<String, dynamic>? processedParams;
      if (params != null) {
        // Obfuscate parameter names
        final obfuscatedParams = _paramProtection.obfuscateParameterNames(params);

        // Encrypt sensitive parameter values
        processedParams = await _paramProtection.encryptSensitiveParameters(obfuscatedParams);
      }

      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(
            obfuscatedEndpoint,
            options: Options(
              headers: await _securityManager.getSecurityHeaders(),
            ),
            queryParameters: processedParams,
          );
          break;
        case 'POST':
          response = await dio.post(
            obfuscatedEndpoint,
            options: Options(
              headers: await _securityManager.getSecurityHeaders(),
            ),
            data: data,
            queryParameters: processedParams,
          );
          break;
        case 'PUT':
          response = await dio.put(
            obfuscatedEndpoint,
            options: Options(
              headers: await _securityManager.getSecurityHeaders(),
            ),
            data: data,
            queryParameters: processedParams,
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            obfuscatedEndpoint,
            options: Options(
              headers: await _securityManager.getSecurityHeaders(),
            ),
            data: data,
            queryParameters: processedParams,
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            obfuscatedEndpoint,
            options: Options(
              headers: await _securityManager.getSecurityHeaders(),
            ),
            queryParameters: processedParams,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        // Decrypt response if needed
        return response.data;
      } else {
        final statusCode = response.statusCode ?? 'unknown';
        throw Exception('Request failed: $statusCode');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
