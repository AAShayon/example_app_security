/// Configuration class for API security settings
class SecurityConfig {
  String baseUrl;
  Map<String, String> endpoints;
  bool enableCertificatePinning;
  bool enableDataEncryption;
  bool enableEndpointObfuscation;
  
  SecurityConfig({
    required this.baseUrl,
    required this.endpoints,
    this.enableCertificatePinning = true,
    this.enableDataEncryption = true,
    this.enableEndpointObfuscation = true,
  });
  
  /// Update the base URL
  void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
  }
  
  /// Update specific endpoint
  void updateEndpoint(String key, String path) {
    endpoints[key] = path;
  }
  
  /// Get an endpoint by key
  String? getEndpoint(String key) {
    return endpoints[key];
  }
  
  /// Get all endpoints
  Map<String, String> getAllEndpoints() {
    return endpoints;
  }
}