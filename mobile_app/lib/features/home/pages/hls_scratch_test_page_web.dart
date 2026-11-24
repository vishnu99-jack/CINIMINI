import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import '../../../config/api_config.dart';
import 'package:flutter/material.dart';

class HlsScratchTestPage extends StatefulWidget {
  const HlsScratchTestPage({super.key});

  @override
  State<HlsScratchTestPage> createState() =>
      _HlsScratchTestPageState();
}

class _HlsScratchTestPageState
    extends State<HlsScratchTestPage> {

  static const String videoUUID =
      'e9713faa-0591-460e-a16f-d51063de1dd1';

static String get videoUrl =>
      '${ApiConfig.backendUrl}/api/videos/$videoUUID/hls/master.m3u8';

  static const String viewType = 'scratch-hls-video-player';

  bool isPlayerReady = false;
  String statusMessage = 'Initializing video player...';

  @override
  void initState() {
    super.initState();

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final video = html.VideoElement()
          ..id = 'scratch-hls-video-$viewId'
          ..controls = true
          ..autoplay = false
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = 'black';

        video.onCanPlay.listen((event) {
          if (!mounted) return;

          setState(() {
            isPlayerReady = true;
            statusMessage = 'Video is ready!';
          });
        });

        video.onError.listen((event) {
          if (!mounted) return;

          setState(() {
            statusMessage =
                'Video element error: ${video.error?.message}';
          });

          debugPrint(
            'Video element error: ${video.error?.message}',
          );
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            js.context.callMethod(
              'initializeHlsPlayer',
              [videoUrl, video],
            );

            if (mounted) {
              setState(() {
                statusMessage = 'HLS.js initialized. Loading stream...';
              });
            }
          } catch (error) {
            debugPrint('HLS initialization error: $error');

            if (mounted) {
              setState(() {
                statusMessage =
                    'HLS initialization failed: $error';
              });
            }
          }
        });

        return video;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLS Scratch Test'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // VIDEO PLAYER
          AspectRatio(
            aspectRatio: 16 / 9,
            child: HtmlElementView(
              viewType: viewType,
            ),
          ),

          const SizedBox(height: 20),

          // STATUS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // LOADING INDICATOR
          if (!isPlayerReady)
            const CircularProgressIndicator(),

          const SizedBox(height: 20),

          // STREAM URL
          // STREAM URL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(videoUrl, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

