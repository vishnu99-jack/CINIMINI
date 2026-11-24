import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';
import '../repositories/video_details_repository.dart';

class VideoPlayerTestScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerTestScreen({super.key, required this.video});

  @override
  State<VideoPlayerTestScreen> createState() => _VideoPlayerTestScreenState();
}

class _VideoPlayerTestScreenState extends State<VideoPlayerTestScreen> {
  VideoPlayerController? _controller;

  bool _isLoading = true;
  String? _error;

  final VideoDetailsRepository _repository = VideoDetailsRepository();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = await _repository.getPlayableVideo(widget.video.uuid);

      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      _controller = controller;

      await controller.initialize();
      await controller.play();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.video.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white))
            : _isLoading || _controller == null
            ? const CircularProgressIndicator(color: Colors.white)
            : AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),
                    VideoPlayerControls(controller: _controller!),
                  ],
                ),
              ),
      ),
    );
  }
}

class VideoPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) {
          return AnimatedOpacity(
            opacity: value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 64,
            ),
          );
        },
      ),
    );
  }
}
