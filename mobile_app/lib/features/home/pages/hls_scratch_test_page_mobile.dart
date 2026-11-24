import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../config/api_config.dart';

class HlsScratchTestPage extends StatefulWidget {
  const HlsScratchTestPage({super.key});

  @override
  State<HlsScratchTestPage> createState() => _HlsScratchTestPageState();
}

class _HlsScratchTestPageState extends State<HlsScratchTestPage> {
  static const String videoUUID = 'e9713faa-0591-460e-a16f-d51063de1dd1';

static String get videoUrl =>
      '${ApiConfig.backendUrl}/api/videos/$videoUUID/hls/master.m3u8';

  late VideoPlayerController _controller;

  bool isInitialized = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        isInitialized = true;
      });
    } catch (error) {
      debugPrint('Video initialization failed: $error');

      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CiniMini HLS Player')),

      body: Center(
        child: errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load video:\n$errorMessage',
                  textAlign: TextAlign.center,
                ),
              )
            : !isInitialized
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),

                  const SizedBox(height: 20),

                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),

                  const SizedBox(height: 15),

                  IconButton(
                    iconSize: 45,

                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),

                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
