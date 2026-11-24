import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class TestVideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const TestVideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
  });

  @override
  State<TestVideoPlayerPage> createState() => _TestVideoPlayerPageState();
}

class _TestVideoPlayerPageState extends State<TestVideoPlayerPage> {
  VideoPlayerController? _controller;

  bool _isInitialized = false;
  String? _error;

  // Slider state.
  bool _isDragging = false;
  Duration? _dragPosition;

  // Orientation state.
  bool _isLandscape = false;

  // Landscape control visibility.
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();

    debugPrint('========================================');
    debugPrint('[PLAYER] VIDEO PLAYER INITIALIZATION');
    debugPrint('========================================');
    debugPrint('[PLAYER] URL: ${widget.videoUrl}');

    _initializePlayer();
  }

  // ---------------------------------------------------------
  // INITIALIZE VIDEO PLAYER
  // ---------------------------------------------------------

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      _controller!.addListener(_onPlayerChanged);

      debugPrint('[PLAYER] Initializing controller...');

      await _controller!.initialize();

      debugPrint('[PLAYER] Initialization successful');
      debugPrint('[PLAYER] Duration: ${_controller!.value.duration}');
      debugPrint(
        '[PLAYER] Resolution: '
        '${_controller!.value.size.width} x '
        '${_controller!.value.size.height}',
      );

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      await _controller!.play();

      debugPrint('[PLAYER] Playback started');

      _scheduleControlsHide();
    } catch (e, stackTrace) {
      debugPrint('[PLAYER ERROR] $e');
      debugPrint('[PLAYER ERROR] $stackTrace');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    }
  }

  // ---------------------------------------------------------
  // PLAYER LISTENER
  // ---------------------------------------------------------

  void _onPlayerChanged() {
    if (!mounted) return;

    final controller = _controller;

    if (controller != null && !controller.value.isPlaying) {
      // Keep controls visible when paused or playback ends.
      _hideControlsTimer?.cancel();

      if (!_showControls) {
        setState(() {
          _showControls = true;
        });
        return;
      }
    }

    setState(() {});
  }

  // ---------------------------------------------------------
  // PLAY / PAUSE
  // ---------------------------------------------------------

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;

    if (_controller!.value.isPlaying) {
      debugPrint('[PLAYER] Pause button clicked');

      _hideControlsTimer?.cancel();

      await _controller!.pause();

      if (!mounted) return;

      setState(() {
        _showControls = true;
      });

      debugPrint('[PLAYER] Playback paused');
    } else {
      debugPrint('[PLAYER] Play button clicked');

      await _controller!.play();

      if (!mounted) return;

      setState(() {
        _showControls = true;
      });

      _scheduleControlsHide();

      debugPrint('[PLAYER] Playback resumed');
    }
  }

  // ---------------------------------------------------------
  // LANDSCAPE CONTROL VISIBILITY
  // ---------------------------------------------------------

  void _showControlsAndStartTimer() {
    if (!mounted) return;

    setState(() {
      _showControls = true;
    });

    _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _hideControlsTimer?.cancel();

    final controller = _controller;

    if (!_isLandscape ||
        controller == null ||
        !controller.value.isPlaying ||
        _isDragging) {
      return;
    }

    debugPrint('[PLAYER] Controls will hide in 5 seconds');

    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_isLandscape || _isDragging) return;

      if (_controller?.value.isPlaying == true) {
        debugPrint('[PLAYER] Auto-hiding landscape controls');

        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleLandscapeVideoTap() {
    if (!_showControls) {
      debugPrint('[PLAYER] Screen tapped - showing controls');

      _showControlsAndStartTimer();
    } else if (_controller?.value.isPlaying == true) {
      debugPrint('[PLAYER] Screen tapped - hiding controls');

      _hideControlsTimer?.cancel();

      setState(() {
        _showControls = false;
      });
    } else {
      // Keep controls visible while paused.
      debugPrint('[PLAYER] Video is paused - keeping controls visible');
    }
  }

  // ---------------------------------------------------------
  // SEEK VIDEO
  // ---------------------------------------------------------

  Future<void> _seekVideo(Duration position) async {
    if (_controller == null) return;

    debugPrint('[PLAYER] Seeking to: $position');

    await _controller!.seekTo(position);

    debugPrint('[PLAYER] Seek completed');

    if (mounted && _isLandscape && !_isDragging) {
      _scheduleControlsHide();
    }
  }

  // ---------------------------------------------------------
  // FORMAT DURATION
  // ---------------------------------------------------------

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hh = hours.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }

    return '$mm:$ss';
  }

  // ---------------------------------------------------------
  // ORIENTATION
  // ---------------------------------------------------------

  Future<void> _toggleOrientation() async {
    if (_isLandscape) {
      debugPrint('[PLAYER] Switching to portrait mode');

      _hideControlsTimer?.cancel();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      if (!mounted) return;

      setState(() {
        _isLandscape = false;
        _showControls = true;
      });
    } else {
      debugPrint('[PLAYER] Switching to landscape mode');

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      if (!mounted) return;

      setState(() {
        _isLandscape = true;
        _showControls = true;
      });

      _scheduleControlsHide();
    }
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------

  @override
  void dispose() {
    debugPrint('[PLAYER] Disposing video controller');

    _hideControlsTimer?.cancel();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Hide AppBar in landscape.
      appBar: _isLandscape
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              title: Text(widget.videoTitle),
              actions: [
                IconButton(
                  onPressed: _toggleOrientation,
                  icon: const Icon(Icons.screen_rotation, color: Colors.white),
                  tooltip: 'Landscape mode',
                ),
              ],
            ),

      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Playback Error:\n$_error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : _isLandscape
          ? _buildLandscapePlayer()
          : _buildPortraitPlayer(),
    );
  }

  // ---------------------------------------------------------
  // PORTRAIT PLAYER
  // ---------------------------------------------------------

  Widget _buildPortraitPlayer() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video display.
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),

          const SizedBox(height: 16),

          // Play / Pause button.
          IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              _controller!.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white,
              size: 65,
            ),
          ),

          const SizedBox(height: 8),

          // Progress bar.
          _buildProgressBar(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // LANDSCAPE PLAYER
  // ---------------------------------------------------------

  Widget _buildLandscapePlayer() {
    return Stack(
      children: [
        // Video area and tap detection.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleLandscapeVideoTap,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),

        // Landscape controls with fade animation.
        IgnorePointer(
          ignoring: !_showControls,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Stack(
              children: [
                // Top controls.
                Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _toggleOrientation,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        tooltip: 'Exit landscape mode',
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          widget.videoTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center play / pause button.
                Center(
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 75,
                    ),
                  ),
                ),

                // Bottom progress controls.
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 8,
                  child: SafeArea(top: false, child: _buildProgressBar()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // SHARED PROGRESS BAR
  // ---------------------------------------------------------

  Widget _buildProgressBar() {
    final value = _controller!.value;

    final duration = value.duration;
    final currentPosition = value.position;

    final sliderPosition = _dragPosition ?? currentPosition;

    final maxMilliseconds = duration.inMilliseconds.toDouble();

    final currentMilliseconds = sliderPosition.inMilliseconds.toDouble().clamp(
      0.0,
      maxMilliseconds > 0 ? maxMilliseconds : 1.0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            min: 0,
            max: maxMilliseconds > 0 ? maxMilliseconds : 1,
            value: currentMilliseconds,

            activeColor: Colors.red,
            inactiveColor: Colors.white30,

            onChangeStart: (value) {
              _hideControlsTimer?.cancel();

              setState(() {
                _isDragging = true;
                _dragPosition = Duration(milliseconds: value.toInt());

                _showControls = true;
              });

              debugPrint('[PLAYER] Progress bar interaction started');
            },

            onChanged: (value) {
              setState(() {
                _dragPosition = Duration(milliseconds: value.toInt());
              });
            },

            onChangeEnd: (value) async {
              final position = Duration(milliseconds: value.toInt());

              setState(() {
                _isDragging = false;
                _dragPosition = null;
              });

              await _seekVideo(position);

              if (mounted && _isLandscape) {
                _scheduleControlsHide();
              }
            },
          ),

          // Current time and total duration.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_isDragging ? sliderPosition : currentPosition),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),

              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
