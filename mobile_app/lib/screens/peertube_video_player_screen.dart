import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../repositories/video_details_repository.dart';
import '../features/home/pages/test_video_player_page.dart';

class PeerTubeVideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const PeerTubeVideoPlayerScreen({super.key, required this.video});

  @override
  State<PeerTubeVideoPlayerScreen> createState() =>
      _PeerTubeVideoPlayerScreenState();
}

class _PeerTubeVideoPlayerScreenState extends State<PeerTubeVideoPlayerScreen> {
  final VideoDetailsRepository _repository = VideoDetailsRepository();

  late Future<String> _videoUrlFuture;

  @override
  void initState() {
    super.initState();

    debugPrint('========================================');
    debugPrint('[PRODUCTION PLAYER] INITIALIZATION');
    debugPrint('========================================');

    debugPrint('[VIDEO] Title: ${widget.video.title}');
    debugPrint('[VIDEO] UUID: ${widget.video.uuid}');

    _loadVideo();
  }

  // ==========================================
  // FETCH PLAYABLE VIDEO URL
  // ==========================================

  void _loadVideo() {
    debugPrint('[PRODUCTION PLAYER] Fetching HLS URL');

    _videoUrlFuture = _repository.getPlayableVideo(widget.video.uuid);
  }

  // ==========================================
  // RETRY
  // ==========================================

  void _retry() {
    setState(() {
      _loadVideo();
    });
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _videoUrlFuture,

      builder: (context, snapshot) {
        // LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text(widget.video.title),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // ERROR
        if (snapshot.hasError) {
          debugPrint('[PRODUCTION PLAYER ERROR] ${snapshot.error}');

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text(widget.video.title),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 55,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Unable to load video',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // SUCCESS
        if (snapshot.hasData) {
          final videoUrl = snapshot.data!;

          debugPrint('[PRODUCTION PLAYER] HLS URL received successfully');

          debugPrint('[PRODUCTION PLAYER] URL: $videoUrl');

          return TestVideoPlayerPage(
            videoUrl: videoUrl,
            videoTitle: widget.video.title,
          );
        }

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Unable to load video',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
