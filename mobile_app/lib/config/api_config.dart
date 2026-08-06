import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return "http://localhost:9000";
    }

    // Windows / Linux / macOS
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return "http://localhost:9000";
    }

    // Android Emulator
    if (Platform.isAndroid) {
      return "http://10.0.2.2:9000";
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://localhost:9000";
    }

    return "http://localhost:9000";
  }
}
