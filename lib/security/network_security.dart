import 'dart:io';

class NetworkSecurity {
  static HttpClient secureHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          // Compare cert SHA256 fingerprint here
          return false;
        };
    return client;
  }
}
