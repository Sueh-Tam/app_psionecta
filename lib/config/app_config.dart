import 'package:flutter/foundation.dart';

class AppConfig {
  // Resolve a baseUrl adequada para cada plataforma
  static String get baseUrl {
    // Web (Chrome/Firefox): usa localhost padrão
    if (kIsWeb) {
      return 'http://192.168.1.5:800/api';
    }

    // Emulador Android: 10.0.2.2 aponta para o host
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.5:800/api';
    }

    // iOS/macOS/Windows/Linux (simuladores/desktop)
    return 'http://192.168.1.5:800/api';
  }
}