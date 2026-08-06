import 'api_config.dart';

class Endpoints {
  static String get baseUrl => ApiConfig.baseUrl;

  static String get videos =>
      "$baseUrl/api/v1/videos";
}