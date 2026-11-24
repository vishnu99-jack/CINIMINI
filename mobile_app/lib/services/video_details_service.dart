import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/endpoints.dart';
import '../config/api_config.dart';

class VideoDetailsService {
  Future<String> fetchPlayableVideo(String uuid) async {
    print('');
    print('========================================');
    print('[API] FETCHING PEERTUBE VIDEO DETAILS');
    print('========================================');

    final uri = Uri.parse('${Endpoints.videos}/$uuid');

    print('[API] Request URL: $uri');
    print('[VIDEO] UUID: $uuid');

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      print('[API] HTTP Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Video details request failed: HTTP ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      print('[VIDEO] Title: ${data['name']}');

      // ========================================
      // CHECK STREAMING PLAYLISTS
      // ========================================

      final playlists = data['streamingPlaylists'];

      if (playlists is! List || playlists.isEmpty) {
        throw Exception('No streaming playlists available');
      }

      print('[HLS] Total playlists: ${playlists.length}');

      for (final playlist in playlists) {
        print('[HLS] Playlist type: ${playlist['type']}');
        print('[HLS] Playlist URL: ${playlist['playlistUrl']}');

        final files = playlist['files'];

        print('[HLS] Available files: ${files is List ? files.length : 0}');
      }

      // ========================================
      // SELECT HLS PLAYLIST
      // ========================================

      final hlsPlaylists = playlists
          .where((playlist) => playlist is Map && playlist['type'] == 1)
          .toList();

      if (hlsPlaylists.isEmpty) {
        throw Exception('No HLS playlist found');
      }

      final playlistUrl = hlsPlaylists.first['playlistUrl'];

      if (playlistUrl == null || playlistUrl.toString().isEmpty) {
        throw Exception('HLS playlist URL is empty');
      }

      // ========================================
      // NORMALIZE PEERTUBE URL
      // ========================================

      final normalizedUrl = ApiConfig.normalizePeerTubeUrl(
        playlistUrl.toString(),
      );

      print('[HLS] Playlist extraction successful');
      print('[HLS] Original URL: $playlistUrl');
      print('[HLS] Normalized URL: $normalizedUrl');

      print('========================================');

      return normalizedUrl;
    } catch (e, stackTrace) {
      print('[ERROR] Video details fetching failed: $e');
      print('[ERROR] Stack trace: $stackTrace');

      rethrow;
    }
  }
}
