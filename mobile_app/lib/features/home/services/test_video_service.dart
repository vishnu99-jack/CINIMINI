import 'dart:convert';
import 'package:mobile_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/config/endpoints.dart';
import 'package:mobile_app/models/video_model.dart';

class TestVideoService {
  // Fetch only the first video from PeerTube.
  Future<VideoModel> fetchFirstVideo() async {
    debugLog('========================================');
    debugLog('[API] CINIMINI PEERTUBE REQUEST STARTED');
    debugLog('========================================');

    final uri = Uri.parse(
      Endpoints.videos,
    ).replace(queryParameters: {'count': '1'});

    debugLog('[API] Request URL: $uri');

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      debugLog('[API] HTTP Status: ${response.statusCode}');
      debugLog('[API] Response received');

      if (response.statusCode != 200) {
        debugLog('[ERROR] PeerTube API request failed');
        debugLog('[ERROR] Response: ${response.body}');

        throw Exception('PeerTube API failed: HTTP ${response.statusCode}');
      }

      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is! Map<String, dynamic>) {
        throw Exception('Unexpected PeerTube response format');
      }

      final videos = decodedResponse['data'];

      if (videos is! List || videos.isEmpty) {
        throw Exception('No videos found in PeerTube');
      }

      debugLog('[API] Videos returned: ${videos.length}');

      final firstVideo = Map<String, dynamic>.from(videos.first);

      debugLog('[VIDEO] First video selected');
      debugLog('[VIDEO] Title: ${firstVideo['name']}');
      debugLog('[VIDEO] UUID: ${firstVideo['uuid']}');

      final video = VideoModel.fromJson(firstVideo);

      debugLog('[VIDEO] VideoModel created successfully');
      debugLog('========================================');

      return video;
    } catch (e, stackTrace) {
      debugLog('[ERROR] Video fetching failed: $e');
      debugLog('[ERROR] Stack trace: $stackTrace');

      rethrow;
    }
  }


  // ============================================
  // FETCH VIDEO DETAILS AND HLS PLAYLIST
  // ============================================

  Future<String> fetchVideoHlsUrl(String uuid) async {
    debugLog('');
    debugLog('========================================');
    debugLog('[API] FETCHING PEERTUBE VIDEO DETAILS');
    debugLog('========================================');

    final uri = Uri.parse('${Endpoints.videos}/$uuid');

    debugLog('[API] Details URL: $uri');
    debugLog('[VIDEO] UUID: $uuid');

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      debugLog('[API] HTTP Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Video details request failed: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      debugLog('[VIDEO] Title: ${data['name']}');

      final playlists = data['streamingPlaylists'];

      if (playlists == null || playlists.isEmpty) {
        throw Exception('No streaming playlists available');
      }

      debugLog('[HLS] Total playlists: ${playlists.length}');

      for (final playlist in playlists) {
        debugLog('[HLS] Playlist type: ${playlist['type']}');
        debugLog('[HLS] Playlist URL: ${playlist['playlistUrl']}');

        final files = playlist['files'];

        debugLog('[HLS] Available files: ${files?.length ?? 0}');
      }

      // Select the HLS playlist (type 1).
      final hlsPlaylists = playlists
          .where((playlist) => playlist['type'] == 1)
          .toList();

      if (hlsPlaylists.isEmpty) {
        throw Exception('No HLS playlist found');
      }

      final playlistUrl = hlsPlaylists.first['playlistUrl'];

      if (playlistUrl == null || playlistUrl.toString().isEmpty) {
        throw Exception('HLS playlist URL is empty');
      }

      final normalizedUrl = ApiConfig.normalizePeerTubeUrl(
        playlistUrl.toString(),
      );

      debugLog('[HLS] Playlist extraction successful');
      debugLog('[HLS] Original URL: $playlistUrl');
      debugLog('[HLS] Normalized URL: $normalizedUrl');
      debugLog('========================================');

      return normalizedUrl;
    } catch (e, stackTrace) {
      debugLog('[ERROR] Video details fetching failed: $e');
      debugLog('[ERROR] Stack trace: $stackTrace');

      rethrow;
    }
  }

  void debugLog(String message) {
    // ignore: avoid_print
    print(message);
  }
}
