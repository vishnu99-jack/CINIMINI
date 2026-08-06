import '../services/video_details_service.dart';

class VideoDetailsRepository {
  final VideoDetailsService _service = VideoDetailsService();

  Future<String> getPlayableVideo(String uuid) {
    return _service.fetchPlayableVideo(uuid);
  }
}
