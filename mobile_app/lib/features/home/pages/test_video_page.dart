import 'package:flutter/material.dart';
import 'package:mobile_app/models/video_model.dart';
import '../services/test_video_service.dart';
import 'test_video_player_page.dart';

class TestVideoPage extends StatefulWidget {
  const TestVideoPage({super.key});

  @override
  State<TestVideoPage> createState() => _TestVideoPageState();
}

class _TestVideoPageState extends State<TestVideoPage> {
  final TestVideoService _service = TestVideoService();

  late Future<VideoModel> _videoFuture;

  @override
  void initState() {
    super.initState();

    debugPrint('[TEST] Test video page initialized');

    _loadVideo();
  }

void _loadVideo() {
    debugPrint('[TEST] Starting first-video fetch');

    _videoFuture = _service.fetchFirstVideo();

    _videoFuture
        .then((video) async {
          debugPrint('[TEST] First video received successfully');
          debugPrint('[TEST] Starting HLS URL extraction');

          final hlsUrl = await _service.fetchVideoHlsUrl(video.uuid);

          debugPrint('[TEST] HLS URL received successfully');
          debugPrint('[TEST] Final playable URL: $hlsUrl');
        })
        .catchError((error) {
          debugPrint('[ERROR] HLS URL extraction failed: $error');
        });
  }

  void _retry() {
    setState(() {
      _loadVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('Test Video Playback'),
        backgroundColor: Colors.black,
      ),

      body: FutureBuilder<VideoModel>(
        future: _videoFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            final video = snapshot.data!;

            debugPrint('[TEST] Displaying first video card');

            return Padding(
              padding: const EdgeInsets.all(16),

              child: Card(
                color: const Color(0xFF202020),
                clipBehavior: Clip.antiAlias,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,

                      child: Image.network(
                        video.thumbnail,
                        width: double.infinity,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            video.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            video.channel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),

                              SizedBox(width: 8),

                              Text(
                                'PeerTube API: Success',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                debugPrint('[TEST] Play button clicked');

                                try {
                                  final hlsUrl = await _service
                                      .fetchVideoHlsUrl(video.uuid);

                                  if (!mounted) return;

                                  debugPrint(
                                    '[TEST] Opening independent video player',
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TestVideoPlayerPage(
                                        videoUrl: hlsUrl,
                                        videoTitle: video.title,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint(
                                    '[ERROR] Unable to open player: $e',
                                  );
                                }
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play Video'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text(
              'No video available',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
