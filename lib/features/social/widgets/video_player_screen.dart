import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../app/theme/uaxis_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? localPath;
  final bool autoPlay;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.localPath,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        final file = File(widget.localPath!);
        if (await file.exists()) {
          _controller = VideoPlayerController.file(file);
        } else {
          _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        }
      } else if (widget.videoUrl.isNotEmpty) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        setState(() => _hasError = true);
        return;
      }

      await _controller.initialize();
      _controller.addListener(_videoListener);
      
      if (mounted) {
        setState(() => _isInitialized = true);
        if (widget.autoPlay) {
          _controller.play();
          _startHideControlsTimer();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _hideControlsTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      _controller.play();
      _startHideControlsTimer();
    }
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position);
    _startHideControlsTimer();
  }

  void _skip(int seconds) {
    final newPosition = _controller.value.position + Duration(seconds: seconds);
    final duration = _controller.value.duration;
    if (newPosition < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (newPosition > duration) {
      _controller.seekTo(duration);
    } else {
      _controller.seekTo(newPosition);
    }
    _startHideControlsTimer();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _buildVideoContent(),
            ),
            if (_isInitialized && !_hasError)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: _buildControls(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white38, size: 64),
          const SizedBox(height: 16),
          Text(
            'Failed to load video',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            label: const Text('Go Back', style: TextStyle(color: Colors.white70)),
          ),
        ],
      );
    }

    if (!_isInitialized) {
      return const CircularProgressIndicator(
        color: UAxisColors.social,
        strokeWidth: 3,
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          if (_controller.value.volume > 0) {
                            _controller.setVolume(0);
                          } else {
                            _controller.setVolume(1);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.replay_10,
                    size: 36,
                    onTap: () => _skip(-10),
                  ),
                  _buildControlButton(
                    icon: _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 64,
                    onTap: _togglePlayPause,
                    isPrimary: true,
                  ),
                  _buildControlButton(
                    icon: Icons.forward_10,
                    size: 36,
                    onTap: () => _skip(10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: UAxisColors.social,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: UAxisColors.social,
                      overlayColor: UAxisColors.social.withValues(alpha: 0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _isDragging
                          ? _controller.value.position.inMilliseconds.toDouble()
                          : _controller.value.position.inMilliseconds.toDouble().clamp(
                              0,
                              _controller.value.duration.inMilliseconds.toDouble(),
                            ),
                      min: 0,
                      max: _controller.value.duration.inMilliseconds.toDouble(),
                      onChangeStart: (_) {
                        setState(() => _isDragging = true);
                        _hideControlsTimer?.cancel();
                      },
                      onChanged: (value) {
                        _controller.seekTo(Duration(milliseconds: value.toInt()));
                      },
                      onChangeEnd: (value) {
                        setState(() => _isDragging = false);
                        _seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
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

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 80 : 60,
        height: isPrimary ? 80 : 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.black : Colors.white,
          size: size,
        ),
      ),
    );
  }
}
