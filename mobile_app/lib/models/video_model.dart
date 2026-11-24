import '../config/endpoints.dart';

/// ===============================================================
/// Cinimini Video Model
/// ---------------------------------------------------------------
/// Represents the summary information returned by:
///
/// GET /api/v1/videos
///
/// Detailed playback information is intentionally NOT stored here.
/// Playback information is fetched separately through
/// VideoDetailsRepository.
/// ===============================================================

class VideoModel {
  final int id;
  final String uuid;
  final String title;
  final String thumbnail;
  final String channel;

  const VideoModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.thumbnail,
    required this.channel,
  });

  /// Creates a VideoModel from PeerTube's video summary response.
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final channelData = json['channel'];

    return VideoModel(
      id: _parseInt(json['id']),
      uuid: json['uuid']?.toString() ?? '',
      title: json['name']?.toString() ?? '',
      thumbnail: _buildThumbnailUrl(json['thumbnailPath']?.toString()),
      channel: channelData is Map<String, dynamic>
          ? channelData['displayName']?.toString() ?? ''
          : '',
    );
  }

  // ===============================================================
  // Thumbnail
  // ===============================================================

  static String _buildThumbnailUrl(String? thumbnailPath) {
    if (thumbnailPath == null || thumbnailPath.isEmpty) {
      return '';
    }

    // Already an absolute URL.
    if (thumbnailPath.startsWith('http://') ||
        thumbnailPath.startsWith('https://')) {
      return thumbnailPath;
    }

    return '${Endpoints.baseUrl}$thumbnailPath';
  }

  // ===============================================================
  // Integer Parsing
  // ===============================================================

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ===============================================================
  // HLS URL
  // ===============================================================
  //
  // NOTE:
  // This remains available for future use.
  //
  // Our current MediaKit player uses VideoDetailsRepository because
  // PeerTube's /api/v1/videos/{uuid} response gives us the actual
  // playable streaming playlist.
  // ===============================================================

  String get hlsUrl {
    return '${Endpoints.baseUrl}/static/streaming-playlists/hls/$uuid/master.m3u8';
  }

  // ===============================================================
  // Utility
  // ===============================================================

  @override
  String toString() {
    return 'VideoModel('
        'id: $id, '
        'uuid: $uuid, '
        'title: $title, '
        'channel: $channel'
        ')';
  }
}
