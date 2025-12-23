import 'package:flutter/foundation.dart';

class AppIntegrity {
  static Future<void> checkDebugMode() async {
    if (kDebugMode) {
      throw Exception('Debug mode detected!');
    }
  }
}
