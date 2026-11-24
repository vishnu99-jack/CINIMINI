import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Build-time configuration
  static const String _lanHost = String.fromEnvironment('LAN_HOST');

  static const String _backendOverride = String.fromEnvironment('BACKEND_URL');

  static const String _peerTubeOverride = String.fromEnvironment(
    'PEERTUBE_URL',
  );

  // ------------------------------------------------------------
  // NODE.JS BACKEND
  // Default port: 3000
  // ------------------------------------------------------------

  static String get backendUrl {
    if (_backendOverride.isNotEmpty) {
      return _backendOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      if (_lanHost.isNotEmpty) {
        return 'http://$_lanHost:3000';
      }

      // Default for Android Emulator
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  // ------------------------------------------------------------
  // PEERTUBE SERVER
  // Default port: 9000
  // ------------------------------------------------------------

  static String get peerTubeUrl {
    if (_peerTubeOverride.isNotEmpty) {
      return _peerTubeOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:9000';
    }

    if (Platform.isAndroid) {
      if (_lanHost.isNotEmpty) {
        return 'http://$_lanHost:9000';
      }

      // Default for Android Emulator
      return 'http://10.0.2.2:9000';
    }

    return 'http://localhost:9000';
  }

  // ------------------------------------------------------------
  // BACKWARD COMPATIBILITY
  // Existing code using ApiConfig.baseUrl continues to work.
  // ------------------------------------------------------------

  static String get baseUrl => peerTubeUrl;

  // ------------------------------------------------------------
  // NORMALIZE PEERTUBE URLS
  // Replace localhost URLs returned by PeerTube API with the
  // currently configured PeerTube server address.
  // ------------------------------------------------------------

  static String normalizePeerTubeUrl(String url) {
    final originalUri = Uri.parse(url);

    if (originalUri.host != 'localhost' && originalUri.host != '127.0.0.1') {
      return url;
    }

    final configuredUri = Uri.parse(peerTubeUrl);

    return originalUri
        .replace(
          scheme: configuredUri.scheme,
          host: configuredUri.host,
          port: configuredUri.port,
        )
        .toString();
  }
}
