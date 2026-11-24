import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/video_model.dart';
import '../repositories/video_details_repository.dart';

class VideoScreen extends StatefulWidget {
  final VideoModel video;

  const VideoScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final Player _player;
  late final VideoController _controller;

  final VideoDetailsRepository _repository =
      VideoDetailsRepository();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _player = Player();

    _controller = VideoController(_player);

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl =
          await _repository.getPlayableVideo(widget.video.uuid);

      await _player.open(
        Media(videoUrl),
        play: true,
      );

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
    _player.dispose();
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
            ? _buildError()
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Video(
                      controller: _controller,
                    ),

                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Unable to play this video',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _error = null;
              _isLoading = true;
            });

            _initializeVideo();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
