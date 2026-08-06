import '../models/video_model.dart';
import '../services/video_services.dart';

class VideoRepository {
  final VideoService _service = VideoService();

  Future<List<VideoModel>> getVideos() {
    return _service.fetchVideos();
  }
}
