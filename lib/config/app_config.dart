import 'package:flutter/foundation.dart';

class AppConfig {
  static const String universalBaseUrl = 'http://SUA_URL/api';
  static String get baseUrl {
    if (kIsWeb) {
      return universalBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return universalBaseUrl;
    }
    return universalBaseUrl;
  }
}