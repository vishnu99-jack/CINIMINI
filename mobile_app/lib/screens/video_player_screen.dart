import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/video_model.dart';
import '../repositories/video_details_repository.dart';

class VideoScreen extends StatefulWidget {
  final VideoModel video;

  const VideoScreen({super.key, required this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final Player player;
  late final VideoController controller;

  final repository = VideoDetailsRepository();

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    player = Player();
    controller = VideoController(player);

    loadVideo();
  }

  Future<void> loadVideo() async {
    try {
      final videoUrl = await repository.getPlayableVideo(widget.video.uuid);
      print(videoUrl);
      await player.open(Media(videoUrl));

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video.title)),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
            ? Text(error!)
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(controller: controller),
              ),
      ),
    );
  }
}
