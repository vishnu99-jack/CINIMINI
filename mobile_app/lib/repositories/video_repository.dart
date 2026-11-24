import '../models/video_model.dart';
import '../services/video_services.dart';

/// ===============================================================
/// Cinimini Video Repository
/// ---------------------------------------------------------------
/// Repository layer between the UI and VideoService.
///
/// UI / Pages
///      ↓
/// VideoRepository
///      ↓
/// VideoService
///      ↓
/// PeerTube REST API
/// ===============================================================

class VideoRepository {
  VideoRepository({VideoService? service})
    : _service = service ?? VideoService();

  final VideoService _service;

  /// Fetches videos from PeerTube through the service layer.
  ///
  /// The UI should never communicate directly with VideoService.
  Future<List<VideoModel>> getVideos() async {
    return _service.fetchVideos();
  }
}
