import '../config/endpoints.dart';

class VideoModel {
  final int id;
  final String uuid;
  final String title;
  final String thumbnail;
  final String channel;

  VideoModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.thumbnail,
    required this.channel,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      uuid: json['uuid'],
      title: json['name'] ?? '',
      thumbnail: "${Endpoints.baseUrl}${json['thumbnailPath']}",
      channel: json['channel']['displayName'] ?? '',
    );
  }

  String get hlsUrl =>
      "${Endpoints.baseUrl}/static/streaming-playlists/hls/$uuid/master.m3u8";
}
