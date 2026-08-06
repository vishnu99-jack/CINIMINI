import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/endpoints.dart';

class VideoDetailsService {
  Future<String> fetchPlayableVideo(String uuid) async {
    final response = await http.get(Uri.parse("${Endpoints.videos}/$uuid"));

    if (response.statusCode != 200) {
      throw Exception("Failed to load video details");
    }

    final json = jsonDecode(response.body);

    // Safety checks
    if (json["streamingPlaylists"] == null ||
        (json["streamingPlaylists"] as List).isEmpty) {
      throw Exception("No streaming playlist found.");
    }

    final playlist = json["streamingPlaylists"][0];

    if (playlist["files"] == null || (playlist["files"] as List).isEmpty) {
      throw Exception("No playable video found.");
    }

    return playlist["files"][0]["fileUrl"];
  }
}
