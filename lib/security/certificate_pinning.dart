import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Advanced certificate pinning implementation
class CertificatePinning {
  // Known certificate fingerprints for the API endpoints
  static const Map<String, Set<String>> _pinnedCertificates = {
    'jsonplaceholder.typicode.com': {
      // These are example fingerprints - in a real app, use actual certificate fingerprints
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Example placeholder
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Example placeholder
    },
    'api.weatherapi.com': {
      // Example for weather API
      'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
    },
  };

  /// Verify the certificate against pinned fingerprints
  static bool verifyCertificate(X509Certificate cert, String host, int port) {
    // In debug mode, allow all certificates for development
    if (kDebugMode) {
      print('Certificate pinning skipped in debug mode for: $host');
      return true;
    }

    // Get the pinned certificates for this host
    final pinnedFingerprints = _pinnedCertificates[host];
    if (pinnedFingerprints == null || pinnedFingerprints.isEmpty) {
      print('No pinned certificates found for host: $host');
      return false;
    }

    // Calculate the certificate fingerprint
    final certFingerprint = _calculateCertFingerprint(cert);

    // Check if the certificate fingerprint matches any of the pinned ones
    if (pinnedFingerprints.contains(certFingerprint)) {
      print('Certificate pinning successful for: $host');
      return true;
    } else {
      print('Certificate pinning failed for: $host. Expected one of: $pinnedFingerprints, got: $certFingerprint');
      return false;
    }
  }

  /// Calculate the SHA-256 fingerprint of a certificate
  static String _calculateCertFingerprint(X509Certificate cert) {
    // Get the raw certificate bytes
    final certBytes = _parseCertificateBytes(cert.pem);
    
    // Calculate SHA-256 hash
    final hash = sha256.convert(certBytes);
    
    // Encode as base64
    final encodedHash = base64Encode(hash.bytes);
    
    return 'sha256/$encodedHash';
  }

  /// Parse certificate bytes from PEM format
  static Uint8List _parseCertificateBytes(String pem) {
    // Remove the PEM header and footer
    final lines = pem.split('\n');
    final base64Lines = <String>[];
    
    bool inCertificate = false;
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine == '-----BEGIN CERTIFICATE-----') {
        inCertificate = true;
      } else if (trimmedLine == '-----END CERTIFICATE-----') {
        inCertificate = false;
        break;
      } else if (inCertificate && trimmedLine.isNotEmpty) {
        base64Lines.add(trimmedLine);
      }
    }
    
    // Join the base64 lines and decode
    final base64String = base64Lines.join('');
    return base64Decode(base64String);
  }

  /// Get the pinned certificate fingerprints for a host
  static Set<String>? getPinnedFingerprints(String host) {
    return _pinnedCertificates[host];
  }

  /// Add a new pinned certificate for a host (for dynamic updates)
  static void addPinnedCertificate(String host, String fingerprint) {
    if (!_pinnedCertificates.containsKey(host)) {
      _pinnedCertificates[host] = <String>{};
    }
    _pinnedCertificates[host]!.add(fingerprint);
  }

  /// Update all pinned certificates for a host
  static void updatePinnedCertificates(String host, Set<String> fingerprints) {
    _pinnedCertificates[host] = fingerprints;
  }
}

/// Enhanced HTTP client with certificate pinning
class SecureHttpClient {
  /// Create an HTTP client with certificate pinning enabled
  static HttpClient create() {
    final client = HttpClient();
    
    // Set up certificate pinning
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return CertificatePinning.verifyCertificate(cert, host, port);
    };
    
    return client;
  }

  /// Create a Dio client with certificate pinning and additional security
  static Future<Map<String, dynamic>> makeSecureRequest({
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final httpClient = create();
    
    try {
      HttpClientRequest request;
      
      switch (method.toUpperCase()) {
        case 'GET':
          request = await httpClient.getUrl(Uri.parse(url));
          break;
        case 'POST':
          request = await httpClient.postUrl(Uri.parse(url));
          if (body != null) {
            request.write(jsonEncode(body));
          }
          break;
        case 'PUT':
          request = await httpClient.putUrl(Uri.parse(url));
          if (body != null) {
            request.write(jsonEncode(body));
          }
          break;
        case 'DELETE':
          request = await httpClient.deleteUrl(Uri.parse(url));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      // Add headers
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      
      // Set content type for JSON requests
      if (body != null) {
        request.headers.contentType = ContentType.json;
      }
      
      // Send the request
      final response = await request.close();
      
      // Read the response
      final responseBody = await response.transform(utf8.decoder).join();
      
      // Close the client
      httpClient.close();
      
      // Return the response
      return {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': responseBody,
      };
    } catch (e) {
      httpClient.close();
      throw Exception('Secure request failed: $e');
    }
  }
}

/// Certificate management utility
class CertificateManager {
  /// Validate a certificate against known good fingerprints
  static bool validateCertificate(X509Certificate cert, String host) {
    // In a real implementation, you might:
    // 1. Check against a local database of known certificates
    // 2. Verify against a trusted certificate authority
    // 3. Check certificate expiration dates
    // 4. Validate certificate chain
    
    // For this example, we'll use the CertificatePinning class
    return CertificatePinning.verifyCertificate(cert, host, 443);
  }

  /// Get certificate information for debugging purposes
  static Map<String, dynamic> getCertificateInfo(X509Certificate cert) {
    return {
      'subject': cert.subject,
      'issuer': cert.issuer,
      'fingerprint': CertificatePinning._calculateCertFingerprint(cert),
    };
  }

  /// Check if a certificate is expired
  static bool isCertificateExpired(X509Certificate cert) {
    // This method is not used in the current implementation but kept for future use
    return false;
  }

  /// Check if a certificate is not yet valid
  static bool isCertificateNotYetValid(X509Certificate cert) {
    // This method is not used in the current implementation but kept for future use
    return false;
  }
}